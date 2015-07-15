//
//  ParserTests.swift
//  Elevate
//
//  Created by Eric Appel on 7/14/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Elevate
import Foundation
import XCTest

class ParserTestCase: BaseTestCase {
    func testThatItParsesValuesForAllPropertyTypes() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")
        let dateDecoder = DateDecoder(dateFormatString: DateFormats.Format1)

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
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
                make.propertyForKeyPath("sub-object", type: .Dictionary, decoder: ValidDecoder())
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
        let data = loadJSONDataForFileNamed("PropertyTypesWithIncorrectValueTypes")

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
        let data = loadJSONDataForFileNamed("PropertyTypesWithIncorrectValueTypes")

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
        let data = loadJSONDataForFileNamed("KeyPathsTest")

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
        let data = loadJSONDataForFileNamed("ArrayTest")

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("rootString", type: .String)
                make.propertyForKeyPath("rootInt", type: .Int)
                make.propertyForKeyPath("items", type: .Array, decoder: ValidDecoder())
            }

            // Then
            XCTAssertTrue(properties["rootString"] is String, "Parsed root string was of incorrect type.")
            XCTAssertTrue(properties["rootInt"] is Int, "Parsed root int was of incorrect type.")

            XCTAssertTrue((properties["items"] as! [Any]).count == 3, "Incorrect number of elements in testArrayParser()")

            for (index, item) in (properties["items"] as! [Any]).enumerate() {
                let dict = item as! [String: Any]
                XCTAssertEqual(dict["subUInt"] as! UInt, UInt(index), "Array UInt object value was incorrect")
                XCTAssertEqual(dict["subInt"] as! Int, index, "Array Int object value was incorrect")
                XCTAssertEqual(dict["subString"] as! String, "value\(index)", "Array string object value was incorrect")
            }
        } catch {
            XCTFail("Parser failed to parse array")
        }
    }

    func testThatItAggregatesErrorsWhenDecodingArrayWithInvalidDecoder() {
        // Given
        let data = loadJSONDataForFileNamed("ArrayTest")

        // When
        do {
            let _ = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("rootString", type: .String)
                make.propertyForKeyPath("rootInt", type: .Int)
                make.propertyForKeyPath("items", type: .Array, decoder: InvalidDecoder())
            }

            XCTFail("Array parser succeeded unexpectedly")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = (
                "Parser Validation Error - Error parsing array object at index 0 with parser [Elevate_Tests.InvalidDecoder]\n" +
                    "Value for key path [subUInt] is of incorrect type\n" +
                    "Required key path [missingSubInt] was missing or null\n" +
                    "--\n" +
                    "Error parsing array object at index 1 with parser [Elevate_Tests.InvalidDecoder]\n" +
                    "Value for key path [subUInt] is of incorrect type\n" +
                    "Required key path [missingSubInt] was missing or null\n" +
                    "--\n" +
                    "Error parsing array object at index 2 with parser [Elevate_Tests.InvalidDecoder]\n" +
                    "Value for key path [subUInt] is of incorrect type\n" +
                    "Required key path [missingSubInt] was missing or null\n" +
                "--"
            )

            XCTAssertEqual(actualValue, expectedValue, "error message did not match expected value.")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatItParsesURL() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("testURL", type: .URL)
            }

            // Then
            let actualURL = properties["testURL"] as? NSURL
            let expectedURL = NSURL(string: "http://apple.com")
            if let actualURL = actualURL {
                XCTAssertEqual(actualURL.absoluteString, expectedURL!.absoluteString, "Parsed URL did not equal value from json file.")
            } else {
                XCTFail("Parsed URL was unexpectedly nil")
            }
        } catch {
            XCTFail("Parser unexpectedly returned an error")
        }
    }
}

// MARK: -

class ParserJSONFragmentDataTestCase: BaseTestCase {
    func testThatItFailsToParseDataFragments() {
        // Given
        let dataValues: [NSData] = {
            var values = [NSData]()

            var intValue: Int = 1000
            let intData = NSData(bytes: &intValue, length: sizeof(Int))
            values.append(intData)

            var uIntValue: UInt = 1000
            let uIntData = NSData(bytes: &uIntValue, length: sizeof(UInt))
            values.append(uIntData)

            var doubleValue: Double = 123.456
            let doubleData = NSData(bytes: &doubleValue, length: sizeof(Double))
            values.append(doubleData)

            var floatValue: Float = -987.345
            let floatData = NSData(bytes: &floatValue, length: sizeof(Float))
            values.append(floatData)

            var boolValue = false
            let boolData = NSData(bytes: &boolValue, length: sizeof(Bool))
            values.append(boolData)

            let stringData = "Some random string".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            values.append(stringData)

            return values
        }()

        // When
        for dataValue in dataValues {
            do {
                try Parser.parseProperties(data: dataValue) { make in
                    make.propertyForKeyPath("not_real_value", type: .Int)
                }

                XCTFail("Parser succeeded unexpectedly")
            } catch let error as ParserError {
                let prefix = "JSON data serialization failed with error:"
                XCTAssertTrue(error.failureReason.hasPrefix(prefix), "Error failure reason prefix does not match")
            } catch {
                XCTFail("Parser error was of incorrect type")
            }
        }
    }
}

