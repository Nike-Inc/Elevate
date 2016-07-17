//
//  DecoderTests.swift
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

class ValidDecoder: Decoder {
    let toDictionary: Bool

    init(toDictionary: Bool = false) {
        self.toDictionary = toDictionary
    }

    func decodeObject(_ object: AnyObject) throws -> Any {
        let result = try Parser.parseProperties(json: object) { make in
            make.propertyForKeyPath("subUInt", type: .uInt)
            make.propertyForKeyPath("subInt", type: .int)
            make.propertyForKeyPath("subString", type: .string)
        }

        if toDictionary {
            return result
        } else {
            return TestObject(
                subUInt: result["subUInt"] as! UInt,
                subInt: result["subInt"] as! Int,
                subString: result["subString"] as! String
            )
        }
    }
}

class InvalidDecoder: Decoder {
    func decodeObject(_ object: AnyObject) throws -> Any {
        return try Parser.parseProperties(json: object) { make in
            make.propertyForKeyPath("subUInt", type: .string)
            make.propertyForKeyPath("missingSubInt", type: .int)
        }
    }
}

// MARK: -

class DecoderTestCase: BaseTestCase {
    func testThatItDecodesObject() {
        // Given
        let decoder = ValidDecoder(toDictionary: true)

        let data = loadJSONDataForFileNamed("PropertyTypesTest")
        let json = try! JSONSerialization.jsonObject(
            with: data,
            options: JSONSerialization.ReadingOptions(rawValue: 0)
        ) as! [String: AnyObject]

        // When
        do {
            if let properties = try decoder.decodeObject(json["sub-object"]!) as? [String: Any] {
                // Then
                XCTAssertEqual(properties["subUInt"] as? UInt, UInt(1), "Parsed UInt value did not equal value from json file.")
                XCTAssertEqual(properties["subInt"] as? Int, -1, "Parsed Int value did not equal value from json file.")
                XCTAssertEqual(properties["subString"] as? String, "sub test string", "Parsed String value did not equal value from json file.")
            } else {
                XCTFail("Parser did not return the expected type")
            }
        } catch {
            XCTFail("Parser unexpectedly returned an error")
        }
    }

    func testThatItDecodesObjectArrayWithParseMethod() {
        // Given
        let data = loadJSONDataForFileNamed("ArrayTest")

        // When
        do {
            let results: [TestObject] = try Parser.parseArray(data: data, forKeyPath: "items", withDecoder: ValidDecoder())

            // Then
            XCTAssertEqual(results[0].subInt, 0)
            XCTAssertEqual(results[1].subString, "value1")
            XCTAssertEqual(results[2].subUInt, 2)
        } catch {
            XCTFail("Parser unexpectedly returned an error")
        }
    }

    func testThatItParsesObjectSuccessfully() {
        // Given
        let decoder = ValidDecoder()
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        do {
            // When
            let testObject: TestObject = try Parser.parseObject(data: data, forKeyPath: "sub-object", withDecoder: decoder)

            // Then
            XCTAssertEqual(testObject.subUInt, UInt(1), "Parsed UInt value did not equal value from json file.")
            XCTAssertEqual(testObject.subInt, -1, "Parsed Int value did not equal value from json file.")
            XCTAssertEqual(testObject.subString, "sub test string", "Parsed string value did not equal value from json file.")
        } catch {
            XCTFail("Parser unexpectedly returned an error")
        }
    }

    func testThatItAggregatesErrorsWhenUsingInvalidDecoder() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        do {
            // When
            let _ = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("sub-object", type: .dictionary, decoder: InvalidDecoder())
            }

            XCTFail("ErroneousTestObjectParser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = (
                "Parser Validation Error - Value for key path [subUInt] is of incorrect type\n" +
                "Required key path [missingSubInt] was missing or null"
            )
            XCTAssertEqual(actualValue, expectedValue, "ErroneousTestObjectParser error did not match expected value")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatItGeneratesErrorWhenStringToIntDecoderStringIsNotAnInt() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let _ = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("testString", type: .string, decoder: StringToIntDecoder())
            }
        } catch let error as ParserError {
            // Then
            let actualValue = error.failureReason
            let expectedValue = "Could not convert String to Int"
            XCTAssertEqual(expectedValue, actualValue, "Parser error message did not match expected value")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }
}

// MARK: -

class DateDecoderTestCase: BaseTestCase {
    func testThatItParsesDateUsingFormatString() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")
        let decoder = DateDecoder(dateFormatString: DateFormats.Format1)

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("testDate", type: .string, decoder: decoder)
            }

            // Then
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormats.Format1
            let parsedDate = properties["testDate"] as! Date
            let testDate = dateFormatter.date(from: "2015-01-30 at 13:00")
            XCTAssertEqual(parsedDate, testDate!, "Parsed NSDate did not equal value from json file.")
        } catch {
            XCTFail("Parser unexpectedly returned an error")
        }
    }

    func testThatItParsesDateUsingDateFormatter() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormats.Format1
        let decoder = DateDecoder(dateFormatter: dateFormatter)

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("testDate", type: .string, decoder: decoder)
            }

            // Then
            let expectedDateFormatter = DateFormatter()
            expectedDateFormatter.dateFormat = DateFormats.Format1
            let parsedDate = properties["testDate"] as! Date
            let testDate = expectedDateFormatter.date(from: "2015-01-30 at 13:00")
            XCTAssertEqual(parsedDate, testDate!, "Parsed NSDate did not equal value from json file.")
        } catch {
            XCTFail("Parser unexpectedly returned an error")
        }
    }

    func testThatItGeneratesAnErrorForIncorrectDateFormat() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")
        let decoder = DateDecoder(dateFormatString: "d")

        do {
            // When
            try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("testDate", type: .string, decoder: decoder)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - DateParser string could not be parsed to NSDate with the given formatter."
            XCTAssertEqual(actualValue, expectedValue, "DateParser error message did not match expected string")
        }  catch {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatItGeneratesAnErrorForIncorrectInputType() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")
        let decoder = DateDecoder(dateFormatString: "d")

        do {
            // When
            try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("testInt", type: .int, decoder: decoder)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.failureReason
            let expectedValue = "DateParser object to parse was not a String."
            XCTAssertEqual(actualValue, expectedValue, "DateParser error message did not match expected string")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }
}
