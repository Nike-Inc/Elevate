//
//  PerformanceTests.swift
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

class PerformanceTestCase: BaseTestCase {
    func testThatItParsesValuesForAllPropertyTypesInSufficientTime() {
        // Given
        let data = loadJSONDataForFileNamed("PropertyTypesTest")
        let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)

        let dataArray: [Any] = (0...1000).map { _ in json }

        self.measure {
            // When
            _ = try! Parser.parseProperties(json: dataArray) { make in
                make.propertyForKeyPath("", type: .array, decodedToType: PerformanceDecodable.self)
            }
        }
    }
}

// MARK: -

private class PerformanceDecodable: Decodable {
    static let dateDecoder = DateDecoder(dateFormatString: BaseTestCase.DateFormats.Format1)

    required init(json: AnyObject) throws {
        let _ = try Parser.parseProperties(json: json) { make in
            make.propertyForKeyPath("testUInt", type: ParserPropertyType.uInt)
            make.propertyForKeyPath("testInt", type: .int)
            make.propertyForKeyPath("testString", type: .string)
            make.propertyForKeyPath("testStringInt", type: .string, decoder: StringToIntDecoder())
            make.propertyForKeyPath("testStringIntNegative", type: .string, decoder: StringToIntDecoder())
            make.propertyForKeyPath("testFloat", type: .float)
            make.propertyForKeyPath("testDouble", type: .double)
            make.propertyForKeyPath("testNull", type: .string, optional: true)
            make.propertyForKeyPath("testDictionary", type: .dictionary)
            make.propertyForKeyPath("testDate", type: .string, decoder: PerformanceDecodable.dateDecoder)
            make.propertyForKeyPath("testURL", type: .url)
            make.propertyForKeyPath("sub-object", type: .dictionary, decoder: ValidDecoder())
            make.propertyForKeyPath("arrayOfInts", type: .array, decodedToType: Int.self)
        }
    }
}
