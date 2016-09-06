//
//  Parser.swift
//
//  Copyright (c) 2015-2016 Nike, Inc. (https://www.nike.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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

        - parameter atKeyPath:  The json key path identifying the object to be parsed. Default is `""`.
        - parameter from:       A Data object containing encoded json data.

        - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
        - returns: The parsed object.
    */
    public class func parseObject<T: Decodable>(atKeyPath keyPath: String = "", from data: Data) throws -> T {
        let properties = try Parser.parseProperties(from: data) { make in
            if T.self == String.self {
                make.property(forKeyPath: keyPath, type: .string)
            } else if T.self == Int.self {
                make.property(forKeyPath: keyPath, type: .int)
            } else if T.self == UInt.self {
                make.property(forKeyPath: keyPath, type: .uint)
            } else if T.self == Float.self {
                make.property(forKeyPath: keyPath, type: .float)
            } else if T.self == Double.self {
                make.property(forKeyPath: keyPath, type: .double)
            } else if T.self == Bool.self {
                make.property(forKeyPath: keyPath, type: .bool)
            } else {
                make.property(forKeyPath: keyPath, type: .dictionary, decodableType: T.self)
            }
        }

        return properties[keyPath] as! T
    }

    /**
        Parses json data at the specified key path into an array of objects of type `T`. `T` must implement the
        `Decodable` protocol.

        - parameter atKeyPath:  The json key path identifying the object to be parsed. Default is `""`.
        - parameter from:       A Data object containing encoded json data.

        - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
        - returns: The parsed array of objects
    */
    public class func parseArray<T: Decodable>(atKeyPath keyPath: String = "", from data: Data) throws -> [T] {
        let properties = try Parser.parseProperties(from: data) { make in
            make.property(forKeyPath: keyPath, type: .array, decodableType: T.self)
        }

        return properties[keyPath] as! [T]
    }

    // MARK: Decoder Parsing Methods

    /**
        Parses json data at the specified key path into an object of type `T` using the passed in `Decoder` instance.

        - parameter atKeyPath:  The json key path identifying the object to be parsed. Default is `""`.
        - parameter from:       A Data object containing encoded json data.
        - parameter with:       The `Decoder` instance used to parse the data.

        - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
        - returns: The parsed object.
    */
    public class func parseObject<T>(atKeyPath keyPath: String = "", from data: Data, with decoder: Decoder) throws -> T {
        let result = try Parser.parseProperties(from: data) { make in
            make.property(forKeyPath: keyPath, type: .dictionary, decoder: decoder)
        }

        return result[keyPath] as! T
    }

    /**
        Parses json data at the specified key path into an array of objects of type `T` using the passed in `Decoder`
        instance.

        - parameter atKeyPath:  The json key path identifying the object to be parsed. Default is `""`.
        - parameter from:       A Data object containing encoded json data.
        - parameter with:       The `Decoder` instance used to parse the data.

        - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
        - returns: The parsed array of objects.
    */
    public class func parseArray<T>(atKeyPath keyPath: String = "", from data: Data, with decoder: Decoder) throws -> [T] {
        let result = try Parser.parseProperties(from: data) { make in
            make.property(forKeyPath: keyPath, type: .array, decoder: decoder)
        }

        return result[keyPath] as! [T]
    }

    // MARK: Property Parsing Methods

    /**
        Performs the work of validating and extracting values from the passed in Data, Dictionary or Array object. The 
        type of the object passed in must be Data, [String: Any] or [Any]. Values in the Dictionary must be
        `JSONSerialization` compatible. If the json parameter is an Array, use an empty string for the property key path.

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

        - parameter data:    A Data object containing encoded json data.
        - parameter closure: Defines the property list for the parser via the passed in `ParserPropertyMaker` instance.

        - returns: The result Dictionary.
    */
    public class func parseProperties(
        from json: Any,
        using closure: (ParserPropertyMaker) -> Void)
        throws -> [String: Any]
    {
        if let data = json as? Data {
            let result: [String: Any]

            do {
                let options = JSONSerialization.ReadingOptions(rawValue: 0)
                let json = try JSONSerialization.jsonObject(with: data, options: options)

                result = try parseProperties(from: json, using: closure)
            } catch {
                if error is ParserError {
                    throw error
                } else {
                    let error = error as NSError

                    throw ParserError.deserialization(
                        failureReason: "JSON data deserialization failed with error: \"\(error.description)\""
                    )
                }
            }

            return result
        } else if let json = json as? [String: Any] {
            return try parsePropertiesFromDictionary(json, using: closure)
        } else if let json = json as? [Any] {
            return try parsePropertiesFromArray(json, using: closure)
        } else {
            throw ParserError.validation(
                failureReason: "JSON object was not of type: Data, [String: Any] or [Any]"
            )
        }
    }

    private class func parsePropertiesFromDictionary(
        _ dictionary: [String: Any],
        using closure: (ParserPropertyMaker) -> Void)
        throws -> [String: Any]
    {
        var parsingErrorDescriptions = [String]()
        var parsed = [String: Any]()
        let propertyMaker = ParserPropertyMaker()

        closure(propertyMaker)

        for property in propertyMaker.properties {
            let jsonValue: Any = Parser.json(from: dictionary, withKeyPath: property.keyPath)
            var parsedValue: Any?

            if property.optional && jsonValue is NSNull {
                parsedValue = Optional.none
            } else if let errorDescription = validateValue(jsonValue, forProperty: property) {
                parsingErrorDescriptions.append(errorDescription)
            } else {
                switch property.type {
                case .string:
                    parsedValue = jsonValue
                    parsed[property.keyPath] = jsonValue
                case .uint:
                    parsedValue = (jsonValue as! NSNumber).uintValue as Any
                    parsed[property.keyPath] = parsedValue
                case .int:
                    parsedValue = (jsonValue as! NSNumber).intValue as Any
                    parsed[property.keyPath] = parsedValue
                case .float:
                    parsedValue = (jsonValue as! NSNumber).floatValue as Any
                    parsed[property.keyPath] = parsedValue
                case .double:
                    parsedValue = (jsonValue as! NSNumber).doubleValue as Any
                    parsed[property.keyPath] = parsedValue
                case .bool:
                    parsedValue = (jsonValue as! NSNumber).boolValue as Any
                    parsed[property.keyPath] = parsedValue
                case .array:
                    if let decodingMethod = property.decodingMethod {
                        do {
                            let result = try parseArray(from: jsonValue, using: decodingMethod)
                            parsed[property.keyPath] = result
                        } catch ParserError.validation(let failureReason) {
                            parsingErrorDescriptions.append(failureReason)
                        }
                    } else {
                        parsingErrorDescriptions.append("A decoding method was not provided for `\(property.keyPath)` array")
                    }
                case .dictionary:
                    parsedValue = jsonValue
                    parsed[property.keyPath] = jsonValue
                case .url:
                    let url = URL(string: jsonValue as! String)
                    if url == nil && !property.optional {
                        let description = "Required key path [\(property.keyPath)] could not be parsed to valid URL"
                        parsingErrorDescriptions.append(description)
                    } else {
                        parsedValue = url as Any?
                        parsed[property.keyPath] = url
                    }
                }

                if let decodingMethod = property.decodingMethod {
                    if let value: Any = parsedValue {
                        do {
                            let result: Any

                            switch decodingMethod {
                            case .useDecoder(let decoder):
                                result = try decoder.decode(value)
                            case .useDecodable(let decodableType):
                                result = try decodableType.init(json: value)
                            }

                            parsed[property.keyPath] = result
                        } catch ParserError.validation(let failureReason) {
                            parsingErrorDescriptions.append(failureReason)
                        }
                    }
                }
            }
        }

        guard parsingErrorDescriptions.isEmpty else {
            let joinedDescriptions = parsingErrorDescriptions.joined(separator: "\n")
            throw ParserError.validation(failureReason: joinedDescriptions)
        }

        return parsed
    }

    private class func parsePropertiesFromArray(
        _ array: [Any],
        using closure: (ParserPropertyMaker) -> Void)
        throws -> [String: Any]
    {
        var parsed = [String: Any]()
        let propertyMaker = ParserPropertyMaker()

        closure(propertyMaker)

        guard propertyMaker.properties.count == 1 && propertyMaker.properties.first?.type == .array else {
            throw ParserError.validation(failureReason: "Invalid property list for json array.")
        }

        let property = propertyMaker.properties.first!
        let jsonValue: Any = array as Any

        if let decodingMethod = property.decodingMethod {
            let result = try parseArray(from: jsonValue, using: decodingMethod)
            parsed[property.keyPath] = result
        } else {
            throw ParserError.validation(
                failureReason: "A decoding method was not provided for `\(property.keyPath)` array"
            )
        }

        return parsed
    }

    // MARK: Internal - Validation Methods

    class func isJSON(_ json: Any, ofType type: ParserPropertyType) -> Bool {
        var isValid = false

        switch json {
        case let number as NSNumber:
            if number.isBool && type == .bool {
                isValid = true
            } else {
                switch type {
                case .int, .uint, .double, .float:
                    isValid = true
                default:
                    isValid = false
                }
            }
        case is NSString:
            isValid = type == .string || type == .url
        case is [Any]:
            isValid = type == .array
        case is [String: Any]:
            isValid = type == .dictionary
        default:
            break
        }

        return isValid
    }

    // MARK: Private - Parser Helper Methods

    private class func json(from dictionary: [String: Any], withKeyPath keyPath: String) -> Any {
        var json: Any? = dictionary as Any

        if let value = dictionary[keyPath] {
            json = value
        } else {
            let keys = keyPath.components(separatedBy: ".")

            for key in keys {
                if let dictionary = json as? [String: Any], let value: Any = dictionary[key] {
                    json = value
                } else {
                    json = nil
                    break
                }
            }
        }

        return json ?? NSNull()
    }

    private class func validateValue(_ value: Any, forProperty property: ParserProperty) -> String?  {
        var errorDescription: String? = nil

        if property.optional == false && value is NSNull {
            errorDescription = "Required key path [\(property.keyPath)] was missing or null"
        } else if property.optional == true && value is NSNull {
            return nil
        } else {
            if !isJSON(value, ofType: property.type) {
                errorDescription = "Value for key path [\(property.keyPath)] is of incorrect type"
            }
        }

        return errorDescription
    }

    private class func parseArray(
        from data: Any,
        using decodingMethod: ParserProperty.DecodingMethod)
        throws -> [Any]
    {
        var parsed = [Any]()
        var parsingErrorDescriptions = [String]()

        if let items = data as? [Any] {
            for (index, item) in items.enumerated() {
                do {
                    let result: Any

                    switch decodingMethod {
                    case .useDecoder(let decoder):
                        result = try decoder.decode(item)
                    case .useDecodable(let decodableType):
                        result = try decodableType.init(json: item)
                    }

                    parsed.append(result)
                } catch ParserError.validation(let failureReason) {
                    let decodingObject: Any

                    switch decodingMethod {
                    case .useDecoder(let decoder):
                        decodingObject = decoder
                    case .useDecodable(let decodableType):
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
            let joinedDescriptions = parsingErrorDescriptions.joined(separator: "\n")
            throw ParserError.validation(failureReason: joinedDescriptions)
        }

        return parsed
    }
}

// MARK: -

extension NSNumber {
    var isBool: Bool {
        let isTrue = self == NSNumber(value: true)
        let isFalse = self == NSNumber(value: false)
        let isBoolType = String(cString: self.objCType) == "c"

        return (isTrue || isFalse) && isBoolType
    }
}
