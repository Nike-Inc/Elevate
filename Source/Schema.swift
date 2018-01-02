//
//  Schema.swift
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

/// Defines a Swift object type used to extract values from a JSON document.
///
/// - string:     Represents a Swift `String` type.
/// - uint:       Represents a Swift `UInt` type.
/// - int:        Represents a Swift `Int` type.
/// - float:      Represents a Swift `Float` type.
/// - double:     Represents a Swift `Double` type.
/// - bool:       Represents a Swift `Bool` type.
/// - array:      Represents a Swift `Array` type.
/// - dictionary: Represents a Swift `Dictionary` type.
/// - url:        Represents a Swift `URL` type.
public enum SchemaPropertyProtocol {
    case string
    case uint
    case int
    case float
    case double
    case bool
    case array
    case dictionary
    case url
}

/// Represents a schema property and all its internal characteristics.
public struct SchemaProperty {
    enum DecodingMethod {
        case useDecoder(Decoder)
        case useDecodable(Decodable.Type)
    }

    let type: SchemaPropertyProtocol
    let keyPath: String
    let optional: Bool
    let decodingMethod: DecodingMethod?

    init(type: SchemaPropertyProtocol, keyPath: String, optional: Bool, decodingMethod: DecodingMethod?) {
        self.type = type
        self.keyPath = keyPath
        self.optional = optional
        self.decodingMethod = decodingMethod
    }
}

// MARK: -

/// Defines the list of properties to be validated and extracted from a object. If a property is not defined in the
/// schema but is present in the JSON data, it will be ignored.
public class Schema {
    var properties = [SchemaProperty]()

    /// Creates, adds and returns a property for the specified key path, type and optionality.
    ///
    /// NOTE: Compound key paths may be used (e.g. `address.city`). Each property name in the key path MUST be
    /// separated by a `.` character.
    ///
    /// - Parameters:
    ///   - keyPath:  Key path for property.
    ///   - type:     Swift object type to be validated and extracted.
    ///   - optional: Specifies whether the keyPath is optional. `false` by default.
    ///
    /// - Returns: The created schema property.
    @discardableResult
    public func addProperty(keyPath: String, type: SchemaPropertyProtocol, optional: Bool = false) -> SchemaProperty {
        return addProperty(keyPath: keyPath, type: type, optional: optional, decodingMethod: nil)
    }

    /// Creates, adds and returns a property for the specified key path, type, optionality and decodable type.
    ///
    /// NOTE: Compound key paths may be used (e.g. `address.city`). Each property name in the key path MUST be
    /// separated by a `.` character.
    ///
    /// - Parameters:
    ///   - keyPath:       Key path for property.
    ///   - type:          Swift object type to be validated and extracted.
    ///   - optional:      Specifies if the keyPath is optional. `false` by default.
    ///   - decodableType: The `Decodable` type associated to the property. `nil` by default.
    ///
    /// - Returns: The created schema property.
    @discardableResult
    public func addProperty(
        keyPath: String,
        type: SchemaPropertyProtocol,
        optional: Bool = false,
        decodableType: Decodable.Type?)
        -> SchemaProperty
    {
        var decodingMethod: SchemaProperty.DecodingMethod?

        if let decodableType = decodableType {
            decodingMethod = SchemaProperty.DecodingMethod.useDecodable(decodableType)
        }

        return addProperty(keyPath: keyPath, type: type, optional: optional, decodingMethod: decodingMethod)
    }

    /// Creates, adds and returns a property for the specified key path, type, optionality and decoder.
    ///
    /// NOTE: Compound key paths may be used (e.g. `address.city`). Each property name in the key path MUST be
    /// separated by a `.` character.
    ///
    /// - Parameters:
    ///   - keyPath:  Key path for property.
    ///   - type:     Swift object type to be validated and extracted.
    ///   - optional: Specifies if the keyPath is optional. `false` by default.
    ///   - decoder:  The `Decoder` associated to the property. `nil` by default.
    ///
    /// - Returns: The created schema property.
    @discardableResult
    public func addProperty(
        keyPath: String,
        type: SchemaPropertyProtocol,
        optional: Bool = false,
        decoder: Decoder?)
        -> SchemaProperty
    {
        var decodingMethod: SchemaProperty.DecodingMethod?

        if let decoder = decoder {
            decodingMethod = SchemaProperty.DecodingMethod.useDecoder(decoder)
        }

        return addProperty(keyPath: keyPath, type: type, optional: optional, decodingMethod: decodingMethod)
    }

    func addProperty(
        keyPath: String,
        type: SchemaPropertyProtocol,
        optional: Bool,
        decodingMethod: SchemaProperty.DecodingMethod?)
        -> SchemaProperty
    {
        let property = SchemaProperty(type: type, keyPath: keyPath, optional: optional, decodingMethod: decodingMethod)
        self.properties.append(property)

        return property
    }
}
