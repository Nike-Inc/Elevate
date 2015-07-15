//
//  ElevateTests.swift
//  ElevateTests
//
//  Created by Eric Appel on 7/13/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation
import XCTest
@testable import Elevate

struct DateFormats {
    static let Format1 = "yyyy-MM-dd 'at' HH:mm"
}

// MARK: -

class ParserTestUtilities {
    class func loadJSONDataForFileNamed(filename: String) -> NSData {
        let bundle = NSBundle(forClass: ParserTestUtilities.self)
        let path = bundle.pathForResource(filename, ofType: "json")
        return NSData(contentsOfFile: path!)!
    }
}

// MARK: -

class TestDecoder: Decoder { // What does this decode so we can be better about naming
    func decodeObject(object: AnyObject) throws -> Any {
        let json = object as! [String: AnyObject]

        return try Parser.parseProperties(json: json) { make in
            make.propertyForKeyPath("subUInt", type: .UInt)
            make.propertyForKeyPath("subInt", type: .Int)
            make.propertyForKeyPath("subString", type: .String)
        }
    }
}

class ErroneousDecoder: Decoder { // What is the error that throws so we can name this better!
    func decodeObject(object: AnyObject) throws -> Any {
        let json = object as! [String: AnyObject]

        return try Parser.parseProperties(json: json) { make in
            make.propertyForKeyPath("subUInt", type: .String)
            make.propertyForKeyPath("missingSubInt", type: .Int)
        }
    }
}

// MARK: -

