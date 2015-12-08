//
//  PropertyExtraction.swift
//  Elevate
//
//  Created by Christian Noon on 12/7/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

infix operator <-! { associativity left precedence 140 }
infix operator <-? { associativity left precedence 140 }
infix operator <-- { associativity left precedence 140 }

public func <-! <T>(lhs: [String: Any], rhs: String) -> T {
    return lhs[rhs] as! T
}

public func <-? <T>(lhs: [String: Any], rhs: String) -> T? {
    return lhs[rhs] as? T
}

public func <-- <T>(lhs: [String: Any], rhs: String) -> [T] {
    guard let array = lhs[rhs] else { return [] }
    return (array as! [Any]).map { $0 as! T }
}

// MARK: -

extension CollectionType where
    Self: DictionaryLiteralConvertible,
    Self.Key: StringLiteralConvertible,
    Self.Value: Any,
    Generator.Element == (Self.Key, Self.Value)
{
    public func valueForKeyPath<T>(keyPath: String) -> T {
        let dictionary = self as! Dictionary<String, Any>
        return dictionary[keyPath] as! T
    }

    public func optionalValueForKeyPath<T>(keyPath: String) -> T? {
        let dictionary = self as! Dictionary<String, Any>
        return dictionary[keyPath] as? T
    }

    public func arrayForKeyPath<T>(keyPath: String) -> [T] {
        let dictionary = self as! Dictionary<String, Any>
        guard let array = dictionary[keyPath] else { return [] }

        return (array as! [Any]).map { $0 as! T }
    }
}
