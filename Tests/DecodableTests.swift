//
//  ElevateDecodableTests.swift
//  Elevate
//
//  Created by Christian Noon on 7/14/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Elevate
import Foundation
import XCTest

class DecodableTestCase: BaseTestCase {
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

    func testThatParseObjectParsesStringSuccessfully() {
        // Given
        let data = "{ \"key\":\"981a383074461fcbf7b9c67e2cb7bd13502d664cad0b254b8f426cd77c62d83e\" }"
            .dataUsingEncoding(NSUTF8StringEncoding)!

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
        let data = "{ \"key\" : 7 }".dataUsingEncoding(NSUTF8StringEncoding)!

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
        let data = "{ \"key\" : 7 }".dataUsingEncoding(NSUTF8StringEncoding)!

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
        let data = "{ \"key\" : 7.1 }".dataUsingEncoding(NSUTF8StringEncoding)!

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
        let data = "{ \"key\" : 7.1 }".dataUsingEncoding(NSUTF8StringEncoding)!

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
        let data = "{ \"key\" : true }".dataUsingEncoding(NSUTF8StringEncoding)!

        // When
        do {
            let result: Bool = try Parser.parseObject(data: data, forKeyPath: "key")

            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Parser unexpectedly failed by throwing error: \(error)")
        }
    }

    func testThatParseThrowsWithInvalidJSON() {
        // Given
        let data = "some random data that isn't json".dataUsingEncoding(NSUTF8StringEncoding)!

        // When
        do {
            let _: TestObject = try Parser.parseObject(data: data, forKeyPath: "sub-object")

            XCTFail("Parser unexpectedly succeeded.")
        } catch let error as ParserError {
            // Then
            let expectedPrefix = "Parser Deserialization Error - JSON data deserialization failed with error:" // prefix
            XCTAssertTrue(error.description.hasPrefix(expectedPrefix), "Error does not begin with expected prefix")

            let expectedFailureReason = "JSON data deserialization failed with error:"
            let containsFailureReason = (error.description as NSString).containsString(expectedFailureReason)
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
                make.propertyForKeyPath("items", type: .Array, decodedToType: InvalidDecodable.self)
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
}
