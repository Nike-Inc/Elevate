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

struct TestObject {
    let subUInt: UInt
    let subInt: Int
    let subString: String
}

extension TestObject: Decodable {
    init(json: AnyObject) throws {
        let subUIntKeyPath = "subUInt"
        let subIntKeyPath = "subInt"
        let subStringKeyPath = "subString"

        let properties = try Parser.parseProperties(json: json) { make in
            make.propertyForKeyPath(subUIntKeyPath, type: .UInt)
            make.propertyForKeyPath(subIntKeyPath, type: .Int)
            make.propertyForKeyPath(subStringKeyPath, type: .String)
        }

        self.subUInt = properties[subUIntKeyPath] as! UInt
        self.subInt = properties[subIntKeyPath] as! Int
        self.subString = properties[subStringKeyPath] as! String
    }
}

// MARK: -

class DecodableTestCase: BaseTestCase {
    func testThatParseOnADecodableSucceeds() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let testObject: TestObject = try Parser.parse(data: data, forKeyPath: "sub-object")

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
            let result: [TestObject] = try Parser.parse(data: data, forKeyPath: "items")

            // Then
            XCTAssertEqual(result[0].subInt, 0, "array item 0 subInt does not match expected value")
            XCTAssertEqual(result[1].subInt, 1, "array item 0 subInt does not match expected value")
            XCTAssertEqual(result[2].subInt, 2, "array item 0 subInt does not match expected value")
        } catch {
            XCTFail("Parser uneexpectedly failed by throwing error: \(error)")
        }
    }

    func testThatParseThrowsWithInvalidJSON() {
        // Given
        let data = "some random data that isn't json".dataUsingEncoding(NSUTF8StringEncoding)!

        // When
        do {
            let _: TestObject = try Parser.parse(data: data, forKeyPath: "sub-object")

            XCTFail("Parser unexpectedly succeeded.")
        } catch let error as ParserError {
            // Then
            let expectedPrefix = "Parser Validation Error - JSON data serialization failed with error:" // prefix
            XCTAssertTrue(error.description.hasPrefix(expectedPrefix), "Error does not begin with expected prefix")

            let expectedFailureReason = "JSON data serialization failed with error:"
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
            let _: TestObject = try Parser.parse(data: data, forKeyPath: "key_does_not_exist")

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
            let _: TestObject = try Parser.parse(data: data, forKeyPath: "testDictionary")

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
}
