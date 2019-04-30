//
//  ModelObjects.swift
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

extension TestObject: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(subUInt.hashValue)
        hasher.combine(subInt.hashValue)
        hasher.combine(subString.hashValue)
    }
}

func ==(lhs: TestObject, rhs: TestObject) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// MARK: -

extension TestObject: Elevate.Encodable, Elevate.Decodable {
    private struct KeyPath {
        static let subUInt = "subUInt"
        static let subInt = "subInt"
        static let subString = "subString"
    }

    var json: Any {
        return [
            KeyPath.subUInt: subUInt,
            KeyPath.subInt: subInt,
            KeyPath.subString: subString
        ]
    }

    init(json: Any) throws {
        let entity = try Parser.parseEntity(json: json) { schema in
            schema.addProperty(keyPath: KeyPath.subUInt, type: .uint)
            schema.addProperty(keyPath: KeyPath.subInt, type: .int)
            schema.addProperty(keyPath: KeyPath.subString, type: .string)
        }

        subUInt = entity <-! KeyPath.subUInt
        subInt = entity <-! KeyPath.subInt
        subString = entity <-! KeyPath.subString
    }
}

// MARK: -

struct InvalidDecodable {
    let invalid: String
}

// MARK: -

extension InvalidDecodable: Elevate.Decodable {
    init(json: Any) throws {
        let invalidKeyPath = "invalid"

        let entity = try Parser.parseEntity(json: json) { schema in
            schema.addProperty(keyPath: invalidKeyPath, type: .string)
        }

        invalid = entity[invalidKeyPath] as! String
    }
}

// MARK: -

struct ErrorThrowingDecodable {}

// MARK: -

extension ErrorThrowingDecodable: Elevate.Decodable {
    init(json: Any) throws {
        throw NSError(domain: "Decodable Test Error", code: 42, userInfo: nil)
    }
}
