//
//  DecodableTests.swift
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

class DecodableTestCase: BaseTestCase {

    // MARK: - Decodable API Success Tests

    func testThatParseOnADecodableSucceeds() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let testObject: TestObject = try Parser.parseObject(data: data, forKeyPath: "sub-object")

            // Then
            XCTAssertEqual(testObject.subUInt, UInt(1), "test object subUInt does not match expected value")
            XCTAssertEqual(testObject.subInt, -1, "test object subInt does not match expected value")
            XCTAssertEqual(testObject.subString, "sub test string", "test object subString does not match expected value")
        } catch {
            XCTFail("Parser unexpectedly failed by throwing error: \(error)")
        }
    }

    func testThatParseOnAnArraySucceeds() {
        // Given
        let data = loadJSONDataForFileNamed("ArrayTest")

        // When
        do {
            let result: [TestObject] = try Parser.parseArray(data: data, forKeyPath: "items")

            // Then
            XCTAssertEqual(result[0].subInt, 0, "array item 0 subInt does not match expected value")
            XCTAssertEqual(result[1].subInt, 1, "array item 0 subInt does not match expected value")
            XCTAssertEqual(result[2].subInt, 2, "array item 0 subInt does not match expected value")
        } catch {
            XCTFail("Parser uneexpectedly failed by throwing error: \(error)")
        }
    }

    // MARK: - Decodable Primative Success Tests

    func testThatParseObjectParsesStringSuccessfully() {
        // Given
        let data = "{ \"key\":\"981a383074461fcbf7b9c67e2cb7bd13502d664cad0b254b8f426cd77c62d83e\" }"
            .data(using: String.Encoding.utf8)!

        // When
        do {
            let result: String = try Parser.parseObject(data: data, forKeyPath: "key")

            // Then
            XCTAssertEqual(result, "981a383074461fcbf7b9c67e2cb7bd13502d664cad0b254b8f426cd77c62d83e")
        } catch {
            XCTFail("Parser unexpectedly failed by throwing error: \(error)")
        }
    }

    func testThatParseObjectParsesIntSuccessfully() {
        // Given
        let data = "{ \"key\" : 7 }".data(using: String.Encoding.utf8)!

        // When
        do {
            let result: Int = try Parser.parseObject(data: data, forKeyPath: "key")

            // Then
            XCTAssertEqual(result, 7)
        } catch {
            XCTFail("Parser unexpectedly failed by throwing error: \(error)")
        }
    }

    func testThatParseObjectParsesUIntSuccessfully() {
        // Given
        let data = "{ \"key\" : 7 }".data(using: String.Encoding.utf8)!

        // When
        do {
            let result: UInt = try Parser.parseObject(data: data, forKeyPath: "key")

            // Then
            XCTAssertEqual(result, 7)
        } catch {
            XCTFail("Parser unexpectedly failed by throwing error: \(error)")
        }
    }

    func testThatParseObjectParsesFloatSuccessfully() {
        // Given
        let data = "{ \"key\" : 7.1 }".data(using: String.Encoding.utf8)!

        // When
        do {
            let result: Float = try Parser.parseObject(data: data, forKeyPath: "key")

            // Then
            XCTAssertEqual(result, 7.1)
        } catch {
            XCTFail("Parser unexpectedly failed by throwing error: \(error)")
        }
    }

    func testThatParseObjectParsesDoubleSuccessfully() {
        // Given
        let data = "{ \"key\" : 7.1 }".data(using: String.Encoding.utf8)!

        // When
        do {
            let result: Double = try Parser.parseObject(data: data, forKeyPath: "key")

            // Then
            XCTAssertEqual(result, 7.1)
        } catch {
            XCTFail("Parser unexpectedly failed by throwing error: \(error)")
        }
    }

    func testThatParseObjectParsesBoolSuccessfully() {
        // Given
        let data = "{ \"key\" : true }".data(using: String.Encoding.utf8)!

        // When
        do {
            let result: Bool = try Parser.parseObject(data: data, forKeyPath: "key")

            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Parser unexpectedly failed by throwing error: \(error)")
        }
    }

    // MARK: - Decoable Primative Failure Tests

    func testThatParseObjectThrowsForInvalidString() {
        // Given
        let json = ["key": 0]

        // When
        do {
            let _ = try String(json: json)

            XCTFail("Parser unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            XCTAssertEqual(error.failureReason, "JSON object was not of type: String")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decoable")
        }
    }

    func testThatParseObjectThrowsForInvalidInt() {
        // Given
        let json = ["key": "invalid"]

        // When
        do {
            let _ = try Int(json: json)

            XCTFail("Parser unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            XCTAssertEqual(error.failureReason, "JSON object was not of type: Int")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decoable")
        }
    }

    func testThatParseObjectThrowsForInvalidUInt() {
        // Given
        let json = ["key": "invaild"]

        // When
        do {
            let _ = try UInt(json: json)

            XCTFail("Parser unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            XCTAssertEqual(error.failureReason, "JSON object was not of type: UInt")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decoable")
        }
    }

    func testThatParseObjectThrowsForInvalidFloat() {
        // Given
        let json = ["key": "invalid"]

        // When
        do {
            let _ = try Float(json: json)

            XCTFail("Parser unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            XCTAssertEqual(error.failureReason, "JSON object was not of type: Float")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decoable")
        }
    }

    func testThatParseObjectThrowsForInvalidDouble() {
        // Given
        let json = ["key": "invalid"]

        // When
        do {
            let _ = try Double(json: json)

            XCTFail("Parser unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            XCTAssertEqual(error.failureReason, "JSON object was not of type: Double")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decoable")
        }
    }

    func testThatParseObjectThrowsForInvalidBool() {
        // Given
        let json = ["key": 0]

        // When
        do {
            let _ = try Bool(json: json)

            XCTFail("Parser unexpectedly succeeded in parsing data of incorrect type")
        } catch let error as ParserError {
            XCTAssertEqual(error.failureReason, "JSON object was not of type: Bool")
        } catch {
            XCTFail("Incorrect error type was thrown while parsing Decoable")
        }
    }

    // MARK: - Decodable Failure Tests

    func testThatParseThrowsWithInvalidJSON() {
        // Given
        let data = "some random data that isn't json".data(using: String.Encoding.utf8)!

        // When
        do {
            let _: TestObject = try Parser.parseObject(data: data, forKeyPath: "sub-object")

            XCTFail("Parser unexpectedly succeeded.")
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

    func testThatParseThrowsWithMissingKeyPath() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let _: TestObject = try Parser.parseObject(data: data, forKeyPath: "key_does_not_exist")

            XCTFail("Parser unexpectedly succeeded.")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - Required key path [key_does_not_exist] was missing or null"
            XCTAssertEqual(expectedValue, actualValue, "Parser error message did not match expected value.")
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }

    func testThatParseThrowsWhenDecodableThrows() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let _: TestObject = try Parser.parseObject(data: data, forKeyPath: "testDictionary")

            XCTFail("Parser unexpectedly succeeded.")
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

    func testThatItThrowsWithInvalidDecodable() {
        // Given
        let data = loadJSONDataForFileNamed("ArrayTest")

        // When
        do {
            try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("items", type: .array, decodedToType: InvalidDecodable.self)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - Error parsing array object at index 0 with parser [InvalidDecodable]"
            XCTAssertTrue(actualValue.hasPrefix(expectedValue), "Error message for Array Decodable did not match expected value")
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }

// As of Xcode 7.3 there is a compiler bug in Release configuration when executing type.init below
#if DEBUG
    func testThatItThrowsWithIncorrectInputType() {
        decodableErrorTest(String.self, value: 1)
        decodableErrorTest(Int.self, value: "1")
        decodableErrorTest(UInt.self, value: "1")
        decodableErrorTest(Float.self, value: "1")
        decodableErrorTest(Double.self, value: "1")
        decodableErrorTest(Bool.self, value: "1")
    }

    // MARK: Private Helper Methods

    private func decodableErrorTest(type: Decodable.Type, value: AnyObject) {
        do {
            let _ = try type.init(json: value)

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            let actualValue = error.failureReason
            let expectedValue = "JSON object was not of type: \(type)"
            XCTAssertEqual(actualValue, expectedValue, "Decodable error message did not match expected value.")
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }
#endif
}
