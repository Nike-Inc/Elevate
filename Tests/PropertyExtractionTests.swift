//
//  PropertyExtractionTests.swift
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

import Elevate
import Foundation
import XCTest

class PropertyExtractionTestCase: BaseTestCase {

    // MARK: - Properties

    let properties: [String: Any] = [
        "string": "string_value",
        "int": Int(-10),
        "uint": UInt(45),
        "float": Float(12.34),
        "double": Double(1234.5678),
        "bool": true,
        "array": ["value_0", "value_1"],
        "array_of_any_values": ["value_0" as Any, "value_1" as Any],
        "dictionary": ["key": "value"],
        "url": URL(string: "https://httpbin.org/get")!
    ]

    // MARK: - Tests - Operators

    func testValueForKeyPathOperator() {
        // Given, When
        let stringValue: String = properties <-! "string"
        let intValue: Int = properties <-! "int"
        let uintValue: UInt = properties <-! "uint"
        let floatValue: Float = properties <-! "float"
        let doubleValue: Double = properties <-! "double"
        let boolValue: Bool = properties <-! "bool"
        let arrayValue: [String] = properties <-! "array"
        let dictionaryValue: [String: String] = properties <-! "dictionary"
        let urlValue: URL = properties <-! "url"

        // Then
        XCTAssertEqual(stringValue, "string_value")
        XCTAssertEqual(intValue, -10)
        XCTAssertEqual(uintValue, 45)
        XCTAssertEqual(floatValue, 12.34)
        XCTAssertEqual(doubleValue, 1234.5678)
        XCTAssertEqual(boolValue, true)
        XCTAssertEqual(arrayValue, ["value_0", "value_1"])
        XCTAssertEqual(dictionaryValue, ["key": "value"])
        XCTAssertEqual(urlValue, URL(string: "https://httpbin.org/get")!)
    }

    func testOptionalValueForKeyPathOperator() {
        // Given, When
        let stringValue: String? = properties <-? "string"
        let stringNilValue: String? = properties <-? "string_nil"

        let intValue: Int? = properties <-? "int"
        let intNilValue: Int? = properties <-? "int_nil"

        let uintValue: UInt? = properties <-? "uint"
        let uintNilValue: UInt? = properties <-? "uint_nil"

        let floatValue: Float? = properties <-? "float"
        let floatNilValue: Float? = properties <-? "float_nil"

        let doubleValue: Double? = properties <-? "double"
        let doubleNilValue: Double? = properties <-? "double_nil"

        let boolValue: Bool? = properties <-? "bool"
        let boolNilValue: Bool? = properties <-? "bool_nil"

        let arrayValue: [String]? = properties <-? "array"
        let arrayNilValue: [String]? = properties <-? "array_nil"

        let dictionaryValue: [String: String]? = properties <-? "dictionary"
        let dictionaryNilValue: [String: String]? = properties <-? "dictionary_nil"

        let urlValue: URL? = properties <-? "url"
        let urlNilValue: URL? = properties <-? "url_nil"

        // Then
        XCTAssertEqual(stringValue, "string_value")
        XCTAssertNil(stringNilValue)

        XCTAssertEqual(intValue, -10)
        XCTAssertNil(intNilValue)

        XCTAssertEqual(uintValue, 45)
        XCTAssertNil(uintNilValue)

        XCTAssertEqual(floatValue, 12.34)
        XCTAssertNil(floatNilValue)

        XCTAssertEqual(doubleValue, 1234.5678)
        XCTAssertNil(doubleNilValue)

        XCTAssertEqual(boolValue, true)
        XCTAssertNil(boolNilValue)

        XCTAssertEqual(arrayValue ?? [], ["value_0", "value_1"])
        XCTAssertNil(arrayNilValue)

        XCTAssertEqual(dictionaryValue ?? [:], ["key": "value"])
        XCTAssertNil(dictionaryNilValue)

        XCTAssertEqual(urlValue, URL(string: "https://httpbin.org/get")!)
        XCTAssertNil(urlNilValue)
    }

    func testArrayForKeyPathOperator() {
        // Given, When
        let anyArray: [String] = properties <--! "array_of_any_values"

        // Then
        XCTAssertEqual(anyArray, ["value_0", "value_1"])
    }

    func testOptionalArrayForKeyPathOperator() {
        // Given, When
        let stringsArray: [String]? = properties <--? "array"
        let anyArray: [String]? = properties <--? "array_of_any_values"
        let missingKey: [String]? = properties <--? "key_does_not_exist"

        // Then
        XCTAssertNil(stringsArray)
        XCTAssertEqual(anyArray ?? [], ["value_0", "value_1"])
        XCTAssertNil(missingKey)
    }
}
