//
//  Encodable.swift
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

/// The `Decodable` protocol type declares an interface used to create a JSON `Any` object from the instance.
public protocol Encodable {
    /// Returns the JSON form of the type to be encoded using `JSONSerialization`.
    var json: Any { get }
}

// MARK: - String

extension String: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension URL: Encodable {
    /// Returns the `absoluteString` of `self` as type `Any`.
    public var json: Any { return absoluteString }
}

// MARK: - Int

extension Int: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension Int8: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension Int16: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension Int32: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension Int64: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

// MARK: - UInt

extension UInt: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension UInt8: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension UInt16: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension UInt32: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension UInt64: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

// MARK: - Number

extension Float: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension Double: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

extension Bool: Encodable {
    /// Returns `self` as type `Any`.
    public var json: Any { return self }
}

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
