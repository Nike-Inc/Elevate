//
//  DecoderTests.swift
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

class ValidDecoder: Elevate.Decoder {
    let toDictionary: Bool

    init(toDictionary: Bool = false) {
        self.toDictionary = toDictionary
    }

    func decode(_ object: Any) throws -> Any {
        let entity = try Parser.parseEntity(json: object) { schema in
            schema.addProperty(keyPath: "subUInt", type: .uint)
            schema.addProperty(keyPath: "subInt", type: .int)
            schema.addProperty(keyPath: "subString", type: .string)
        }

        if toDictionary {
            return entity
        } else {
            return TestObject(
                subUInt: entity["subUInt"] as! UInt,
                subInt: entity["subInt"] as! Int,
                subString: entity["subString"] as! String
            )
        }
    }
}

class InvalidDecoder: Elevate.Decoder {
    func decode(_ object: Any) throws -> Any {
        return try Parser.parseEntity(json: object) { schema in
            schema.addProperty(keyPath: "subUInt", type: .string)
            schema.addProperty(keyPath: "missingSubInt", type: .int)
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
        ) as! [String: Any]

        // When
        do {
            if let entity = try decoder.decode(json["sub-object"]!) as? [String: Any] {
                // Then
                XCTAssertEqual(entity["subUInt"] as? UInt, UInt(1), "Parsed UInt value did not equal value from json file.")
                XCTAssertEqual(entity["subInt"] as? Int, -1, "Parsed Int value did not equal value from json file.")
                XCTAssertEqual(entity["subString"] as? String, "sub test string", "Parsed String value did not equal value from json file.")
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
            let results: [TestObject] = try Elevate.decodeArray(from: data, atKeyPath: "items", with: ValidDecoder())

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
            let testObject: TestObject = try Elevate.decodeObject(from: data, atKeyPath: "sub-object", with: decoder)

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
            let _ = try Parser.parseEntity(data: data) { schema in
                schema.addProperty(keyPath: "sub-object", type: .dictionary, decoder: InvalidDecoder())
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
            let _ = try Parser.parseEntity(data: data) { schema in
                schema.addProperty(keyPath: "testString", type: .string, decoder: StringToIntDecoder())
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
            let entity = try Parser.parseEntity(data: data) { schema in
                schema.addProperty(keyPath: "testDate", type: .string, decoder: decoder)
            }

            // Then
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormats.Format1
            let parsedDate = entity["testDate"] as! Date
            let testDate = dateFormatter.date(from: "2015-01-30 at 13:00")
            XCTAssertEqual(parsedDate, testDate!, "Parsed Date did not equal value from json file.")
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
            let entity = try Parser.parseEntity(data: data) { schema in
                schema.addProperty(keyPath: "testDate", type: .string, decoder: decoder)
            }

            // Then
            let expectedDateFormatter = DateFormatter()
            expectedDateFormatter.dateFormat = DateFormats.Format1
            let parsedDate = entity["testDate"] as! Date
            let testDate = expectedDateFormatter.date(from: "2015-01-30 at 13:00")
            XCTAssertEqual(parsedDate, testDate!, "Parsed Date did not equal value from json file.")
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
            _ = try Parser.parseEntity(data: data) { schema in
                schema.addProperty(keyPath: "testDate", type: .string, decoder: decoder)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - DateParser string could not be parsed to Date with the given formatter."
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
            _ = try Parser.parseEntity(data: data) { schema in
                schema.addProperty(keyPath: "testInt", type: .int, decoder: decoder)
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

    func testThatCustomErrorsThrownFromDecoderCanBeCaught() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("PropertyTypesTest")

            // When
            let _: ErrorThrowingDecodable = try Elevate.decodeObject(from: data, with: ErrorThrowingDecoder())

            XCTFail("Decoding unexpectedly succeeded.")
        } catch let error as NSError {
            // Then
            XCTAssertEqual(error.domain, "Decoder Test Error")
            XCTAssertEqual(error.code, 42)
        } catch {
            XCTFail("Parser error was of incorrect type.")
        }
    }
}
