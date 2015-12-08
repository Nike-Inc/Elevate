//
//  PropertyExtractionTests.swift
//  Elevate
//
//  Created by Christian Noon on 12/7/15.
//  Copyright © 2015 Nike. All rights reserved.
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
        "url": NSURL(string: "https://httpbin.org/get")!
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
        let urlValue: NSURL = properties <-! "url"

        // Then
        XCTAssertEqual(stringValue, "string_value")
        XCTAssertEqual(intValue, -10)
        XCTAssertEqual(uintValue, 45)
        XCTAssertEqual(floatValue, 12.34)
        XCTAssertEqual(doubleValue, 1234.5678)
        XCTAssertEqual(boolValue, true)
        XCTAssertEqual(arrayValue, ["value_0", "value_1"])
        XCTAssertEqual(dictionaryValue, ["key": "value"])
        XCTAssertEqual(urlValue, NSURL(string: "https://httpbin.org/get")!)
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

        let urlValue: NSURL? = properties <-? "url"
        let urlNilValue: NSURL? = properties <-? "url_nil"

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

        XCTAssertEqual(urlValue, NSURL(string: "https://httpbin.org/get")!)
        XCTAssertNil(urlNilValue)
    }

    func testArrayForKeyPathOperator() {
        // Given, When
        let stringsArray: [String] = properties <-- "array_of_any_values"

        // Then
        XCTAssertEqual(stringsArray, ["value_0", "value_1"])
    }

    // MARK: - Tests - CollectionType Extension

    func testValueForKeyPath() {
        // Given, When
        let stringValue: String = properties.valueForKeyPath("string")
        let intValue: Int = properties.valueForKeyPath("int")
        let uintValue: UInt = properties.valueForKeyPath("uint")
        let floatValue: Float = properties.valueForKeyPath("float")
        let doubleValue: Double = properties.valueForKeyPath("double")
        let boolValue: Bool = properties.valueForKeyPath("bool")
        let arrayValue: [String] = properties.valueForKeyPath("array")
        let dictionaryValue: [String: String] = properties.valueForKeyPath("dictionary")
        let urlValue: NSURL = properties.valueForKeyPath("url")

        // Then
        XCTAssertEqual(stringValue, "string_value")
        XCTAssertEqual(intValue, -10)
        XCTAssertEqual(uintValue, 45)
        XCTAssertEqual(floatValue, 12.34)
        XCTAssertEqual(doubleValue, 1234.5678)
        XCTAssertEqual(boolValue, true)
        XCTAssertEqual(arrayValue, ["value_0", "value_1"])
        XCTAssertEqual(dictionaryValue, ["key": "value"])
        XCTAssertEqual(urlValue, NSURL(string: "https://httpbin.org/get")!)
    }

    func testOptionalValueForKeyPath() {
        // Given, When
        let stringValue: String? = properties.optionalValueForKeyPath("string")
        let stringNilValue: String? = properties.optionalValueForKeyPath("string_nil")

        let intValue: Int? = properties.optionalValueForKeyPath("int")
        let intNilValue: Int? = properties.optionalValueForKeyPath("int_nil")

        let uintValue: UInt? = properties.optionalValueForKeyPath("uint")
        let uintNilValue: UInt? = properties.optionalValueForKeyPath("uint_nil")

        let floatValue: Float? = properties.optionalValueForKeyPath("float")
        let floatNilValue: Float? = properties.optionalValueForKeyPath("float_nil")

        let doubleValue: Double? = properties.optionalValueForKeyPath("double")
        let doubleNilValue: Double? = properties.optionalValueForKeyPath("double_nil")

        let boolValue: Bool? = properties.optionalValueForKeyPath("bool")
        let boolNilValue: Bool? = properties.optionalValueForKeyPath("bool_nil")

        let arrayValue: [String]? = properties.optionalValueForKeyPath("array")
        let arrayNilValue: [String]? = properties.optionalValueForKeyPath("array_nil")

        let dictionaryValue: [String: String]? = properties.optionalValueForKeyPath("dictionary")
        let dictionaryNilValue: [String: String]? = properties.optionalValueForKeyPath("dictionary_nil")

        let urlValue: NSURL? = properties.optionalValueForKeyPath("url")
        let urlNilValue: NSURL? = properties.optionalValueForKeyPath("url_nil")

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

        XCTAssertEqual(urlValue, NSURL(string: "https://httpbin.org/get")!)
        XCTAssertNil(urlNilValue)
    }

    func testArrayForKeyPath() {
        // Given, When
        let stringsArray: [String] = properties.arrayForKeyPath("array_of_any_values")

        // Then
        XCTAssertEqual(stringsArray, ["value_0", "value_1"])
    }
}
