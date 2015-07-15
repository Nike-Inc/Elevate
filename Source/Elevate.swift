//
//  Elevate.swift
//  Elevate
//
//  Created by Eric Appel on 7/13/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

// MARK: -

public protocol Decodable {
    init(json: AnyObject?) throws
}

public protocol Decoder {
    func decodeObject(object: AnyObject) throws -> Any
}

// MARK: -

public enum ParserError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    case Deserialization(failureReason: String)
    case Validation(failureReason: String)

    public var failureReason: String {
        switch self {
        case .Deserialization(let failureReason):
            return failureReason
        case .Validation(let failureReason):
            return failureReason
        }
    }

    public var description: String {
        switch self {
        case .Deserialization(let failureReason):
            return "Parser Deserialization Error - \(failureReason)"
        case .Validation(let failureReason):
            return "Parser Validation Error - \(failureReason)"
        }
    }

    public var debugDescription: String {
        return self.description
    }
}

// MARK: -

public class Parser {
    public class func parseDecodable<T: Decodable>(
        data data: NSData,
        forKeyPath keyPath: String)
        throws -> T
    {
        let properties = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Dictionary, decodedToType: T.self)
        }

        return properties[keyPath] as! T
    }

    public class func parseDecodableArray<T: Decodable>(
        data data: NSData,
        forKeyPath keyPath: String)
        throws -> [T]
    {
        let properties = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Array, decodedToType: T.self)
        }

        return properties[keyPath] as! [T]
    }

    public class func parseProperties(data data: NSData, closure: ParserPropertyMaker -> Void) throws -> [String: Any] {
        let failureReason: String

        do {
            let options = NSJSONReadingOptions(rawValue: 0)

            guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: options) as? [String: AnyObject] else {
                let failureReason = "JSON data deserialization failed because result was not of type: [String: AnyObject]"
                throw ParserError.Deserialization(failureReason: failureReason)
            }

            return try parseProperties(json: json, closure: closure)
        } catch ParserError.Validation(let parserFailureReason) {
            failureReason = parserFailureReason
        } catch let error as NSError {
            failureReason = "JSON data serialization failed with error: \"\(error.description)\""
        }

        throw ParserError.Validation(failureReason: failureReason)
    }

    public class func parseProperties(json json: AnyObject, closure: ParserPropertyMaker -> Void) throws -> [String: Any] {
        guard json is [String: AnyObject] else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: [String: AnyObject]")
        }

        var parsingErrorDescriptions = [String]()
        var parsed = [String: Any]()
        let propertyMaker = ParserPropertyMaker()

        closure(propertyMaker)

        for property in propertyMaker.properties {
            let jsonValue: AnyObject = Parser.json(json, forKeyPath: property.keyPath)
            var parsedValue: AnyObject?

            if property.optional && jsonValue is NSNull {
                parsedValue = Optional.None
            } else if let errorDescription = validateValue(jsonValue, forProperty: property) {
                parsingErrorDescriptions.append(errorDescription)
            } else {
                switch property.type {
                case .String:
                    parsedValue = jsonValue
                    parsed[property.keyPath] = jsonValue
                case .UInt:
                    parsedValue = (jsonValue as! NSNumber).unsignedIntegerValue
                    parsed[property.keyPath] = parsedValue
                case .Int:
                    parsedValue = (jsonValue as! NSNumber).integerValue
                    parsed[property.keyPath] = parsedValue
                case .Float:
                    parsedValue = (jsonValue as! NSNumber).floatValue
                    parsed[property.keyPath] = parsedValue
                case .Double:
                    parsedValue = (jsonValue as! NSNumber).doubleValue
                    parsed[property.keyPath] = parsedValue
                case .Number:
                    parsedValue = jsonValue
                    parsed[property.keyPath] = jsonValue
                case .Bool:
                    parsedValue = (jsonValue as! NSNumber).boolValue
                    parsed[property.keyPath] = parsedValue
                case .Array:
                    if let decodingMethod = property.decodingMethod {
                        do {
                            let result = try parseArray(data: jsonValue, decodingMethod: decodingMethod)
                            parsed[property.keyPath] = result
                        } catch ParserError.Validation(let failureReason) {
                            parsingErrorDescriptions.append(failureReason)
                        }
                    } else {
                        parsed[property.keyPath] = jsonValue
                    }
                case .Dictionary:
                    parsedValue = jsonValue
                    parsed[property.keyPath] = jsonValue
                case .URL:
                    let url = NSURL(string: jsonValue as! String)
                    if url == nil && !property.optional {
                        let description = "Required key path [\(property.keyPath)] could not be parsed to valid URL"
                        parsingErrorDescriptions.append(description)
                    } else {
                        parsedValue = url
                        parsed[property.keyPath] = url
                    }
                }

                if let decodingMethod = property.decodingMethod {
                    if let value: AnyObject = parsedValue {
                        do {
                            let result: Any

                            switch decodingMethod {
                            case .UseDecoder(let decoder):
                                result = try decoder.decodeObject(value)
                            case .UseDecodable(let decodableType):
                                result = try decodableType.init(json: value)
                            }

                            parsed[property.keyPath] = result
                        } catch ParserError.Validation(let failureReason) {
                            parsingErrorDescriptions.append(failureReason)
                        }
                    }
                }
            }
        }

        guard parsingErrorDescriptions.isEmpty else {
            let joinedDescriptions = "\n".join(parsingErrorDescriptions)
            throw ParserError.Validation(failureReason: joinedDescriptions)
        }

        return parsed
    }

    // MARK: Private - Parser Helper Methods

    private class func json(var json: AnyObject?, forKeyPath keypath: String) -> AnyObject {
        let keys = split(keypath.characters) { $0 == "." }.map { String($0) }

        for key in keys {
            let dictionary = json as! [String: AnyObject]

            if let value: AnyObject = dictionary[key] {
                json = value
            } else {
                json = nil
                break
            }
        }

        return json ?? NSNull()
    }

    private class func validateValue(value: AnyObject, forProperty property: ParserProperty) -> String?  {
        var errorDescription: String? = nil

        if property.optional == false && value is NSNull {
            errorDescription = "Required key path [\(property.keyPath)] was missing or null"
        } else if property.optional == true && value is NSNull {
            return nil
        } else {
            var isCorrectType = false

            switch value {
            case let number as NSNumber:
                if number.isBool && property.type == .Bool {
                    isCorrectType = true
                } else {
                    switch property.type {
                    case .Number, .Int, .UInt, .Double, .Float:
                        isCorrectType = true
                    default:
                        isCorrectType = false
                    }
                }
            case is NSString:
                isCorrectType = property.type == .String || property.type == .URL
            case is [AnyObject]:
                isCorrectType = property.type == .Array
            case is [String: AnyObject]:
                isCorrectType = property.type == .Dictionary
            default:
                break
            }

            if !isCorrectType {
                errorDescription = "Value for key path [\(property.keyPath)] is of incorrect type"
            }
        }

        return errorDescription
    }

    private class func parseArray(data data: AnyObject, decodingMethod: ParserProperty.DecodingMethod) throws -> [Any] {
        var parsed = [Any]()
        var parsingErrorDescriptions = [String]()

        if let items = data as? [AnyObject] {
            for (index, item) in items.enumerate() {
                do {
                    let result: Any

                    switch decodingMethod {
                    case .UseDecoder(let decoder):
                        result = try decoder.decodeObject(item)
                    case .UseDecodable(let decodableType):
                        result = try decodableType.init(json: item)
                    }

                    parsed.append(result)
                } catch ParserError.Validation(let failureReason) {
                    let decodingObject: Any

                    switch decodingMethod {
                    case .UseDecoder(let decoder):
                        decodingObject = decoder
                    case .UseDecodable(let decodableType):
                        decodingObject = decodableType
                    }

                    let description = (
                        "Error parsing array object at index \(index) with " +
                        "parser [\(decodingObject)]\n\(failureReason)\n--"
                    )

                    parsingErrorDescriptions.append(description)
                }
            }
        }

        guard parsingErrorDescriptions.isEmpty else {
            let joinedDescriptions = "\n".join(parsingErrorDescriptions)
            throw ParserError.Validation(failureReason: joinedDescriptions)
        }

        return parsed
    }
}

