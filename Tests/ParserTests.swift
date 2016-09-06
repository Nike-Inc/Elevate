//
//  ParserTests.swift
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

class ParserTestCase: BaseTestCase {
    func testThatItParsesValuesForAllPropertyTypes() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")
        let dateDecoder = DateDecoder(dateFormatString: DateFormats.Format1)

        // When
        do {
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "testUInt", type: ParserPropertyType.uint)
                make.property(forKeyPath: "testInt", type: .int)
                make.property(forKeyPath: "testString", type: .string)
                make.property(forKeyPath: "testStringInt", type: .string, decoder: StringToIntDecoder())
                make.property(forKeyPath: "testStringIntNegative", type: .string, decoder: StringToIntDecoder())
                make.property(forKeyPath: "testFloat", type: .float)
                make.property(forKeyPath: "testDouble", type: .double)
                make.property(forKeyPath: "testNull", type: .string, optional: true)
                make.property(forKeyPath: "testDictionary", type: .dictionary)
                make.property(forKeyPath: "testDate", type: .string, decoder: dateDecoder)
                make.property(forKeyPath: "testURL", type: .url)
                make.property(forKeyPath: "sub-object", type: .dictionary, decoder: ValidDecoder())
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

            let jsonDictionary = properties["testDictionary"] as! [String: Any]

            XCTAssertEqual(jsonDictionary["key1"] as? String, "value1", "Parsed Dictionary<String, Any> did not equal value from json file.")
            XCTAssertTrue(properties["sub-object"] is TestObject, "Parsed sub object did not contain value of correct type")

