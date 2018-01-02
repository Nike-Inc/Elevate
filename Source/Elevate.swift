//
//  Elevate.swift
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

// MARK: Decodable Methods

/// Decodes json data at the specified key path into an object of type `T`.
///
/// `T` must implement the `Decodable` protocol.
///
/// - Parameters:
///   - data:    The json data.
///   - keyPath: The key path identifying the object to be decoded. `""` by default.
///
/// - Returns: The decoded object of type `T`.
///
/// - Throws:  A `ParserError` if decoding fails.
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

/// Decodes json data at the specified key path into an array of objects of type `T`.
///
/// `T` must implement the `Decodable` protocol.
///
/// - Parameters:
///   - data:    The json data.
///   - keyPath: The key path identifying the object to be decoded. Default is `""`.
///
/// - Returns: The decoded array of objects.
///
/// - throws: A `ParserError` if decoding fails.
public func decodeArray<T: Decodable>(from data: Data, atKeyPath keyPath: String = "") throws -> [T] {
    let entity = try Parser.parseEntity(data: data) { schema in
        schema.addProperty(keyPath: keyPath, type: .array, decodableType: T.self)
    }

    return entity[keyPath] as! [T]
}

// MARK: Decoder Methods

/// Decodes json data at the specified key path into an object of type `T` using the specified decoder.
///
/// - Parameters:
///   - data:    The json data.
///   - keyPath: The key path identifying the object to be decoded. `""` by default.
///   - decoder: The decoder to use to decode the data.
///
/// - Returns: The decoded object.
///
/// - throws: A `ParserError` if decoding fails.
public func decodeObject<T>(from data: Data, atKeyPath keyPath: String = "", with decoder: Decoder) throws -> T {
    let result = try Parser.parseEntity(data: data) { schema in
        schema.addProperty(keyPath: keyPath, type: .dictionary, decoder: decoder)
    }

    return result[keyPath] as! T
}

/// Decodes json data at the specified key path into an array of objects of type `T` using the specified decoder.
///
/// - Parameters:
///   - data:    The json data.
///   - keyPath: The key path identifying the object to be decoded. `""` by default.
///   - decoder: The decoder to use to decode the data.
///
/// - Returns: The decoded array of objects.
///
/// - throws: A `ParserError` if decoding fails.
public func decodeArray<T>(from data: Data, atKeyPath keyPath: String = "", with decoder: Decoder) throws -> [T] {
    let result = try Parser.parseEntity(data: data) { schema in
        schema.addProperty(keyPath: keyPath, type: .array, decoder: decoder)
    }

    return result[keyPath] as! [T]
}