// MARK: -

class ParserJSONNumericDataTestCase: BaseTestCase {
    func testThatItHandlesAllTypesOfNumericData() {
        // Given
        let data = loadJSONDataForFileNamed("JSONNumericData")

        // When
        do {
            let parsed = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("intMin", type: .Int)
                make.propertyForKeyPath("intMax", type: .Int)
                make.propertyForKeyPath("uintMin", type: .UInt)
                make.propertyForKeyPath("uintMax", type: .UInt)
                make.propertyForKeyPath("float", type: .Float)
                make.propertyForKeyPath("double", type: .Double)

                make.propertyForKeyPath("boolFalse", type: .Bool)
                make.propertyForKeyPath("boolTrue", type: .Bool)

                make.propertyForKeyPath("intZero", type: .Int)
                make.propertyForKeyPath("uintZero", type: .UInt)
                make.propertyForKeyPath("numberZero", type: .Number)
                make.propertyForKeyPath("floatZero", type: .Float)
                make.propertyForKeyPath("doubleZero", type: .Double)

                make.propertyForKeyPath("intOne", type: .Int)
                make.propertyForKeyPath("uintOne", type: .UInt)
                make.propertyForKeyPath("numberOne", type: .Number)
                make.propertyForKeyPath("floatOne", type: .Float)
                make.propertyForKeyPath("doubleOne", type: .Double)

                make.propertyForKeyPath("intMinusOne", type: .Int)
                make.propertyForKeyPath("uintMinusOne", type: .UInt)
                make.propertyForKeyPath("numberMinusOne", type: .Number)
                make.propertyForKeyPath("floatMinusOne", type: .Float)
                make.propertyForKeyPath("doubleMinusOne", type: .Double)
            }

            // Then
            XCTAssertEqual(parsed["intMin"] as! Int, Int.min, "Parsed [intMin] did not equal `Int.min`.")
            XCTAssertEqual(parsed["intMax"] as! Int, Int.max, "Parsed [intMax] did not equal `Int.max`.")
            XCTAssertEqual(parsed["uintMin"] as! UInt, UInt.min, "Parsed [uintMin] did not equal `UInt.min`.")
            XCTAssertEqual(parsed["uintMax"] as! UInt, UInt.max, "Parsed [uintMax] did not equal `UInt.max`.")
            XCTAssertEqual(parsed["float"] as! Float, Float(4123.6789), "Parsed [float] did not equal expected value.")
            XCTAssertEqual(parsed["double"] as! Double, Double(-123456.789), "Parsed [double] did not equal expected value.")

            XCTAssertFalse(parsed["boolFalse"] as! Bool, "Parsed [boolFalse] was not `false`.")
            XCTAssertTrue(parsed["boolTrue"] as! Bool, "Parsed [boolTrue] was not `true`.")

            XCTAssertEqual(parsed["intZero"] as! Int, Int(0), "Parsed [intZero] did not equal expected value.")
            XCTAssertEqual(parsed["uintZero"] as! UInt, UInt(0), "Parsed [uintZero] did not equal expected value.")
            XCTAssertEqual(parsed["numberZero"] as! NSNumber, NSNumber(integer: 0), "Parsed [numberZero] did not equal expected value.")
            XCTAssertEqual(parsed["floatZero"] as! Float, Float(0.0), "Parsed [floatZero] did not equal expected value.")
            XCTAssertEqual(parsed["doubleZero"] as! Double, Double(0.0), "Parsed [doubleZero] did not equal expected value.")

            XCTAssertEqual(parsed["intOne"] as! Int, Int(1), "Parsed [intOne] did not equal expected value.")
            XCTAssertEqual(parsed["uintOne"] as! UInt, UInt(1), "Parsed [uintOne] did not equal expected value.")
            XCTAssertEqual(parsed["numberOne"] as! NSNumber, NSNumber(integer: 1), "Parsed [numberOne] did not equal expected value.")
            XCTAssertEqual(parsed["floatOne"] as! Float, Float(1.0), "Parsed [floatOne] did not equal expected value.")
            XCTAssertEqual(parsed["doubleOne"] as! Double, Double(1.0), "Parsed [doubleOne] did not equal expected value.")

            XCTAssertEqual(parsed["intMinusOne"] as! Int, Int(-1), "Parsed [intMinusOne] did not equal expected value.")
            XCTAssertEqual(parsed["uintMinusOne"] as! UInt, UInt.max, "Parsed [uintMinusOne] did not equal expected value.")
            XCTAssertEqual(parsed["numberMinusOne"] as! NSNumber, NSNumber(integer: -1), "Parsed [numberMinusOne] did not equal expected value.")
            XCTAssertEqual(parsed["floatMinusOne"] as! Float, Float(-1.0), "Parsed [floatMinusOne] did not equal expected value.")
            XCTAssertEqual(parsed["doubleMinusOne"] as! Double, Double(-1.0), "Parsed [doubleMinusOne] did not equal expected value.")
        } catch {
            XCTFail("Parser unexpectedly returned an error")
        }
    }
}