            if let subObject = properties["sub-object"] as? TestObject {
                XCTAssertEqual(subObject.subUInt, UInt(1), "Parsed sub object value did not equal value from json file.")
                XCTAssertEqual(subObject.subInt, -1, "Parsed sub object value did not equal value from json file.")
                XCTAssertEqual(subObject.subString, "sub test string", "Parsed sub object value did not equal value from json file.")
            } else {
                XCTFail("subObject should not be nil")
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormats.Format1
            let parsedDate = properties["testDate"] as! Date
            let testDate = dateFormatter.date(from: "2015-01-30 at 13:00")
            XCTAssertTrue(parsedDate == testDate, "Parsed NSDate did not equal value from json file.")

            let expectedURL = URL(string: "http://apple.com")?.absoluteString ?? "default expected URL"
            let actualURL = (properties["testURL"] as? URL)?.absoluteString ?? "default actual URL"
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
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "testOptional", type: .string, optional: true)
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
            let _ = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "uint", type: .uint)
                make.property(forKeyPath: "int", type: .int)
                make.property(forKeyPath: "string", type: .string)
                make.property(forKeyPath: "float", type: .float)
                make.property(forKeyPath: "double", type: .double)
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
            let _ = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "uint", type: .uint)
                make.property(forKeyPath: "int", type: .int)
                make.property(forKeyPath: "string", type: .string)
                make.property(forKeyPath: "float", type: .float)
                make.property(forKeyPath: "double", type: .double)
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
        let data: Data! = "not json data".data(using: String.Encoding.utf8)

        // When
        do {
            _ = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "foo", type: .string)
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
            _ = try Parser.parseProperties(from: badJSON) { make in
                make.property(forKeyPath: "foo", type: .string)
            }

            XCTFail("Parser unexpectedly succeeded")
        } catch let error as ParserError {
            // Then
            let actualValue = error.description
            let expectedValue = "Parser Validation Error - JSON object was not of type: Data, [String: Any] or [Any]"
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
            _ = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "items", type: .array)
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
            _ = try Parser.parseProperties(from: json) { make in
                make.property(forKeyPath: "invalidURL", type: .url)
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
            _ = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "missingKeyPath", type: .string)
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
            let _ = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "keypath", type: .string)
                make.property(forKeyPath: "two.level", type: .string)
                make.property(forKeyPath: "multi.level.key.path", type: .string)
                make.property(forKeyPath: "numb3r", type: .string)
                make.property(forKeyPath: "speci@l", type: .string)
                make.property(forKeyPath: "dashed-key-path", type: .string)
                make.property(forKeyPath: "twoLevelNumb3r.speci@l", type: .string)
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
            let parsed = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "dots.key.path", type: .string)
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
            let results: [TestObject] = try Parser.parseArray(from: data, withKeyPath: "", decoder: ValidDecoder())

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
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "rootString", type: .string)
                make.property(forKeyPath: "rootInt", type: .int)
                make.property(forKeyPath: "items", type: .array, decoder: ValidDecoder(toDictionary: true))
            }

            // Then
            XCTAssertTrue(properties["rootString"] is String, "Parsed root string was of incorrect type.")
            XCTAssertTrue(properties["rootInt"] is Int, "Parsed root int was of incorrect type.")

            XCTAssertTrue((properties["items"] as! [Any]).count == 3, "Incorrect number of elements in testArrayParser()")

            for (index, item) in (properties["items"] as! [Any]).enumerated() {
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
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "arrayOfStrings", type: .array, decodableType: String.self)
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
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "arrayOfInts", type: .array, decodableType: Int.self)
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
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "arrayOfUInts", type: .array, decodableType: UInt.self)
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
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "arrayOfDoubles", type: .array, decodableType: Double.self)
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
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "arrayOfFloats", type: .array, decodableType: Float.self)
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
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "arrayOfBools", type: .array, decodableType: Bool.self)
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
            let _ = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "rootString", type: .string)
                make.property(forKeyPath: "rootInt", type: .int)
                make.property(forKeyPath: "items", type: .array, decoder: InvalidDecoder())
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
            let properties = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "testURL", type: .url)
            }

            // Then
            let actualURL = properties["testURL"] as? URL
            let expectedURL = URL(string: "http://apple.com")
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
            let testObject: TestObject = try Parser.parseObject(from: data, withKeyPath: "sub-object")

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
                from: data,
                withKeyPath: "sub-object",
                decoder: TestObjectDecoder()
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
            let testObjects: [TestObject] = try Parser.parseArray(from: data, withKeyPath: "items")

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
                from: data,
                withKeyPath: "items",
                decoder: TestObjectDecoder()
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
        let dataValues: [Data] = {
            var values = [Data]()

            var intValue: Int = 1000
            let intData = NSData(bytes: &intValue, length: MemoryLayout<Int>.size)
            values.append(intData as Data)

            var uIntValue: UInt = 1000
            let uIntData = NSData(bytes: &uIntValue, length: MemoryLayout<UInt>.size)
            values.append(uIntData as Data)

            var doubleValue: Double = 123.456
            let doubleData = NSData(bytes: &doubleValue, length: MemoryLayout<Double>.size)
            values.append(doubleData as Data)

            var floatValue: Float = -987.345
            let floatData = NSData(bytes: &floatValue, length: MemoryLayout<Float>.size)
            values.append(floatData as Data)

            var boolValue = false
            let boolData = NSData(bytes: &boolValue, length: MemoryLayout<Bool>.size)
            values.append(boolData as Data)

            let stringData = "Some random string".data(using: String.Encoding.utf8, allowLossyConversion: false)!
            values.append(stringData)

            return values
        }()

        // When
        for dataValue in dataValues {
            do {
                _ = try Parser.parseProperties(from: dataValue) { make in
                    make.property(forKeyPath: "not_real_value", type: .int)
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
            let parsed = try Parser.parseProperties(from: data) { make in
                make.property(forKeyPath: "intMin", type: .int)
                make.property(forKeyPath: "intMax", type: .int)
                make.property(forKeyPath: "intMin32Bit", type: .int)
                make.property(forKeyPath: "intMax32Bit", type: .int)
                make.property(forKeyPath: "uintMin", type: .uint)
                make.property(forKeyPath: "uintMax", type: .uint)
                make.property(forKeyPath: "float", type: .float)
                make.property(forKeyPath: "double", type: .double)

                make.property(forKeyPath: "boolFalse", type: .bool)
                make.property(forKeyPath: "boolTrue", type: .bool)

                make.property(forKeyPath: "intZero", type: .int)
                make.property(forKeyPath: "uintZero", type: .uint)
                make.property(forKeyPath: "floatZero", type: .float)
                make.property(forKeyPath: "doubleZero", type: .double)

                make.property(forKeyPath: "intOne", type: .int)
                make.property(forKeyPath: "uintOne", type: .uint)
                make.property(forKeyPath: "floatOne", type: .float)
                make.property(forKeyPath: "doubleOne", type: .double)

                make.property(forKeyPath: "intMinusOne", type: .int)
                make.property(forKeyPath: "uintMinusOne", type: .uint)
                make.property(forKeyPath: "floatMinusOne", type: .float)
                make.property(forKeyPath: "doubleMinusOne", type: .double)
            }

            // Then
            if MemoryLayout<Int>.size == MemoryLayout<Int32>.size { // 32-bit
                XCTAssertEqual(parsed["intMin32Bit"] as? Int, Int.min, "Parsed [intMin32Bit] did not equal `Int.min`.")
                XCTAssertEqual(parsed["intMax32Bit"] as? Int, Int.max, "Parsed [intMax32Bit] did not equal `Int.max`.")
            } else if MemoryLayout<Int>.size == MemoryLayout<Int64>.size { // 64-bit
                XCTAssertEqual(parsed["intMin"] as? Int, Int.min, "Parsed [intMin] did not equal `Int.min`.")
                XCTAssertEqual(parsed["intMax"] as? Int, Int.max, "Parsed [intMax] did not equal `Int.max`.")
            }
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
