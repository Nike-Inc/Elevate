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

        measure {
            // When
            let _: [String: Any] = try! Parser.parseProperties(from: dataArray) { make in
                make.property(forKeyPath: "", type: .array, decodableType: PerformanceDecodable.self)
            }
        }
    }
}

// MARK: -

private class PerformanceDecodable: Decodable {
    static let dateDecoder = DateDecoder(dateFormatString: BaseTestCase.DateFormats.Format1)

    required init(json: AnyObject) throws {
        let _ = try Parser.parseProperties(from: json) { make in
            make.property(forKeyPath: "testUInt", type: ParserPropertyType.uint)
            make.property(forKeyPath: "testInt", type: .int)
            make.property(forKeyPath: "testString", type: .string)
            make.property(forKeyPath: "testStringInt", type: .string, decoder: StringToIntDecoder())
            make.property(forKeyPath: "testStringIntNegative", type: .string, decoder: StringToIntDecoder())
            make.property(forKeyPath: "testFloat", type: .float)
            make.property(forKeyPath: "testDouble", type: .double)
            make.property(forKeyPath: "testNull", type: .string, optional: true)
            make.property(forKeyPath: "testDictionary", type: .dictionary)
            make.property(forKeyPath: "testDate", type: .string, decoder: PerformanceDecodable.dateDecoder)
            make.property(forKeyPath: "testURL", type: .url)
            make.property(forKeyPath: "sub-object", type: .dictionary, decoder: ValidDecoder())
            make.property(forKeyPath: "arrayOfInts", type: .array, decodableType: Int.self)
        }
    }
}
