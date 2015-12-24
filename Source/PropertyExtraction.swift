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

infix operator <--! { associativity left precedence 140 }
infix operator <--? { associativity left precedence 140 }

/**
    Forcibly extracts the value for the key from the dictionary as the specified type.

    - parameter lhs: Dictionary to extract the value from.
    - parameter rhs: Key of the value to extract from the dictionary.

    - returns: Value for the key in the dictionary.
*/
public func <-! <T>(lhs: [String: Any], rhs: String) -> T {
    return lhs[rhs] as! T
}

/**
    Safely extracts the value for the key from the dictionary as the specified optional type.

    - parameter lhs: Dictionary to extract the value from.
    - parameter rhs: Key of the value to extract from the dictionary.

    - returns: Value for the key in the dictionary.
*/
public func <-? <T>(lhs: [String: Any], rhs: String) -> T? {
    return lhs[rhs] as? T
}

/**
    Forcibly extracts the array for the key from the dictionary as the specified array type.

    - parameter lhs: Dictionary to extract the array from.
    - parameter rhs: Key of the array to extract from the dictionary.

    - returns: Array for the key in the dictionary.
*/
public func <--! <T>(lhs: [String: Any], rhs: String) -> [T] {
    guard let array = lhs[rhs] else { return [] }
    return (array as! [Any]).map { $0 as! T }
}

/**
    Safely extracts the array for the key from the dictionary as the specified optional array type.

    - parameter lhs: Dictionary to extract the array from.
    - parameter rhs: Key of the array to extract from the dictionary.

    - returns: Array for the key in the dictionary.
*/
public func <--? <T>(lhs: [String: Any], rhs: String) -> [T]? {
    guard let array = lhs[rhs] else { return nil }
    return (array as? [Any])?.map { $0 as! T }
}
