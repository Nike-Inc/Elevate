//
//  Elevate.swift
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

// MARK: Decodable Parsing Methods

/**
 Parses json data at the specified key path into an object of type `T`. `T` must implement the `Decodable` protocol.

 - parameter data:       A Data object containing encoded json data.
 - parameter forKeyPath: The json key path identifying the object to be parsed. Default is `""`.

 - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
 - returns: The parsed object.
 */
public func decodeObject<T: Decodable>(from data: Data, atKeyPath keyPath: String = "") throws -> T {
    let entity = try Parser.parseEntity(data: data) { schema in
        if T.self == String.self {
            schema.addProperty(keyPath: keyPath, type: .string)
        } else if T.self == Int.self {
            schema.addProperty(keyPath: keyPath, type: .int)
        } else if T.self == UInt.self {
            schema.addProperty(keyPath: keyPath, type: .uint)
        } else if T.self == Float.self {
            schema.addProperty(keyPath: keyPath, type: .float)
        } else if T.self == Double.self {
            schema.addProperty(keyPath: keyPath, type: .double)
        } else if T.self == Bool.self {
            schema.addProperty(keyPath: keyPath, type: .bool)
        } else {
            schema.addProperty(keyPath: keyPath, type: .dictionary, decodableType: T.self)
        }
    }

    return entity[keyPath] as! T
}

/**
 Parses json data at the specified key path into an array of objects of type `T`. `T` must implement the
 `Decodable` protocol.

 - parameter data:       A Data object containing encoded json data.
 - parameter forKeyPath: The json key path identifying the object to be parsed. Default is `""`.

 - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
 - returns: The parsed array of objects
 */
public func decodeArray<T: Decodable>(from data: Data, atKeyPath keyPath: String = "") throws -> [T] {
    let entity = try Parser.parseEntity(data: data) { schema in
        schema.addProperty(keyPath: keyPath, type: .array, decodableType: T.self)
    }

    return entity[keyPath] as! [T]
}

// MARK: Decoder Parsing Methods

/**
 Parses json data at the specified key path into an object of type `T` using the passed in `Decoder` instance.

 - parameter data:        A Data object containing encoded json data.
 - parameter forKeyPath:  The json key path identifying the object to be parsed. Default is `""`.
 - parameter with:        The `Decoder` instance used to parse the data.

 - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
 - returns: The parsed object.
 */
public func decodeObject<T>(from data: Data, atKeyPath keyPath: String = "", with decoder: Decoder) throws -> T {
    let result = try Parser.parseEntity(data: data) { schema in
        schema.addProperty(keyPath: keyPath, type: .dictionary, decoder: decoder)
    }

    return result[keyPath] as! T
}

/**
 Parses json data at the specified key path into an array of objects of type `T` using the passed in `Decoder`
 instance.

 - parameter data:        A Data object containing encoded json data.
 - parameter forKeyPath:  The json key path identifying the object to be parsed. Default is `""`.
 - parameter with:        The `Decoder` instance used to parse the data.

 - throws:  A ParserError.Deserialization and ParserError.Validation error if parsing fails.
 - returns: The parsed array of objects.
 */
public func decodeArray<T>(from data: Data, atKeyPath keyPath: String = "", with decoder: Decoder) throws -> [T] {
    let result = try Parser.parseEntity(data: data) { schema in
        schema.addProperty(keyPath: keyPath, type: .array, decoder: decoder)
    }

    return result[keyPath] as! [T]
}
