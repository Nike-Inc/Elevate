//
//  Decodable.swift
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

// MARK: Decodable Protocol Definition

/// The `Decodable` protocol declares an interface used to create an instance of an object from an `Any` to be parsed.
public protocol Decodable {
    /// Creates an instance of the object using the specified json object.
    ///
    /// - Parameter json: The json object to be decoded.
    ///
    /// - Throws: A `ParserError` if decoding fails.
    init(json: Any) throws
}

// MARK: - Primitive Decodables

/// The primitive decodables implemented below are used by the parser when parsing an array of primitive values. The
/// input is expected to be of the same type as the object and will be validated and cast as such.
extension String: Decodable {
    /// Creates a `String` instance from the json object expected to be of type `String`.
    ///
    /// - Parameter json: The json object to decode.
    ///
    /// - Throws: A `ParserError.validation` error if decoding fails.
    public init(json: Any) throws {
        guard Parser.isValue(json, ofType: .string) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: String")
        }

        self = json as! String
    }
}

extension Int: Decodable {
    /// Creates a `Int` instance from the json object expected to be of type `Int`.
    ///
    /// - Parameter json: The json object to decode.
    ///
    /// - Throws: A `ParserError.validation` error if decoding fails.
    public init(json: Any) throws {
        guard Parser.isValue(json, ofType: .int) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: Int")
        }

        self = json as! Int
    }
}

extension UInt: Decodable {
    /// Creates a `UInt` instance from the json object expected to be of type `UInt`.
    ///
    /// - Parameter json: The json object to decode.
    ///
    /// - Throws: A `ParserError.validation` error if decoding fails.
    public init(json: Any) throws {
        guard Parser.isValue(json, ofType: .uint) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: UInt")
        }

        self = json as! UInt
    }
}

extension Float: Decodable {
    /// Creates a `Float` instance from the json object expected to be of type `Float`.
    ///
    /// - Parameter json: The json object to decode.
    ///
    /// - Throws: A `ParserError.validation` error if decoding fails.
    public init(json: Any) throws {
        guard Parser.isValue(json, ofType: .float), let number = json as? NSNumber else {
            throw ParserError.validation(failureReason: "JSON object was not of type: Float")
        }

        self = number.floatValue
    }
}

extension Double: Decodable {
    /// Creates a `Double` instance from the json object expected to be of type `Double`.
    ///
    /// - Parameter json: The json object to decode.
    ///
    /// - Throws: A `ParserError.validation` error if decoding fails.
    public init(json: Any) throws {
        guard Parser.isValue(json, ofType: .double), let number = json as? NSNumber else {
            throw ParserError.validation(failureReason: "JSON object was not of type: Double")
        }

        self = number.doubleValue
    }
}

extension Bool: Decodable {
    /// Creates a `Bool` instance from the json object expected to be of type `Bool`.
    ///
    /// - Parameter json: The json object to decode.
    ///
    /// - Throws: A `ParserError.validation` error if decoding fails.
    public init(json: Any) throws {
        guard Parser.isValue(json, ofType: .bool) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: Bool")
        }

        self = json as! Bool
    }
}

extension Dictionary: Decodable {
    /// Creates a `Dictionary` instance from the json object expected to be of type `[Key: Value]`.
    ///
    /// - Parameter json: The json object to decode.
    ///
    /// - Throws: A `ParserError.validation` error if decoding fails.
    public init(json: Any) throws {
        guard json is [Key: Value] else {
            throw ParserError.validation(failureReason: "JSON object was not of type: \(Dictionary<Key, Value>.self)")
        }

        self = json as! [Key: Value]
    }
}
