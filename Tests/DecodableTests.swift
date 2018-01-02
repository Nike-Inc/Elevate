//
//  DecodableTests.swift
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

class DecodableTestCase: BaseTestCase {

    // MARK: - Decodable API Success Tests

    func testThatDecodeObjectWithDecodableTypeSucceeds() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("PropertyTypesTest")

            // When
            let testObject: TestObject = try Elevate.decodeObject(from: data, atKeyPath: "sub-object")

            // Then
            XCTAssertEqual(testObject.subUInt, UInt(1), "test object subUInt does not match expected value")
            XCTAssertEqual(testObject.subInt, -1, "test object subInt does not match expected value")
            XCTAssertEqual(testObject.subString, "sub test string", "test object subString does not match expected value")
        } catch {
            XCTFail("Test unexpectedly failed with error: \(error)")
        }
    }

    func testThatDecodeArrayWithDecodableArraySucceeds() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("ArrayTest")

            // When
            let result: [TestObject] = try Elevate.decodeArray(from: data, atKeyPath: "items")

            // Then
            XCTAssertEqual(result[0].subInt, 0, "array item 0 subInt does not match expected value")
            XCTAssertEqual(result[1].subInt, 1, "array item 0 subInt does not match expected value")
            XCTAssertEqual(result[2].subInt, 2, "array item 0 subInt does not match expected value")
        } catch {
            XCTFail("Test unexpectedly failed with error: \(error)")
        }
    }

    // MARK: - Decodable Primitive Success Tests

    func testThatDecodeObjectDecodesStringSuccessfully() {
        do {
            // Given
            let data = "{ \"key\":\"981a383074461fcbf7b9c67e2cb7bd13502d664cad0b254b8f426cd77c62d83e\" }"
                .data(using: .utf8)!

            // When
            let result: String = try Elevate.decodeObject(from: data, atKeyPath: "key")

            // Then
            XCTAssertEqual(result, "981a383074461fcbf7b9c67e2cb7bd13502d664cad0b254b8f426cd77c62d83e")
        } catch {
            XCTFail("Test unexpectedly failed with error: \(error)")
        }
    }

    func testThatDecodeObjectDecodesIntSuccessfully() {
        do {
            // Given
            let data = "{ \"key\" : 7 }".data(using: .utf8)!

            // When
            let result: Int = try Elevate.decodeObject(from: data, atKeyPath: "key")

            // Then
            XCTAssertEqual(result, 7)
        } catch {
            XCTFail("Test unexpectedly failed with error: \(error)")
        }
    }

    func testThatDecodeObjectDecodesUIntSuccessfully() {
        do {
            // Given
            let data = "{ \"key\" : 7 }".data(using: .utf8)!

            // When
            let result: UInt = try Elevate.decodeObject(from: data, atKeyPath: "key")

            // Then
            XCTAssertEqual(result, 7)
        } catch {
            XCTFail("Test unexpectedly failed with error: \(error)")
        }
    }

    func testThatDecodeObjectDecodesFloatSuccessfully() {
        do {
            // Given
            let data = "{ \"key\" : 7.1 }".data(using: .utf8)!

            // When
            let result: Float = try Elevate.decodeObject(from: data, atKeyPath: "key")

            // Then
            XCTAssertEqual(result, 7.1)
        } catch {
            XCTFail("Test unexpectedly failed with error: \(error)")
        }
    }

    func testThatDecodeObjectDecodesDoubleSuccessfully() {
        do {
            // Given
            let data = "{ \"key\" : 7.1 }".data(using: .utf8)!

            // When
            let result: Double = try Elevate.decodeObject(from: data, atKeyPath: "key")

            // Then
            XCTAssertEqual(result, 7.1)
        } catch {
            XCTFail("Test unexpectedly failed with error: \(error)")
        }
    }

    func testThatDecodeObjectDecodesBoolSuccessfully() {
        do {
            // Given
            let data = "{ \"key\" : true }".data(using: .utf8)!

            // When
            let result: Bool = try Elevate.decodeObject(from: data, atKeyPath: "key")

            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Test unexpectedly failed with error: \(error)")
        }
    }

    func testThatDecodeObjectDecodesDictionarySuccessfully() {
        do {
            // Given
            let data = "{ \"key\" : \"value\" }".data(using: .utf8)!

            // When
            let result: [String: String] = try Elevate.decodeObject(from: data, atKeyPath: "")

            // Then
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result["key"], "value")
        } catch {
            XCTFail("Test unexpectedly failed with error: \(error)")
        }
    }

    // MARK: - Decodable Primitive Failure Tests

    func testThatStringDecodableInitializerThrowsForInvalidString() {
        do {
            // Given
            let json = ["key": 0] as Any

            // When
            let _ = try String(json: json)

            XCTFail("String initializer unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            // Then
            XCTAssertEqual(error.failureReason, "JSON object was not of type: String")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decodable")
        }
    }

    func testThatIntDecodableInitializerThrowsForInvalidInt() {
        do {
            // Given
            let json = ["key": "invalid"] as Any

            // When
            let _ = try Int(json: json)

            XCTFail("Int initializer unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            // Then
            XCTAssertEqual(error.failureReason, "JSON object was not of type: Int")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decodable")
        }
    }

    func testThatUIntDecodableInitializerThrowsForInvalidUInt() {
        do {
            // Given
            let json = ["key": "invaild"] as Any

            // When
            let _ = try UInt(json: json)

            XCTFail("UInt initializer unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            // Then
            XCTAssertEqual(error.failureReason, "JSON object was not of type: UInt")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decodable")
        }
    }

    func testThatFloatDecodableInitializerThrowsForInvalidFloat() {
        do {
            // Given
            let json = ["key": "invalid"] as Any

            // When
            let _ = try Float(json: json)

            XCTFail("Float initializer unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            // Then
            XCTAssertEqual(error.failureReason, "JSON object was not of type: Float")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decodable")
        }
    }

    func testThatDoubleDecodableInitializerThrowsForInvalidDouble() {
        do {
            // Given
            let json = ["key": "invalid"] as Any

            // When
            let _ = try Double(json: json)

            XCTFail("Double initializer unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            // Then
            XCTAssertEqual(error.failureReason, "JSON object was not of type: Double")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decodable")
        }
    }

    func testThatBoolDecodableInitializerThrowsForInvalidBool() {
        do {
            // Given
            let json = ["key": 0] as Any

            // When
            let _ = try Bool(json: json)

            XCTFail("Bool initializer unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            // Then
            XCTAssertEqual(error.failureReason, "JSON object was not of type: Bool")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decodable")
        }
    }

    func testThatDictionaryDecodableInitializerThrowsForInvalidDictionary() {
        do {
            // Given
            let json: Any = "value"

            // When
            let _ = try Dictionary<String, String>(json: json)

            XCTFail("Dictionary initializer unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            // Then
            XCTAssertEqual(error.failureReason, "JSON object was not of type: Dictionary<String, String>")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decodable")
        }
    }

    // MARK: - Decodable Failure Tests

    func testThatDecodeObjectThrowsWithInvalidJSON() {
        do {
            // Given
            let data = "some random data that isn't json".data(using: .utf8)!

            // When
            let _: TestObject = try Elevate.decodeObject(from: data, atKeyPath: "sub-object")

            XCTFail("Decoding unexpectedly succeeded.")
        } catch let error as ParserError {
            // Then
            let expectedPrefix = "Parser Deserialization Error - JSON data deserialization failed with error:" // prefix
            XCTAssertTrue(error.description.hasPrefix(expectedPrefix), "Error does not begin with expected prefix")

            let expectedFailureReason = "JSON data deserialization failed with error:"
            let containsFailureReason = (error.description as NSString).contains(expectedFailureReason)
            XCTAssertTrue(containsFailureReason, "Error should contain expected failure reason")
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }

    func testThatDecodeObjectThrowsWithMissingKeyPath() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("PropertyTypesTest")

            // When
            let _: TestObject = try Elevate.decodeObject(from: data, atKeyPath: "key_does_not_exist")

            XCTFail("Decoding unexpectedly succeeded.")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - Required key path [key_does_not_exist] was missing or null"
            XCTAssertEqual(expectedValue, actualValue, "Parser error message did not match expected value.")
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }

    func testThatDecodeObjectThrowsWhenDecodableThrows() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("PropertyTypesTest")

            // When
            let _: TestObject = try Elevate.decodeObject(from: data, atKeyPath: "testDictionary")

            XCTFail("Decoding unexpectedly succeeded.")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = (
                "Parser Validation Error - Required key path [subUInt] was missing or null\n" +
                "Required key path [subInt] was missing or null\n" +
                "Required key path [subString] was missing or null"
            )

            XCTAssertEqual(expectedValue, actualValue, "Parser error message did not match expected value.")
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }

    func testThatParserParseEntityThrowsWithInvalidDecodable() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("ArrayTest")

            // When
            _ = try Parser.parseEntity(data: data) { schema in
                schema.addProperty(keyPath: "items", type: .array, decodableType: InvalidDecodable.self)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - Error parsing array object at index 0 with parser [InvalidDecodable]"
            XCTAssertTrue(actualValue.hasPrefix(expectedValue), "Error message for Array Decodable did not match expected value")
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }

    func testThatDecodableInitializerThrowsWithIncorrectInputType() {
        decodableErrorTest(type: String.self, value: 1)
        decodableErrorTest(type: Int.self, value: "1")
        decodableErrorTest(type: UInt.self, value: "1")
        decodableErrorTest(type: Float.self, value: "1")
        decodableErrorTest(type: Double.self, value: "1")
        decodableErrorTest(type: Bool.self, value: "1")
        decodableErrorTest(type: [String: String].self, value: "1")
    }

    func testThatCustomErrorsThrownFromDecodableCanBeCaught() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("PropertyTypesTest")

            // When
            let _: ErrorThrowingDecodable = try Elevate.decodeObject(from: data)

            XCTFail("Decoding unexpectedly succeeded.")
        } catch let error as NSError {
            // Then
            XCTAssertEqual(error.domain, "Decodable Test Error", "Error domain did not match expected value.")
            XCTAssertEqual(error.code, 42, "Error code did not match expected value.")
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }

    // MARK: - Private - Helper Methods

    private func decodableErrorTest(type: Elevate.Decodable.Type, value: Any) {
        do {
            // Given, When
            let _ = try type.init(json: value)

            XCTFail("Decodable initializer unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.failureReason
            let expectedValue = "JSON object was not of type: \(type)"
            XCTAssertEqual(actualValue, expectedValue, "Decodable error message did not match expected value.")
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }
}
