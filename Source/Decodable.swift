//
//  Decodable.swift
//  Elevate
//
//  Created by Eric Appel on 8/4/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

// MARK: Decodable Protocol Definition

/**
    The `Decodable` protocol declares an interface used to create an instance of an object from an `AnyObject` to be 
    parsed.
*/
public protocol Decodable {
    /**
        Initializes an instance of the object using the given json object.
    
        - parameter json: The data to be parsed.
    
        - throws: A ParserError.Validation or ParserError.Deserialization if decoding fails.
    */
    init(json: AnyObject) throws
}

// MARK: - Primative Decodables

/**
    The primative decodables implemented below are used by the parser when parsing an array of primative values. The 
    input is expected to be of the same type as the object and will be validated and cast as such.
*/

extension String: Decodable {
    /**
        Implements the `Decodable` protocol for the `String` type. Expects input to be a `String`.
    
        - parameter json: A `String` instance.
        
        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .String) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: String")
        }

        self = json as! String
    }
}

extension Int: Decodable {
    /**
        Implements the `Decodable` protocol for the `Int` type. Expects input to be an `Int`.

        - parameter json: An `Int` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .Int) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Int")
        }

        self = (json as! NSNumber).integerValue
    }
}

extension UInt: Decodable {
    /**
        Implements the `Decodable` protocol for the `UInt` type. Expects input to be a `UInt`.

        - parameter json: A `UInt` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .UInt) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: UInt")
        }

        self = (json as! NSNumber).unsignedLongValue
    }
}

extension Float: Decodable {
    /**
        Implements the `Decodable` protocol for the `Float` type. Expects input to be a `Float`.

        - parameter json: A `Float` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .Float) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Float")
        }

        self = (json as! NSNumber).floatValue
    }
}

extension Double: Decodable {
    /**
        Implements the `Decodable` protocol for the `Double` type. Expects input to be a `Double`.

        - parameter json: A `Double` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .Double) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Double")
        }

        self = (json as! NSNumber).doubleValue
    }
}

extension Bool: Decodable {
    /**
        Implements the `Decodable` protocol for the `Bool` type. Expects input to be a `Bool`.

        - parameter json: A `Bool` instance.

        - throws: A ParserError.Validation error if decoding fails.
    */
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .Bool) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Bool")
        }

        self = (json as! NSNumber).boolValue
    }
}
