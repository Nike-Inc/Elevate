//
//  Elevate.swift
//  Elevate
//
//  Created by Eric Appel on 7/13/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

// MARK: - Decodable

// TODO: Add docstring
public protocol Decodable {
    init(json: AnyObject) throws
}

// MARK: - Decoder

// TODO: Add docstring
public protocol Decoder {
    func decodeObject(object: AnyObject) throws -> Any
}

// MARK: - ParserError

// TODO: Add docstring
public enum ParserError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    case Deserialization(failureReason: String)
    case Validation(failureReason: String)

    // TODO: Add docstring
    public var failureReason: String {
        switch self {
        case .Deserialization(let failureReason):
            return failureReason
        case .Validation(let failureReason):
            return failureReason
        }
    }

    // TODO: Add docstring
    public var description: String {
        switch self {
        case .Deserialization(let failureReason):
            return "Parser Deserialization Error - \(failureReason)"
        case .Validation(let failureReason):
            return "Parser Validation Error - \(failureReason)"
        }
    }

    // TODO: Add docstring
    public var debugDescription: String {
        return self.description
    }
}

// MARK: -

// TODO: Add docstring
public class Parser {

    // MARK: Decodable Parsing Methods

    // TODO: Add docstring
    public class func parse<T: Decodable>(data data: NSData, forKeyPath keyPath: String) throws -> T {
        let properties = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Dictionary, decodedToType: T.self)
        }

        return properties[keyPath] as! T
    }

    // TODO: Add docstring
    public class func parse<T: Decodable>(data data: NSData, forKeyPath keyPath: String) throws -> [T] {
        let properties = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Array, decodedToType: T.self)
        }

        return (properties[keyPath] as! [Any]).map { $0 as! T }
    }

    public class func parse<T>(data data: NSData, forKeyPath keyPath: String, withDecoder decoder: Decoder) throws -> T {
        let result = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Dictionary, decoder: decoder)
        }

        return result[keyPath] as! T
    }

    public class func parse<T>(data data: NSData, forKeyPath keyPath: String, withDecoder decoder: Decoder) throws -> [T] {
        let result = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Array, decoder: decoder)
        }

        return (result[keyPath] as! [Any]).map { $0 as! T }
    }

    // MARK: Property Parsing Methods

    /**
        Performs the work of validating and extracting values from the passed in NSData object. The NSData object must
        contain json that can be deserialized by `NSJSONSerialization.JSONObjectWithData`.

        Returns resulting Dictionary object containing all the parsed property results where the property keyPath is 
        the key and the extracted object is the value. The value is guaranteed to be an object of the type defined by 
        the property and can be cast to that type directly, without further checks.

        - parameter data:    An NSData object containing encoded json data.
        - parameter closure: Defines the property list for the parser via the passed in `ParserPropertyMaker` instance.

        - returns: The result Dictionary.
    */
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

    /**
        Performs the work of validating and extracting values from the passed in Dictionary object. The type of the
        object passed in must be [String: AnyObject]. Values in the Dictionary must be `NSJSONSerialization` compatible.

        Defining the property list to be parsed is achieved using a maker pattern via the `ParserPropertyMaker` object 
        passed into the trailing closure. Inside the closure, for each property, call the `propertyForKeyPath` instance 
        method.

        The parser will evaluate each property using the following steps:

        1) Extract the object for the given keyPath
        2) Validate the value type and optionality
        3) Extract the value in the specified type
        4) Optionally, run the parser on the value or on each item in an array

        The resulting Dictionary contains all the parsed property results where the property keyPath is the key and the 
        extracted object is the value. The value is guaranteed to be an object of the type defined by the property and 
        can be cast to that type directly, without further checks.

        See the README for code samples and best practices for creating re-usable `Decoder`s.

        - parameter data:    A NSData object containing encoded json data.
        - parameter closure: Defines the property list for the parser via the passed in `ParserPropertyMaker` instance.

        - returns: The result Dictionary.
    */
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
                    parsedValue = (jsonValue as! NSNumber).unsignedLongValue
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
            if !valueIsSpecifiedType(value: value, type: property.type) {
                errorDescription = "Value for key path [\(property.keyPath)] is of incorrect type"
            }
        }

        return errorDescription
    }

    class func valueIsSpecifiedType(value value: AnyObject, type: ParserPropertyType) -> Bool {
        var isValid = false

        switch value {
        case let number as NSNumber:
            if number.isBool && type == .Bool {
                isValid = true
            } else {
                switch type {
                case .Int, .UInt, .Double, .Float:
                    isValid = true
                default:
                    isValid = false
                }
            }
        case is NSString:
            isValid = type == .String || type == .URL
        case is [AnyObject]:
            isValid = type == .Array
        case is [String: AnyObject]:
            isValid = type == .Dictionary
        default:
            break
        }

        return isValid
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

/**
    The parser property maker is used to define the list of properties to be validated and extracted from a object. 
    If a property is not defined in the list it will be ignored.
*/
public class ParserPropertyMaker {
    var properties = [ParserProperty]()

    /**
        Creates, adds and returns a property for the specified key path, type and optionality.

        NOTE: Compound key paths may be used (e.g. `address.city`). Each property name in the key path MUST be 
        separated by a `.` character.

        - parameter keyPath:  Key path for property.
        - parameter type:     Swift object type to be validated and extracted.
        - parameter optional: Specifies if the keyPath is optional. `false` by default.

        - returns: The created parser property.
    */
    public func propertyForKeyPath(keyPath: String, type: ParserPropertyType, optional: Bool = false) -> ParserProperty {
        return addProperty(keyPath: keyPath, type: type, optional: optional, decodingMethod: nil)
    }

    /**
        Creates, adds and returns a property for the specified key path, type, optionality and decodable type.

        NOTE: Compound key paths may be used (e.g. `address.city`). Each property name in the key path MUST be
        separated by a `.` character.

        - parameter keyPath:       Key path for property.
        - parameter type:          Swift object type to be validated and extracted.
        - parameter optional:      Specifies if the keyPath is optional. `false` by default.
        - parameter decodedToType: The `Decodable` type associated to the property. `nil` by default.

        - returns: The created parser property.
    */
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

    /**
        Creates, adds and returns a property for the specified key path, type, optionality and decoder.

        NOTE: Compound key paths may be used (e.g. `address.city`). Each property name in the key path MUST be
        separated by a `.` character.

        - parameter keyPath:  Key path for property.
        - parameter type:     Swift object type to be validated and extracted.
        - parameter optional: Specifies if the keyPath is optional. `false` by default.
        - parameter decoder:  The `Decoder` associated to the property. `nil` by default.

        - returns: The created parser property.
    */
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

/**
    Defines a Swift object type used to extract values from a JSON document.

    - String:     Represents a Swift `String` type.
    - UInt:       Represents a Swift `UInt` type.
    - Int:        Represents a Swift `Int` type.
    - Float:      Represents a Swift `Float` type.
    - Double:     Represents a Swift `Double` type.
    - Bool:       Represents a Swift `Bool` type.
    - Array:      Represents a Swift `Array` type.
    - Dictionary: Represents a Swift `Dictionary` type.
    - URL:        Represents a Swift `URL` type.
*/
public enum ParserPropertyType {
    case String
    case UInt
    case Int
    case Float
    case Double
    case Bool
    case Array
    case Dictionary
    case URL
}

/**
    Represents a parser property and all its internal characteristics.
*/
public struct ParserProperty {

    // TODO: Add docstring
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

/**
    Decodes a String to an Int.
*/
public class StringToIntDecoder: Decoder {

    /**
        Converts the `String` object to an `Int`.

        - parameter object: The `String` to decode.

        - returns: The decoded `Int` or throws.
    */
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

/**
    The date decoder converts a `String` into an `NSDate` object using the provided date format string 
    or `NSDateFormatter`.
*/
public class DateDecoder: Decoder {
    private let dateFormatter: NSDateFormatter

    /**
        Creates a data decoder with the given date format string.

        - parameter dateFormatString: The date format string.

        - returns: The date decoder.
    */
    public init(dateFormatString: String) {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateFormat = dateFormatString
    }

    /**
        Creates a date decoder with the given date formatter.

        - parameter dateFormatter: A `NSDateFormatter` instance.

        - returns: The date decoder.
    */
    public init(dateFormatter: NSDateFormatter) {
        self.dateFormatter = dateFormatter
    }

    /**
        Decodes the data parameter into an `NSDate`.

        - parameter data: The string to parse. MUST be of type `String` or `NSString`.

        - returns: The parsed date.
    */
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
