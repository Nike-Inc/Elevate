//
//  PerformanceTests.swift
//  Elevate
//
//  Created by Eric Appel on 12/29/15.
//  Copyright © 2015 Nike. All rights reserved.
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
