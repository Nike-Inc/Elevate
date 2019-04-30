//
//  EncodableTests.swift
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

import Elevate
import Foundation
import XCTest

class EncodableTestCase: BaseTestCase {
    func testThatTestObjectCanBeEncoded() {
        // Given
        let testObject = TestObject(subUInt: 10, subInt: -30, subString: "randomString")

        // When
        let json = testObject.json as? [String: Any]

        // Then
        XCTAssertEqual(json?["subUInt"] as? UInt, 10)
        XCTAssertEqual(json?["subInt"] as? Int, -30)
        XCTAssertEqual(json?["subString"] as? String, "randomString")
    }

    func testThatStringTypesCanBeEncoded() {
        // Given
        let string = "s1"
        let url = URL(string: "https://httbin.org/get")!

        // When
        let stringJSON = string.json
        let urlJSON = url.json

        // Then
        XCTAssertEqual(stringJSON as? String, string)
        XCTAssertEqual(urlJSON as? String, url.absoluteString)
    }

    func testThatIntTypesCanBeEncoded() {
        // Given
        let int = Int(1)
        let int8 = Int8(2)
        let int16 = Int16(3)
        let int32 = Int32(4)
        let int64 = Int64(5)

        // When
        let intJSON = int.json
        let int8JSON = int8.json
        let int16JSON = int16.json
        let int32JSON = int32.json
        let int64JSON = int64.json

        // Then
        XCTAssertEqual(intJSON as? Int, int)
        XCTAssertEqual(int8JSON as? Int8, int8)
        XCTAssertEqual(int16JSON as? Int16, int16)
        XCTAssertEqual(int32JSON as? Int32, int32)
        XCTAssertEqual(int64JSON as? Int64, int64)
    }

    func testThatUIntTypesCanBeEncoded() {
        // Given
        let uint = UInt(1)
        let uint8 = UInt8(2)
        let uint16 = UInt16(3)
        let uint32 = UInt32(4)
        let uint64 = UInt64(5)

        // When
        let uintJSON = uint.json
        let uint8JSON = uint8.json
        let uint16JSON = uint16.json
        let uint32JSON = uint32.json
        let uint64JSON = uint64.json

        // Then
        XCTAssertEqual(uintJSON as? UInt, uint)
        XCTAssertEqual(uint8JSON as? UInt8, uint8)
        XCTAssertEqual(uint16JSON as? UInt16, uint16)
        XCTAssertEqual(uint32JSON as? UInt32, uint32)
        XCTAssertEqual(uint64JSON as? UInt64, uint64)
    }

    func testThatNumberTypesCanBeEncoded() {
        // Given
        let float = Float(1.23)
        let double = Double(45.67)
        let boolTrue = true
        let boolFalse = false

        // When
        let floatJSON = float.json
        let doubleJSON = double.json
        let boolTrueJSON = boolTrue.json
        let boolFalseJSON = boolFalse.json

        // Then
        XCTAssertEqual(floatJSON as? Float, float)
        XCTAssertEqual(doubleJSON as? Double, double)
        XCTAssertEqual(boolTrueJSON as? Bool, boolTrue)
        XCTAssertEqual(boolFalseJSON as? Bool, boolFalse)
    }

    func testThatArrayTypesCanBeEncoded() {
        // Given
        let stringArray: [String] = ["s1", "s2", "s3"]
        let intArray: [Int] = [1, 2, 3]

        let testObjectArray = [
            TestObject(subUInt: 1, subInt: 2, subString: "3"),
            TestObject(subUInt: 4, subInt: 5, subString: "6")
        ]

        // When
        let stringArrayJSON = stringArray.json
        let intArrayJSON = intArray.json
        let testObjectArrayJSON = testObjectArray.json

        // Then
        XCTAssertEqual(stringArrayJSON as? [String] ?? [], stringArray)
        XCTAssertEqual(intArrayJSON as? [Int] ?? [], intArray)

        let expectedTestObjectArrayJSON: [[String: Any]] = [
            [
                "subUInt": 1,
                "subInt": 2,
                "subString": "3"
            ],
            [
                "subUInt": 4,
                "subInt": 5,
                "subString": "6"
            ]
        ]

        do {
            let actualTestObjectJSON = try JSONSerialization.data(
                withJSONObject: testObjectArrayJSON,
                options: []
            )

            let expectedTestObjectJSON = try JSONSerialization.data(
                withJSONObject: expectedTestObjectArrayJSON,
                options: []
            )

            XCTAssertEqual(actualTestObjectJSON.count, expectedTestObjectJSON.count)
        } catch {
            XCTFail("JSON encoding failed with unexpected error: \(error)")
        }
    }

    func testThatSetTypesCanBeEncoded() {
        // Given
        let stringSet: Set<String> = ["s1", "s2", "s3"]
        let intSet: Set<Int> = [1, 2, 3]

        // When
        let stringSetJSON = stringSet.json
        let intSetJSON = intSet.json

        // Then
        XCTAssertEqual(stringSetJSON as? [String] ?? [], Array(stringSet))
        XCTAssertEqual(intSetJSON as? [Int] ?? [], Array(intSet))
    }

    func testThatDictionaryTypesCanBeEncoded() {
        // Given
        let stringDictionary: [String: String] = [
            "string1": "s1",
            "string2": "s2",
            "string3": "s3"
        ]

        let intDictionary: [String: Int] = [
            "int1": 1,
            "int2": 2,
            "int3": 3
        ]

        // When
        let stringDictionaryJSON = stringDictionary.json as? [String: String]
        let intDictionaryJSON = intDictionary.json as? [String: Int]

        // Then
        if let stringDictionaryJSON = stringDictionaryJSON, stringDictionaryJSON.count == 3, stringDictionary.count == 3 {
            XCTAssertEqual(stringDictionaryJSON["string1"], stringDictionary["string1"])
            XCTAssertEqual(stringDictionaryJSON["string2"], stringDictionary["string2"])
            XCTAssertEqual(stringDictionaryJSON["string3"], stringDictionary["string3"])
        } else {
            XCTFail("Both dictionaries should have 3 items")
        }

        if let intDictionaryJSON = intDictionaryJSON, intDictionaryJSON.count == 3, intDictionary.count == 3 {
            XCTAssertEqual(intDictionaryJSON["int1"], intDictionary["int1"])
            XCTAssertEqual(intDictionaryJSON["int2"], intDictionary["int2"])
            XCTAssertEqual(intDictionaryJSON["int3"], intDictionary["int3"])
        } else {
            XCTFail("Both dictionaries should have 3 items")
        }
    }
}
