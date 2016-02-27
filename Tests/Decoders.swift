//
//  Decoders.swift
//  Elevate
//
//  Created by Christian Noon on 2/27/16.
//  Copyright © 2016 Nike. All rights reserved.
//

import Elevate
import Foundation

struct TestObjectDecoder: Decoder {
    func decodeObject(object: AnyObject) throws -> Any {
        struct KeyPath {
            static let subUInt = "subUInt"
            static let subInt = "subInt"
            static let subString = "subString"
        }

        let properties = try Parser.parseProperties(json: object) { make in
            make.propertyForKeyPath(KeyPath.subUInt, type: .UInt)
            make.propertyForKeyPath(KeyPath.subInt, type: .Int)
            make.propertyForKeyPath(KeyPath.subString, type: .String)
        }

        return TestObject(
            subUInt: properties <-! KeyPath.subUInt,
            subInt: properties <-! KeyPath.subInt,
            subString: properties <-! KeyPath.subString
        )
    }
}
