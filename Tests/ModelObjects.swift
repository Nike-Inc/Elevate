//
//  ModelObjects.swift
//  Elevate
//
//  Created by Christian Noon on 2/27/16.
//  Copyright © 2016 Nike. All rights reserved.
//

import Elevate
import Foundation

struct TestObject {
    let subUInt: UInt
    let subInt: Int
    let subString: String

    init(subUInt: UInt, subInt: Int, subString: String) {
        self.subUInt = subUInt
        self.subInt = subInt
        self.subString = subString
    }
}

// MARK: -

extension TestObject: Decodable {
    init(json: AnyObject) throws {
        let subUIntKeyPath = "subUInt"
        let subIntKeyPath = "subInt"
        let subStringKeyPath = "subString"

        let properties = try Parser.parseProperties(json: json) { make in
            make.propertyForKeyPath(subUIntKeyPath, type: .UInt)
            make.propertyForKeyPath(subIntKeyPath, type: .Int)
            make.propertyForKeyPath(subStringKeyPath, type: .String)
        }

        subUInt = properties <-! subUIntKeyPath
        subInt = properties <-! subIntKeyPath
        subString = properties <-! subStringKeyPath
    }
}

// MARK: -

struct InvalidDecodable {
    let invalid: String
}

// MARK: -

extension InvalidDecodable: Decodable {
    init(json: AnyObject) throws {
        let invalidKeyPath = "invalid"

        let properties = try Parser.parseProperties(json: json) { make in
            make.propertyForKeyPath(invalidKeyPath, type: .String)
        }

        invalid = properties[invalidKeyPath] as! String
    }
}
