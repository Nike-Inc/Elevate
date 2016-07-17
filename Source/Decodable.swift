//
//  Decodable.swift
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

// MARK: Decodable Protocol Definition

/**
    The `Decodable` protocol declares an interface used to create an instance of an object from an `AnyObject` to be
    parsed.
*/
public protocol Decodable {
    /**
        Initializes an instance of the object using the given json object.

        - parameter json: The data to be parsed.

        - throws: A ParserError.Validation or ParserError.Deserialization if decoding fails.
    */
    init(json: AnyObject) throws
}

// MARK: - Primative Decodables

/**
    The primative decodables implemented below are used by the parser when parsing an array of primative values. The
    input is expected to be of the same type as the object and will be validated and cast as such.
*/

extension String: Decodable {
    /**
        Implements the `Decodable` protocol for the `String` type. Expects input to be a `String`.

        - parameter json: A `String` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .string) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: String")
        }

        self = json as! String
    }
}

extension Int: Decodable {
    /**
        Implements the `Decodable` protocol for the `Int` type. Expects input to be an `Int`.

        - parameter json: An `Int` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .int) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: Int")
        }

        self = (json as! NSNumber).intValue
    }
}

extension UInt: Decodable {
    /**
        Implements the `Decodable` protocol for the `UInt` type. Expects input to be a `UInt`.

        - parameter json: A `UInt` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .uInt) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: UInt")
        }

        self = (json as! NSNumber).uintValue
    }
}

extension Float: Decodable {
    /**
        Implements the `Decodable` protocol for the `Float` type. Expects input to be a `Float`.

        - parameter json: A `Float` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .float) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: Float")
        }

        self = (json as! NSNumber).floatValue
    }
}

extension Double: Decodable {
    /**
        Implements the `Decodable` protocol for the `Double` type. Expects input to be a `Double`.

        - parameter json: A `Double` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .double) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: Double")
        }

        self = (json as! NSNumber).doubleValue
    }
}

extension Bool: Decodable {
    /**
        Implements the `Decodable` protocol for the `Bool` type. Expects input to be a `Bool`.

        - parameter json: A `Bool` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .bool) else {
            throw ParserError.validation(failureReason: "JSON object was not of type: Bool")
        }

        self = (json as! NSNumber).boolValue
    }
}
