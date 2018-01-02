//
//  Encodable.swift
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

/// The `Encodable` protocol type declares an interface used to create a JSON `Any` object from the instance.
public protocol Encodable {
    /// Returns the JSON form of the type to be encoded using `JSONSerialization`.
    var json: Any { get }
}

protocol JSONPrimitive: Encodable {}

extension JSONPrimitive {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

// MARK: - String

extension String: JSONPrimitive { }

extension URL: Encodable {
    /// Returns the `absoluteString` of `self` as type `Any`.
    public var json: Any { return absoluteString }
}

// MARK: - Int

extension Int: JSONPrimitive {}
extension Int8: JSONPrimitive {}
extension Int16: JSONPrimitive {}
extension Int32: JSONPrimitive {}
extension Int64: JSONPrimitive {}

// MARK: - UInt

extension UInt: JSONPrimitive {}
extension UInt8: JSONPrimitive {}
extension UInt16: JSONPrimitive {}
extension UInt32: JSONPrimitive {}
extension UInt64: JSONPrimitive {}

// MARK: - Number

extension Float: JSONPrimitive {}
extension Double: JSONPrimitive {}
extension Bool: JSONPrimitive {}

// MARK: - Collection

extension Array where Element: Encodable {
    /// Returns a new `Array` cast to type `Any` with all items encoded to JSON.
    public var json: Any { return map { $0.json } }
}

extension Set where Element: Encodable {
    /// Returns a new `Array` cast to type `Any` with all items encoded to JSON.
    public var json: Any { return map { $0.json } }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Encodable {
    /// Returns a new `Dictionary` cast to type `Any` with all values encoded to JSON.
    public var json: Any {
        guard !isEmpty else { return [:] }

        var json: [String: Any] = [:]
        forEach { json[String(describing: $0.0)] = $0.1.json }

        return json
    }
}
