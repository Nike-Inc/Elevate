//
//  PerformanceTests.swift
//
//  Copyright (c) 2015-2016 Nike (http://www.nike.com)
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
        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        let dataArray: [AnyObject] = {
            var array: [AnyObject] = []
            for _ in 0...1000 {
                array.append(json.copy())
            }
            return array
        }()

        self.measureBlock {
            // When
            try! Parser.parseProperties(json: dataArray) { make in
                make.propertyForKeyPath("", type: .Array, decodedToType: PerformanceDecodable.self)
            }
        }
    }
}

private class PerformanceDecodable: Decodable {

    static let dateDecoder = DateDecoder(dateFormatString: BaseTestCase.DateFormats.Format1)

    required init(json: AnyObject) throws {
        let _ = try Parser.parseProperties(json: json) { make in
            make.propertyForKeyPath("testUInt", type: ParserPropertyType.UInt)
            make.propertyForKeyPath("testInt", type: .Int)
            make.propertyForKeyPath("testString", type: .String)
            make.propertyForKeyPath("testStringInt", type: .String, decoder: StringToIntDecoder())
            make.propertyForKeyPath("testStringIntNegative", type: .String, decoder: StringToIntDecoder())
            make.propertyForKeyPath("testFloat", type: .Float)
            make.propertyForKeyPath("testDouble", type: .Double)
            make.propertyForKeyPath("testNull", type: .String, optional: true)
            make.propertyForKeyPath("testDictionary", type: .Dictionary)
            make.propertyForKeyPath("testDate", type: .String, decoder: PerformanceDecodable.dateDecoder)
            make.propertyForKeyPath("testURL", type: .URL)
            make.propertyForKeyPath("sub-object", type: .Dictionary, decoder: ValidDecoder())
            make.propertyForKeyPath("arrayOfInts", type: .Array, decodedToType: Int.self)
        }
    }
}