// MARK: -

public class ParserPropertyMaker {
    var properties = [ParserProperty]()

    public func propertyForKeyPath(keyPath: String, type: ParserPropertyType, optional: Bool = false) -> ParserProperty {
        return addProperty(keyPath: keyPath, type: type, optional: optional, decodingMethod: nil)
    }

    public func propertyForKeyPath(
        keyPath: String,
        type: ParserPropertyType,
        optional: Bool = false,
        decodedToType decodableType: Decodable.Type?)
        -> ParserProperty
    {
        var decodingMethod: ParserProperty.DecodingMethod?

        if let decodableType = decodableType {
            decodingMethod = ParserProperty.DecodingMethod.UseDecodable(decodableType)
        }

        return addProperty(keyPath: keyPath, type: type, optional: optional, decodingMethod: decodingMethod)
    }

    public func propertyForKeyPath(
        keyPath: String,
        type: ParserPropertyType,
        optional: Bool = false,
        decoder: Decoder?)
        -> ParserProperty
    {
        var decodingMethod: ParserProperty.DecodingMethod?

        if let decoder = decoder {
            decodingMethod = ParserProperty.DecodingMethod.UseDecoder(decoder)
        }

        return addProperty(keyPath: keyPath, type: type, optional: optional, decodingMethod: decodingMethod)
    }

