//
//  Decodable.swift
//  Elevate
//
//  Created by Eric Appel on 8/4/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

// MARK: - Decodable Protocol Definition

// TODO: Add docstring
public protocol Decodable {
    init(json: AnyObject) throws
}

// MARK: - Primative Decodables

extension String: Decodable {
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .String) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: String")
        }

        self = json as! String
    }
}

extension Int: Decodable {
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .Int) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Int")
        }

        self = (json as! NSNumber).integerValue
    }
}

extension UInt: Decodable {
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .UInt) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: UInt")
        }

        self = (json as! NSNumber).unsignedLongValue
    }
}

extension Float: Decodable {
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .Float) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Float")
        }

        self = (json as! NSNumber).floatValue
    }
}

extension Double: Decodable {
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .Double) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Double")
        }

        self = (json as! NSNumber).doubleValue
    }
}

extension Bool: Decodable {
    public init(json: AnyObject) throws {
        guard Parser.valueIsSpecifiedType(value: json, type: .Bool) else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Bool")
        }

        self = (json as! NSNumber).boolValue
    }
}