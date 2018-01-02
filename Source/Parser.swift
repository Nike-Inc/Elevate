//
//  Parser.swift
//
//  Copyright (c) 2015-present Nike, Inc. (https://www.nike.com)
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

/// The `Parser` validates and extracts values from json data by allowing you to define the type and optionality
/// for each property to be parsed. All parser errors encountered are aggregated when evaluating the data.
public class Parser {

    // MARK: Property Parsing Methods

    /// Performs the work of validating and extracting values from the passed in Data object. The Data object must
    /// contain json that can be deserialized by `JSONSerialization.jsonObject`. Fragments are not allowed.
    ///
    /// Returns resulting Dictionary object containing all property values matching the `Schema` as defined in the
    /// closure. The property keyPath is the key and the extracted object is the value. The value is guaranteed to be an
    /// object of the type defined by the property and can be cast to that type directly, without further checks. Custom
    /// extraction operators are provided for convenience.
    ///
    /// - Parameters:
    ///   - data:    The json data.
    ///   - closure: Defines the property list for the parser via the passed in `Schema` instance.
    ///
    /// - Returns: The parsed entity as a Dictionary.
    ///
    /// - Throws: `ParserError` types for parsing related errors or custom `Error` types from `Decodable` and
    ///           `Decoder` implementations.
    public class func parseEntity(data: Data, closure: (Schema) -> Void) throws -> [String: Any] {
        let result: [String: Any]
        let json: Any

        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            let error = error as NSError
            let failureReason = "JSON data deserialization failed with error: \"\(error.description)\""

            throw ParserError.deserialization(failureReason: failureReason)
        }

        result = try parseEntity(json: json, closure: closure)

        return result
    }

    /// Performs the work of validating and extracting values from the passed in Dictionary or Array object. The type of
    /// the object passed in must be [String: Any] or [Any]. Values in the Dictionary must be `JSONSerialization`
    /// compatible. If the json parameter is an Array, use an empty string for the property key path.
    ///
    /// Defining the property list to be parsed is achieved using a maker pattern via the `Schema` object passed into
    /// the trailing closure. Inside the closure, for each property, call the `addProperty` instance method.
    ///
    /// The parser will evaluate each property using the following steps:
    ///
    /// 1) Extract the object for the given keyPath
    /// 2) Validate the value type and optionality
    /// 3) Extract the value in the specified type
    /// 4) Optionally, run the `Decoder` on the value or on each item in an array
    ///
    /// The resulting Dictionary contains all property values matching the `Schema` as defined in the closure. The
    /// property keyPath is the key and the extracted object is the value. The value is guaranteed to be an object of
    /// the type defined by the property and can be cast to that type directly, without further checks. Custom
    /// extraction operators are provided for convenience.
    ///
    /// See the README for code samples and best practices for creating re-usable `Decoder`s.
    ///
    /// - Parameters:
    ///   - json:    The json object.
    ///   - closure: Defines the property list for the parser via the passed in `ParserPropertyMaker` instance.
    ///
    /// - Returns: The parsed entity as a Dictionary.
    public class func parseEntity(json: Any, closure: (Schema) -> Void) throws -> [String: Any] {
        if let json = json as? [String: Any] {
            return try parseEntity(fromJSON: json, closure: closure)
        } else if let json = json as? [Any] {
            return try parseEntity(fromJSONArray: json, closure: closure)
        } else {
            throw ParserError.validation(failureReason: "JSON object was not of type: [String: Any] or [Any]")
        }
    }

    private class func parseEntity(fromJSON json: [String: Any], closure: (Schema) -> Void) throws -> [String: Any] {
        var parsingErrorDescriptions = [String]()
        var parsed = [String: Any]()
        let propertyMaker = Schema()

        closure(propertyMaker)

        for property in propertyMaker.properties {
            let jsonValue = Parser.json(json, forKeyPath: property.keyPath)
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
                    parsedValue = (jsonValue as! NSNumber).uintValue
                    parsed[property.keyPath] = parsedValue
                case .int:
                    parsedValue = (jsonValue as! NSNumber).intValue
                    parsed[property.keyPath] = parsedValue
                case .float:
                    parsedValue = (jsonValue as! NSNumber).floatValue
                    parsed[property.keyPath] = parsedValue
                case .double:
                    parsedValue = (jsonValue as! NSNumber).doubleValue
                    parsed[property.keyPath] = parsedValue
                case .bool:
                    parsedValue = (jsonValue as! NSNumber).boolValue
                    parsed[property.keyPath] = parsedValue
                case .array:
                    if let decodingMethod = property.decodingMethod {
                        do {
                            let result = try parseArray(data: jsonValue, decodingMethod: decodingMethod)
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

    private class func parseEntity(fromJSONArray json: [Any], closure: (Schema) -> Void) throws -> [String: Any] {
        var parsed = [String: Any]()
        let propertyMaker = Schema()

        closure(propertyMaker)

        guard propertyMaker.properties.count == 1 && propertyMaker.properties.first?.type == .array else {
            throw ParserError.validation(failureReason: "Invalid property list for json array.")
        }

        let property = propertyMaker.properties.first!
        let jsonValue = json as Any

        if let decodingMethod = property.decodingMethod {
            let result = try parseArray(data: jsonValue, decodingMethod: decodingMethod)
            parsed[property.keyPath] = result
        } else {
            throw ParserError.validation(failureReason: "A decoding method was not provided for `\(property.keyPath)` array")
        }

        return parsed
    }

    // MARK: Internal - Validation Methods

    class func isValue(_ value: Any, ofType type: SchemaPropertyProtocol) -> Bool {
        var isValid = false

        switch value {
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

    private class func json(_ dictionary: [String: Any], forKeyPath keypath: String) -> Any {
        var json: Any? = dictionary as Any

        if !keypath.isEmpty {
            if let value = dictionary[keypath] {
                json = value
            } else {
                let keys = keypath.components(separatedBy: ".")
                
                for key in keys {
                    if let dictionary = json as? [String: Any], let value: Any = dictionary[key] {
                        json = value
                    } else {
                        json = nil
                        break
                    }
                }
            }
        }

        return json ?? NSNull()
    }

    private class func validateValue(_ value: Any, forProperty property: SchemaProperty) -> String?  {
        var errorDescription: String? = nil

        if property.optional == false && value is NSNull {
            errorDescription = "Required key path [\(property.keyPath)] was missing or null"
        } else if property.optional == true && value is NSNull {
            return nil
        } else {
            if !isValue(value, ofType: property.type) {
                errorDescription = "Value for key path [\(property.keyPath)] is of incorrect type"
            }
        }

        return errorDescription
    }

    private class func parseArray(data: Any, decodingMethod: SchemaProperty.DecodingMethod) throws -> [Any] {
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