    // MARK: Internal - Helper Methods

    func addProperty(
        keyPath keyPath: String,
        type: ParserPropertyType,
        optional: Bool,
        decodingMethod: ParserProperty.DecodingMethod?)
        -> ParserProperty
    {
        let property = ParserProperty(type: type, keyPath: keyPath, optional: optional, decodingMethod: decodingMethod)
        self.properties.append(property)

        return property
    }
}

// MARK: -

public enum ParserPropertyType {
    case String
    case UInt
    case Int
    case Float
    case Double
    case Number
    case Bool
    case Array
    case Dictionary
    case URL
}

public struct ParserProperty {
    public enum DecodingMethod {
        case UseDecoder(Decoder)
        case UseDecodable(Decodable.Type)
    }

    let type: ParserPropertyType
    let keyPath: String
    let optional: Bool
    let decodingMethod: DecodingMethod?

    init(type: ParserPropertyType, keyPath: String, optional: Bool, decodingMethod: DecodingMethod?) {
        self.type = type
        self.keyPath = keyPath
        self.optional = optional
        self.decodingMethod = decodingMethod
    }
}

// MARK: -

public class StringToIntDecoder: Decoder {
    public func decodeObject(object: AnyObject) throws -> Any {
        if let
            intString = object as? String,
            intValue = Int(intString)
        {
            return intValue
        }

        throw ParserError.Validation(failureReason: "Could not convert String to Int")
    }
}

// MARK: -

public class DateDecoder: Decoder {
    private let dateFormatter: NSDateFormatter

    public init(dateFormatString: String) {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateFormat = dateFormatString
    }

    public init(dateFormatter: NSDateFormatter) {
        self.dateFormatter = dateFormatter
    }

    public func decodeObject(data: AnyObject) throws -> Any {
        if let string = data as? String {
            return try dateFromString(string, withFormatter:self.dateFormatter)
        } else {
            let description = "DateParser object to parse was not a String."
            throw ParserError.Validation(failureReason: description)
        }
    }

    private func dateFromString<T>(string: String, withFormatter formatter: NSDateFormatter) throws -> T {
        let date = formatter.dateFromString(string)

        if let date = date {
            return date as! T
        }

        let description = "DateParser string could not be parsed to NSDate with the given formatter."
        throw ParserError.Validation(failureReason: description)
    }
}

// MARK: -

extension NSNumber {
    var isBool: Bool {
        let isTrue = self == NSNumber(bool: true)
        let isFalse = self == NSNumber(bool: false)
        let isBoolType = String.fromCString(self.objCType) == "c"

        return (isTrue || isFalse) && isBoolType
    }
}
