//
//  Decoders.swift
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

struct TestObjectDecoder: Elevate.Decoder {
    func decode(_ object: Any) throws -> Any {
        struct KeyPath {
            static let subUInt = "subUInt"
            static let subInt = "subInt"
            static let subString = "subString"
        }

        let entity = try Parser.parseEntity(json: object) { schema in
            schema.addProperty(keyPath: KeyPath.subUInt, type: .uint)
            schema.addProperty(keyPath: KeyPath.subInt, type: .int)
            schema.addProperty(keyPath: KeyPath.subString, type: .string)
        }

        return TestObject(
            subUInt: entity <-! KeyPath.subUInt,
            subInt: entity <-! KeyPath.subInt,
            subString: entity <-! KeyPath.subString
        )
    }
}

// MARK: -

struct ErrorThrowingDecoder: Elevate.Decoder {
    func decode(_ object: Any) throws -> Any {
        throw NSError(domain: "Decoder Test Error", code: 42, userInfo: nil)
    }
}
