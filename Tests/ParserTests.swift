//
//  ParserTests.swift
//
//  Copyright (c) 2015-2016 Nike (https://developer.nike.com)
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
                make.propertyForKeyPath("testStringInt", type: .String, decoder: StringToIntDecoder())
                make.propertyForKeyPath("testStringIntNegative", type: .String, decoder: StringToIntDecoder())
                make.propertyForKeyPath("testFloat", type: .Float)
                make.propertyForKeyPath("testDouble", type: .Double)
                make.propertyForKeyPath("testNull", type: .String, optional: true)
                make.propertyForKeyPath("testDictionary", type: .Dictionary)
                make.propertyForKeyPath("testDate", type: .String, decoder: dateDecoder)
                make.propertyForKeyPath("testURL", type: .URL)
                make.propertyForKeyPath("sub-object", type: .Dictionary, decoder: ValidDecoder())
            }

            // Then
            XCTAssertEqual(properties["testUInt"] as? UInt, UInt(1), "Parsed UInt value did not equal value from json file.")
            XCTAssertEqual(properties["testInt"] as? Int, -1, "Parsed Int value did not equal value from json file.")
            XCTAssertEqual(properties["testString"] as? String, "test string", "Parsed String value did not equal value from json file.")
            XCTAssertEqual(properties["testStringInt"] as? Int, 100, "Parsed StringToIntDecoder value did not equal value from json file.")
            XCTAssertEqual(properties["testStringIntNegative"] as? Int, -100, "Parsed StringToIntDecoder value did not equal value from json file.")
            XCTAssertEqual(properties["testFloat"] as? Float, Float(1.1111), "Parsed Float did not equal value from json file.")
            XCTAssertEqual(properties["testDouble"] as? Double, 1.1111, "Parsed Double did not equal value from json file.")
            XCTAssertTrue(properties["testNull"] == nil, "Parsed value did not equal nil from json file.")

            let jsonDictionary = properties["testDictionary"] as! [String: AnyObject]

            XCTAssertEqual(jsonDictionary["key1"] as? String, "value1", "Parsed Dictionary<String, AnyObject> did not equal value from json file.")
            XCTAssertTrue(properties["sub-object"] is TestObject, "Parsed sub object did not contain value of correct type")

            if let subObject = properties["sub-object"] as? TestObject {
                XCTAssertEqual(subObject.subUInt, UInt(1), "Parsed sub object value did not equal value from json file.")
                XCTAssertEqual(subObject.subInt, -1, "Parsed sub object value did not equal value from json file.")
                XCTAssertEqual(subObject.subString, "sub test string", "Parsed sub object value did not equal value from json file.")
            } else {
                XCTFail("subObject should not be nil")
            }

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

    func testThatItAllowsOptionalValues() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("testOptional", type: .String, optional: true)
            }

            XCTAssertTrue(properties.keys.count == 0, "Parser unexpectedly returned key for missing optional")
        } catch {
            XCTFail("Parser threw when it should have allowed an optional to be null")
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
                    "Value for key path [double] is of incorrect type"
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
                    "Value for key path [double] is of incorrect type"
            )

            XCTAssertEqual(expectedValue, actualValue, "Parser error message did not match expected value")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatItGeneratesADeserializationErrorForInvalidData() {
        // Given
        let data: NSData! = "not json data".dataUsingEncoding(NSUTF8StringEncoding)

        // When
        do {
            try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("foo", type: .String)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Deserialization Error - JSON data deserialization failed with error:"
            XCTAssertTrue(actualValue.hasPrefix(expectedValue), "JSON deserialization message did not contain expected value")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatItGeneratesAValidationErrorForJSONOfWrongType() {
        // Given
        let badJSON = 1

        // When
        do {
            try Parser.parseProperties(json: badJSON) { make in
                make.propertyForKeyPath("foo", type: .String)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - JSON object was not of type: [String: AnyObject] or [AnyObject]"
            XCTAssertEqual(actualValue, expectedValue, "Parser json type error value did not match")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatItGeneratesAnErrorForMissingArrayDecoder() {
        // Given
        let data = loadJSONDataForFileNamed("ArrayTest")

        // When
        do {
            try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("items", type: .Array)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - A decoding method was not provided for `items` array"
            XCTAssertEqual(actualValue, expectedValue, "Parser missing array decoder error did not match expected value")
        } catch {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatItGeneratesAnErrorForAnInvalidURLValue() {
        // Given
        let json = [
            "invalidURL": "💩"
        ]

        // When
        do {
            try Parser.parseProperties(json: json) { make in
                make.propertyForKeyPath("invalidURL", type: .URL)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - Required key path [invalidURL] could not be parsed to valid URL"
            XCTAssertEqual(actualValue, expectedValue, "Parser error for invalid URL did not match expected value")
        } catch  {
            XCTFail("Parser error was of incorrect type")
        }
    }

    func testThatParserErrorDebugDescriptionMatchesDescription() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("missingKeyPath", type: .String)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            XCTAssertEqual(error.description, error.debugDescription, "ParserError debugDescription did not match description")
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

    func testThatItParsesKeyPathsWithDots() {
        // Given
        let data = loadJSONDataForFileNamed("KeyPathsTest")

        // When
        do {
            let parsed = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("dots.key.path", type: .String)
            }

            // Then
            XCTAssertEqual(parsed["dots.key.path"] as! String?, "value")
        } catch {
            XCTFail("Parser failed to parse dotted key path")
        }
    }

    func testThatItParserRootArrayWithParseMethod() {
        // Given
        let data = loadJSONDataForFileNamed("RootArrayTest")

        // When
        do {
            let results: [TestObject] = try Parser.parseArray(data: data, forKeyPath: "", withDecoder: ValidDecoder())

            // Then
            XCTAssertEqual(results[0].subInt, 0)
            XCTAssertEqual(results[1].subString, "value1")
            XCTAssertEqual(results[2].subUInt, 2)
        } catch {
            XCTFail("Parser unexpectedly returned an error")
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
                make.propertyForKeyPath("items", type: .Array, decoder: ValidDecoder(toDictionary: true))
            }

            // Then
            XCTAssertTrue(properties["rootString"] is String, "Parsed root string was of incorrect type.")
            XCTAssertTrue(properties["rootInt"] is Int, "Parsed root int was of incorrect type.")

            XCTAssertTrue((properties["items"] as! [Any]).count == 3, "Incorrect number of elements in testArrayParser()")

            for (index, item) in (properties["items"] as! [Any]).enumerate() {
                let dict = item as! [String: Any]
                XCTAssertEqual(dict["subUInt"] as? UInt, UInt(index), "Array UInt object value was incorrect")
                XCTAssertEqual(dict["subInt"] as? Int, index, "Array Int object value was incorrect")
                XCTAssertEqual(dict["subString"] as? String, "value\(index)", "Array string object value was incorrect")
            }
        } catch {
            XCTFail("Parser failed to parse array")
        }
    }

    func testThatItParsesArrayOfStrings() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("arrayOfStrings", type: .Array, decodedToType: String.self)
            }

            // Then
            let values = (properties["arrayOfStrings"] as! [Any]).map { $0 as! String }
            XCTAssertEqual(values[0], "array", "Array of Strings object was incorrect")
            XCTAssertEqual(values[1], "of", "Array of Strings object was incorrect")
            XCTAssertEqual(values[2], "strings", "Array of Strings object was incorrect")
        }
        catch {
            XCTFail("Parse failed unexpectedly")
        }
    }

    func testThatItParsesArrayOfInts() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("arrayOfInts", type: .Array, decodedToType: Int.self)
            }

            // Then
            let values = (properties["arrayOfInts"] as! [Any]).map { $0 as! Int }
            XCTAssertEqual(values[0], 0, "Array of Ints object was incorrect")
            XCTAssertEqual(values[1], 1, "Array of Ints object was incorrect")
            XCTAssertEqual(values[2], 2, "Array of Ints object was incorrect")
        }
        catch let error {
            print(error)
            XCTFail("Parse failed unexpectedly")
        }
    }

    func testThatItParsesArrayOfUInts() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("arrayOfUInts", type: .Array, decodedToType: UInt.self)
            }

            // Then
            let values = (properties["arrayOfUInts"] as! [Any]).map { $0 as! UInt }
            XCTAssertEqual(values[0], 0, "Array of UInts object was incorrect")
            XCTAssertEqual(values[1], 1, "Array of UInts object was incorrect")
            XCTAssertEqual(values[2], 2, "Array of UInts object was incorrect")
        } catch {
            XCTFail("Parse failed unexpectedly")
        }
    }

    func testThatItParsesArrayOfDoubles() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("arrayOfDoubles", type: .Array, decodedToType: Double.self)
            }

            // Then
            let values = (properties["arrayOfDoubles"] as! [Any]).map { $0 as! Double }
            XCTAssertEqual(values[0], -1.1, "Array of Doubles object was incorrect")
            XCTAssertEqual(values[1], 0, "Array of Doubles object was incorrect")
            XCTAssertEqual(values[2], 1.1, "Array of Doubles object was incorrect")
        }
        catch {
            XCTFail("Parse failed unexpectedly")
        }
    }

    func testThatItParsesArrayOfFloats() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("arrayOfFloats", type: .Array, decodedToType: Float.self)
            }

            // Then
            let values = (properties["arrayOfFloats"] as! [Any]).map { $0 as! Float }
            XCTAssertEqual(values[0], -1.1, "Array of Floats object was incorrect")
            XCTAssertEqual(values[1], 0, "Array of Floats object was incorrect")
            XCTAssertEqual(values[2], 1.1, "Array of Floats object was incorrect")
        }
        catch {
            XCTFail("Parse failed unexpectedly")
        }
    }

    func testThatItParsesArrayOfBools() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")

        // When
        do {
            let properties = try Parser.parseProperties(data: data) { make in
                make.propertyForKeyPath("arrayOfBools", type: .Array, decodedToType: Bool.self)
            }

            // Then
            let values = (properties["arrayOfBools"] as! [Any]).map { $0 as! Bool }
            XCTAssertEqual(values[0], true, "Array of Bools object was incorrect")
            XCTAssertEqual(values[1], true, "Array of Bools object was incorrect")
            XCTAssertEqual(values[2], false, "Array of Bools object was incorrect")
        }
        catch {
            XCTFail("Parse failed unexpectedly")
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
                "Parser Validation Error - Error parsing array object at index 0 with parser [ElevateTests.InvalidDecoder]\n" +
                    "Value for key path [subUInt] is of incorrect type\n" +
                    "Required key path [missingSubInt] was missing or null\n" +
                    "--\n" +
                    "Error parsing array object at index 1 with parser [ElevateTests.InvalidDecoder]\n" +
                    "Value for key path [subUInt] is of incorrect type\n" +
                    "Required key path [missingSubInt] was missing or null\n" +
                    "--\n" +
                    "Error parsing array object at index 2 with parser [ElevateTests.InvalidDecoder]\n" +
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

class ParserParseObjectTestCase: BaseTestCase {
    func testThatParserCanParseDecodableObject() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("PropertyTypesTest")

            // When
            let testObject: TestObject = try Parser.parseObject(data: data, forKeyPath: "sub-object")

            // Then
            XCTAssertEqual(testObject.subUInt, UInt(1))
            XCTAssertEqual(testObject.subInt, -1)
            XCTAssertEqual(testObject.subString, "sub test string")
        } catch {
            XCTFail("Test encountered unexpected error: \(error)")
        }
    }

    func testThatParserCanParseObjectUsingDecoder() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("PropertyTypesTest")

            // When
            let testObject: TestObject = try Parser.parseObject(
                data: data,
                forKeyPath: "sub-object",
                withDecoder: TestObjectDecoder()
            )

            // Then
            XCTAssertEqual(testObject.subUInt, UInt(1))
            XCTAssertEqual(testObject.subInt, -1)
            XCTAssertEqual(testObject.subString, "sub test string")
        } catch {
            XCTFail("Test encountered unexpected error: \(error)")
        }
    }
}