class ParserTestCase: XCTestCase {
    func testThatItParsesValuesForAllPropertyTypes() {
        // Given
        let data = ParserTestUtilities.loadJSONDataForFileNamed("PropertyTypesTest")
        let dateDecoder = DateDecoder(dateFormatString: DateFormats.Format1)

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { (make: ParserPropertyMaker) -> Void in
                make.propertyForKeyPath("testUInt", type: ParserPropertyType.UInt)
                make.propertyForKeyPath("testInt", type: .Int)
                make.propertyForKeyPath("testString", type: .String)
                make.propertyForKeyPath("testFloat", type: .Float)
                make.propertyForKeyPath("testDouble", type: .Double)
                make.propertyForKeyPath("testNumber", type: .Number)
                make.propertyForKeyPath("testNull", type: .String, optional: true)
                make.propertyForKeyPath("testDictionary", type: .Dictionary)
                make.propertyForKeyPath("testDate", type: .String, decoder: dateDecoder)
                make.propertyForKeyPath("testURL", type: .URL)
                make.propertyForKeyPath("sub-object", type: .Dictionary, decoder: TestDecoder())
            }

            // Then
            XCTAssertEqual(properties["testUInt"] as! UInt, UInt(1), "Parsed UInt value did not equal value from json file.")
            XCTAssertEqual(properties["testInt"] as! Int, -1, "Parsed Int value did not equal value from json file.")
            XCTAssertEqual(properties["testString"] as! String, "test string", "Parsed String value did not equal value from json file.")
            XCTAssertEqual(properties["testFloat"] as! Float, Float(1.1111), "Parsed Float did not equal value from json file.")
            XCTAssertEqual(properties["testDouble"] as! Double, 1.1111, "Parsed Double did not equal value from json file.")
            XCTAssertEqual(properties["testNumber"] as! NSNumber, NSNumber(double: 1.1111), "Parsed NSNumber did not equal value from json file.")
            XCTAssertTrue(properties["testNull"] == nil, "Parsed value did not equal nil from json file.")

            let jsonDictionary = properties["testDictionary"] as! [String: AnyObject]

            XCTAssertEqual(jsonDictionary["key1"] as! String, "value1", "Parsed Dictionary<String, AnyObject> did not equal value from json file.")
            XCTAssertTrue(properties["sub-object"] is [String: Any], "Parsed sub object did not contain value of correct type")

            let subObject = properties["sub-object"] as? [String: Any]
            XCTAssertEqual(subObject?["subUInt"] as! UInt, UInt(1), "Parsed sub object value did not equal value from json file.")
            XCTAssertEqual(subObject?["subInt"] as! Int, -1, "Parsed sub object value did not equal value from json file.")
            XCTAssertEqual(subObject?["subString"] as! String, "sub test string", "Parsed sub object value did not equal value from json file.")

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = DateFormats.Format1
            let parsedDate = properties["testDate"] as! NSDate
            let testDate = dateFormatter.dateFromString("2015-01-30 at 13:00")
            XCTAssertTrue(parsedDate == testDate, "Parsed NSDate did not equal value from json file.")

            let expectedURL = NSURL(string: "http://apple.com")?.absoluteString ?? "default expected URL"
            let actualURL = (properties["testURL"] as? NSURL)?.absoluteString ?? "default actual URL"
            XCTAssertEqual(actualURL, expectedURL, "Parsed NSURL did not equal value from json file.")
        } catch {
            XCTFail("Parser should not fail with error: \(error)")
        }
    }

    func testThatItGeneratesErrorsWhenParsingValuesOfIncorrectType() {
        // Given
        let data = ParserTestUtilities.loadJSONDataForFileNamed("PropertyTypesWithIncorrectValueTypes")

        // When
        do {
            let _ = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("uint", type: .UInt)
                make.propertyForKeyPath("int", type: .Int)
                make.propertyForKeyPath("string", type: .String)
                make.propertyForKeyPath("float", type: .Float)
                make.propertyForKeyPath("double", type: .Double)
                make.propertyForKeyPath("number", type: .Number)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = (
                "Parser Validation Error - Value for key path [uint] is of incorrect type\n" +
                    "Value for key path [int] is of incorrect type\n" +
                    "Value for key path [string] is of incorrect type\n" +
                    "Value for key path [float] is of incorrect type\n" +
                    "Value for key path [double] is of incorrect type\n" +
                "Value for key path [number] is of incorrect type"
            )

            XCTAssertEqual(expectedValue, actualValue, "Parser error message did not match expected value")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatItAggregatesErrorsWithMultipleLevels() {
        // Given
        let data = ParserTestUtilities.loadJSONDataForFileNamed("PropertyTypesWithIncorrectValueTypes")

        // When
        do {
            let _ = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("uint", type: .UInt)
                make.propertyForKeyPath("int", type: .Int)
                make.propertyForKeyPath("string", type: .String)
                make.propertyForKeyPath("float", type: .Float)
                make.propertyForKeyPath("double", type: .Double)
                make.propertyForKeyPath("number", type: .Number)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = (
                "Parser Validation Error - Value for key path [uint] is of incorrect type\n" +
                    "Value for key path [int] is of incorrect type\n" +
                    "Value for key path [string] is of incorrect type\n" +
                    "Value for key path [float] is of incorrect type\n" +
                    "Value for key path [double] is of incorrect type\n" +
                "Value for key path [number] is of incorrect type"
            )

            XCTAssertEqual(expectedValue, actualValue, "Parser error message did not match expected value")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatItParsesMultiLevelKeyPaths() {
        // Given
        let data = ParserTestUtilities.loadJSONDataForFileNamed("KeyPathsTest")

        // When
        do {
            let _ = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("keypath", type: .String)
                make.propertyForKeyPath("two.level", type: .String)
                make.propertyForKeyPath("multi.level.key.path", type: .String)
                make.propertyForKeyPath("numb3r", type: .String)
                make.propertyForKeyPath("speci@l", type: .String)
                make.propertyForKeyPath("dashed-key-path", type: .String)
                make.propertyForKeyPath("twoLevelNumb3r.speci@l", type: .String)
            }

            // Then
            return
        } catch {
            XCTFail("Parser failed to parse key paths")
        }
    }

    func testThatItParsesArray() {
        // Given


        // When


        // Then
    }
}
