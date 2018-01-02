//
//  SchemaPropertyExtraction.swift
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

import Foundation

precedencegroup DictionaryExtractionPrecedence {
    associativity: left
    higherThan: NilCoalescingPrecedence
}

infix operator <-! : DictionaryExtractionPrecedence
infix operator <-? : DictionaryExtractionPrecedence

infix operator <--! : DictionaryExtractionPrecedence
infix operator <--? : DictionaryExtractionPrecedence

/// Forcibly extracts the value for the key from the dictionary as the specified type.
///
/// - Parameters:
///   - lhs: Dictionary to extract the value from.
///   - rhs: Key of the value to extract from the dictionary.
///
/// - Returns: Value for the key in the dictionary.
public func <-! <T>(lhs: [String: Any], rhs: String) -> T {
    return lhs[rhs] as! T
}

/// Safely extracts the value for the key from the dictionary as the specified optional type.
///
/// - Parameters:
///   - lhs: Dictionary to extract the value from.
///   - rhs: Key of the value to extract from the dictionary.
///
/// - Returns: Value for the key in the dictionary.
public func <-? <T>(lhs: [String: Any], rhs: String) -> T? {
    return lhs[rhs] as? T
}

/// Forcibly extracts the array for the key from the dictionary as the specified array type.
///
/// - Parameters:
///   - lhs: Dictionary to extract the array from.
///   - rhs: Key of the array to extract from the dictionary.
///
/// - Returns: Array for the key in the dictionary.
public func <--! <T>(lhs: [String: Any], rhs: String) -> [T] {
    guard let array = lhs[rhs] else { return [] }
    return array as! [T]
}

/// Safely extracts the array for the key from the dictionary as the specified optional array type.
///
/// - Parameters:
///   - lhs: Dictionary to extract the array from.
///   - rhs: Key of the array to extract from the dictionary.
///
/// - Returns: Array for the key in the dictionary.
public func <--? <T>(lhs: [String: Any], rhs: String) -> [T]? {
    guard let array = lhs[rhs] else { return nil }
    return array as? [T]
}
