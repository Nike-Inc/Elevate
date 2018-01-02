//
//  PerformanceTests.swift
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

class PerformanceTestCase: BaseTestCase {
    func testThatItParsesValuesForAllPropertyTypesInSufficientTime() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")
        let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)

        let dataArray: [Any] = (0...1000).map { _ in json }

        measure {
            // When
            _ = try! Parser.parseEntity(json: dataArray) { schema in
                schema.addProperty(keyPath: "", type: .array, decodableType: PerformanceDecodable.self)
            }
        }
    }
}

// MARK: -

private class PerformanceDecodable: Elevate.Decodable {
    static let dateDecoder = DateDecoder(dateFormatString: BaseTestCase.DateFormats.Format1)

    required init(json: Any) throws {
        let _ = try Parser.parseEntity(json: json) { schema in
            schema.addProperty(keyPath: "testUInt", type: SchemaPropertyProtocol.uint)
            schema.addProperty(keyPath: "testInt", type: .int)
            schema.addProperty(keyPath: "testString", type: .string)
            schema.addProperty(keyPath: "testStringInt", type: .string, decoder: StringToIntDecoder())
            schema.addProperty(keyPath: "testStringIntNegative", type: .string, decoder: StringToIntDecoder())
            schema.addProperty(keyPath: "testFloat", type: .float)
            schema.addProperty(keyPath: "testDouble", type: .double)
            schema.addProperty(keyPath: "testNull", type: .string, optional: true)
            schema.addProperty(keyPath: "testDictionary", type: .dictionary)
            schema.addProperty(keyPath: "testDate", type: .string, decoder: PerformanceDecodable.dateDecoder)
            schema.addProperty(keyPath: "testURL", type: .url)
            schema.addProperty(keyPath: "sub-object", type: .dictionary, decoder: ValidDecoder())
            schema.addProperty(keyPath: "arrayOfInts", type: .array, decodableType: Int.self)
        }
    }
}