// MARK: -

class ParserParseArrayTestCaseCase: BaseTestCase {
    func testThatParserCanParseDecodableArray() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("ArrayTest")

            // When
            let testObjects: [TestObject] = try Parser.parseArray(data: data, forKeyPath: "items")

            // Then
            XCTAssertEqual(testObjects.count, 3)

            if testObjects.count == 3 {
                XCTAssertEqual(testObjects[0].subUInt, 0)
                XCTAssertEqual(testObjects[0].subInt, 0)
                XCTAssertEqual(testObjects[0].subString, "value0")

                XCTAssertEqual(testObjects[1].subUInt, 1)
                XCTAssertEqual(testObjects[1].subInt, 1)
                XCTAssertEqual(testObjects[1].subString, "value1")

                XCTAssertEqual(testObjects[2].subUInt, 2)
                XCTAssertEqual(testObjects[2].subInt, 2)
                XCTAssertEqual(testObjects[2].subString, "value2")
            }
        } catch {
            XCTFail("Test encountered unexpected error: \(error)")
        }
    }

    func testThatParserCanParseArrayUsingDecoder() {
        do {
            // Given
            let data = loadJSONDataForFileNamed("ArrayTest")

            // When
            let testObjects: [TestObject] = try Parser.parseArray(
                data: data,
                forKeyPath: "items",
                withDecoder: TestObjectDecoder()
            )

            // Then
            XCTAssertEqual(testObjects.count, 3)

            if testObjects.count == 3 {
                XCTAssertEqual(testObjects[0].subUInt, 0)
                XCTAssertEqual(testObjects[0].subInt, 0)
                XCTAssertEqual(testObjects[0].subString, "value0")

                XCTAssertEqual(testObjects[1].subUInt, 1)
                XCTAssertEqual(testObjects[1].subInt, 1)
                XCTAssertEqual(testObjects[1].subString, "value1")

                XCTAssertEqual(testObjects[2].subUInt, 2)
                XCTAssertEqual(testObjects[2].subInt, 2)
                XCTAssertEqual(testObjects[2].subString, "value2")
            }
        } catch {
            XCTFail("Test encountered unexpected error: \(error)")
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
                let prefix = "JSON data deserialization failed with error:"
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
                make.propertyForKeyPath("floatZero", type: .Float)
                make.propertyForKeyPath("doubleZero", type: .Double)

                make.propertyForKeyPath("intOne", type: .Int)
                make.propertyForKeyPath("uintOne", type: .UInt)
                make.propertyForKeyPath("floatOne", type: .Float)
                make.propertyForKeyPath("doubleOne", type: .Double)

                make.propertyForKeyPath("intMinusOne", type: .Int)
                make.propertyForKeyPath("uintMinusOne", type: .UInt)
                make.propertyForKeyPath("floatMinusOne", type: .Float)
                make.propertyForKeyPath("doubleMinusOne", type: .Double)
            }

            // Then
            XCTAssertEqual(parsed["intMin"] as? Int, Int.min, "Parsed [intMin] did not equal `Int.min`.")
            XCTAssertEqual(parsed["intMax"] as? Int, Int.max, "Parsed [intMax] did not equal `Int.max`.")
            XCTAssertEqual(parsed["uintMin"] as? UInt, UInt.min, "Parsed [uintMin] did not equal `UInt.min`.")
            XCTAssertEqual(parsed["uintMax"] as? UInt, UInt.max, "Parsed [uintMax] did not equal `UInt.max`.")
            XCTAssertEqual(parsed["float"] as? Float, Float(4123.6789), "Parsed [float] did not equal expected value.")
            XCTAssertEqual(parsed["double"] as? Double, Double(-123456.789), "Parsed [double] did not equal expected value.")

            XCTAssertFalse(parsed["boolFalse"] as! Bool, "Parsed [boolFalse] was not `false`.")
            XCTAssertTrue(parsed["boolTrue"] as! Bool, "Parsed [boolTrue] was not `true`.")

            XCTAssertEqual(parsed["intZero"] as? Int, Int(0), "Parsed [intZero] did not equal expected value.")
            XCTAssertEqual(parsed["uintZero"] as? UInt, UInt(0), "Parsed [uintZero] did not equal expected value.")
            XCTAssertEqual(parsed["floatZero"] as? Float, Float(0.0), "Parsed [floatZero] did not equal expected value.")
            XCTAssertEqual(parsed["doubleZero"] as? Double, Double(0.0), "Parsed [doubleZero] did not equal expected value.")

            XCTAssertEqual(parsed["intOne"] as? Int, Int(1), "Parsed [intOne] did not equal expected value.")
            XCTAssertEqual(parsed["uintOne"] as? UInt, UInt(1), "Parsed [uintOne] did not equal expected value.")
            XCTAssertEqual(parsed["floatOne"] as? Float, Float(1.0), "Parsed [floatOne] did not equal expected value.")
            XCTAssertEqual(parsed["doubleOne"] as? Double, Double(1.0), "Parsed [doubleOne] did not equal expected value.")

            XCTAssertEqual(parsed["intMinusOne"] as? Int, Int(-1), "Parsed [intMinusOne] did not equal expected value.")
            XCTAssertEqual(parsed["uintMinusOne"] as? UInt, UInt.max, "Parsed [uintMinusOne] did not equal expected value.")
            XCTAssertEqual(parsed["floatMinusOne"] as? Float, Float(-1.0), "Parsed [floatMinusOne] did not equal expected value.")
            XCTAssertEqual(parsed["doubleMinusOne"] as? Double, Double(-1.0), "Parsed [doubleMinusOne] did not equal expected value.")
        } catch {
            XCTFail("Parser unexpectedly returned an error")
        }
    }
}
