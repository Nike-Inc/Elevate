//
//  ElevateBaseTestCase.swift
//  Elevate
//
//  Created by Eric Appel on 7/14/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation
import XCTest

public class BaseTestCase: XCTestCase {

    struct DateFormats {
        static let Format1 = "yyyy-MM-dd 'at' HH:mm"
    }

    func loadJSONDataForFileNamed(filename: String) -> NSData {
        let bundle = NSBundle(forClass: BaseTestCase.self)
        let path = bundle.pathForResource(filename, ofType: "json")
        return NSData(contentsOfFile: path!)!
    }

}
