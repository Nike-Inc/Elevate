//
//  ParserError.swift
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

import Foundation

/**
    The error types that can be thrown in Elevate.

    - Deserialization: An error that occurs from deserializing using `NSJSONSerialization`.
    - Validation:      An error that occurs when one or more values fail validation.
*/
public enum ParserError: Error, CustomStringConvertible, CustomDebugStringConvertible {
    case deserialization(failureReason: String)
    case validation(failureReason: String)

    /// The failure reason String.
    public var failureReason: String {
        switch self {
        case .deserialization(let failureReason):
            return failureReason
        case .validation(let failureReason):
            return failureReason
        }
    }

    /// The description of the failure reason.
    public var description: String {
        switch self {
        case .deserialization(let failureReason):
            return "Parser Deserialization Error - \(failureReason)"
        case .validation(let failureReason):
            return "Parser Validation Error - \(failureReason)"
        }
    }

    /// The debug description of the failure reason.
    public var debugDescription: String {
        return self.description
    }
}
