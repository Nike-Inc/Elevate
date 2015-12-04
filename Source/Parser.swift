//
//  Parser.swift
//  Elevate
//
//  Created by Eric Appel on 7/13/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

/**
    The `Parser` validates and extracts values from json data by allowing you to define the type and optionality
    for each property to be parsed. All parser errors encountered are aggregated when evaluating the data.
*/
public class Parser {

    // MARK: Decodable Parsing Methods

    /**
        Parses json data at the specified key path into an object of type `T`. `T` must implement the `Decodable` protocol.

        - parameter data:       An NSData object containing encoded json data.
        - parameter forKeyPath: The json key path identifying the object to be parsed.

        - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
        - returns: The parsed object.
    */
    public class func parseObject<T: Decodable>(data data: NSData, forKeyPath keyPath: String) throws -> T {
        let properties = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Dictionary, decodedToType: T.self)
        }

        return properties[keyPath] as! T
    }

    /**
        Parses json data at the specified key path into an array of objects of type `T`. `T` must implement the
        `Decodable` protocol.

        - parameter data:       An NSData object containing encoded json data.
        - parameter forKeyPath: The json key path identifying the object to be parsed.

        - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
        - returns: The parsed array of objects
    */
    public class func parseArray<T: Decodable>(data data: NSData, forKeyPath keyPath: String) throws -> [T] {
        let properties = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Array, decodedToType: T.self)
        }

        return (properties[keyPath] as! [Any]).map { $0 as! T }
    }

    /**
        Parses json data at the specified key path into an object of type `T` using the passed in `Decoder` instance.

        - parameter data:        An NSData object containing encoded json data.
        - parameter forKeyPath:  The json key path identifying the object to be parsed.
        - parameter withDecoder: The `Decoder` instance used to parse the data.

        - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
        - returns: The parsed object.
    */
    public class func parseObject<T>(data data: NSData, forKeyPath keyPath: String, withDecoder decoder: Decoder) throws -> T {
        let result = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Dictionary, decoder: decoder)
        }

        return result[keyPath] as! T
    }

    /**
        Parses json data at the specified key path into an array of objects of type `T` using the passed in `Decoder`
        instance.

        - parameter data:        An NSData object containing encoded json data.
        - parameter forKeyPath:  The json key path identifying the object to be parsed.
        - parameter withDecoder: The `Decoder` instance used to parse the data.

        - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
        - returns: The parsed array of objects.
    */
    public class func parseArray<T>(data data: NSData, forKeyPath keyPath: String, withDecoder decoder: Decoder) throws -> [T] {
        let result = try Parser.parseProperties(data: data) { make in
            make.propertyForKeyPath(keyPath, type: .Array, decoder: decoder)
        }

        return (result[keyPath] as! [Any]).map { $0 as! T }
    }

    // MARK: Property Parsing Methods

    /**
        Performs the work of validating and extracting values from the passed in NSData object. The NSData object must
        contain json that can be deserialized by `NSJSONSerialization.JSONObjectWithData`. Fragments are not allowed.

        Returns resulting Dictionary object containing all the parsed property results where the property keyPath is
        the key and the extracted object is the value. The value is guaranteed to be an object of the type defined by
        the property and can be cast to that type directly, without further checks.

        - parameter data:    An NSData object containing encoded json data.
        - parameter closure: Defines the property list for the parser via the passed in `ParserPropertyMaker` instance.

        - returns: The result Dictionary.
    */
    public class func parseProperties(data data: NSData, closure: ParserPropertyMaker -> Void) throws -> [String: Any] {
        let result: [String: Any]
        
        do {
            let options = NSJSONReadingOptions(rawValue: 0)
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: options)

            result = try parseProperties(json: json, closure: closure)
        } catch {
            if error is ParserError {
                throw error
            } else {
                let error = error as NSError
                throw ParserError.Deserialization(failureReason: "JSON data deserialization failed with error: \"\(error.description)\"")
            }
        }

        return result
    }

    /**
        Performs the work of validating and extracting values from the passed in Dictionary or Array object. The type of 
        the object passed in must be [String: AnyObject] or [AnyObject]. Values in the Dictionary must be 
        `NSJSONSerialization` compatible. If the json parameter is an Array, use an empty string for the property key path.

        Defining the property list to be parsed is achieved using a maker pattern via the `ParserPropertyMaker` object
        passed into the trailing closure. Inside the closure, for each property, call the `propertyForKeyPath` instance
        method.

        The parser will evaluate each property using the following steps:

        1) Extract the object for the given keyPath
        2) Validate the value type and optionality
        3) Extract the value in the specified type
        4) Optionally, run the `Decoder` on the value or on each item in an array

        The resulting Dictionary contains all the parsed property results where the property keyPath is the key and the
        extracted object is the value. The value is guaranteed to be an object of the type defined by the property and
        can be cast to that type directly, without further checks.

        See the README for code samples and best practices for creating re-usable `Decoder`s.

        - parameter data:    A NSData object containing encoded json data.
        - parameter closure: Defines the property list for the parser via the passed in `ParserPropertyMaker` instance.

        - returns: The result Dictionary.
    */
    public class func parseProperties(json json: AnyObject, closure: ParserPropertyMaker -> Void) throws -> [String: Any] {
        guard json is [String: AnyObject] || json is [AnyObject] else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: [String: AnyObject] or [AnyObject]")
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
                        parsingErrorDescriptions.append("A decoding method was not provided for `\(property.keyPath)` array")
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
            let joinedDescriptions = parsingErrorDescriptions.joinWithSeparator("\n")
            throw ParserError.Validation(failureReason: joinedDescriptions)
        }

        return parsed
    }

    // MARK: Internal - Validation Methods

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

    // MARK: Private - Parser Helper Methods

    private class func json(var json: AnyObject?, forKeyPath keypath: String) -> AnyObject {
        if let json = json as? [AnyObject] {
            return json
        }

        var dictionary = json as! [String: AnyObject]

        if dictionary.keys.contains(keypath) {
            json = dictionary[keypath]
        } else {
            let keys = keypath.characters.split() { $0 == "." }.map { String($0) }

            for key in keys {
                dictionary = json as! [String: AnyObject]

                if let value: AnyObject = dictionary[key] {
                    json = value
                } else {
                    json = nil
                    break
                }
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
            let joinedDescriptions = parsingErrorDescriptions.joinWithSeparator("\n")
            throw ParserError.Validation(failureReason: joinedDescriptions)
        }

        return parsed
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
