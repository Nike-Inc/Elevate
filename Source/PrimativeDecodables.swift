//
//  PrimativeDecodables.swift
//  Elevate
//
//  Created by Eric Appel on 8/4/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

extension String: Decodable {
    public init(json: AnyObject) throws {
        guard let stringValue: String = json as? String else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: String")
        }

        self = stringValue
    }
}

extension Int: Decodable {
    public init(json: AnyObject) throws {
        guard let intValue = (json as? NSNumber)?.integerValue else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Int")
        }

        self = intValue
    }
}

extension Int64: Decodable {
    public init(json: AnyObject) throws {
        guard let int64Value = (json as? NSNumber)?.longLongValue else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Int64")
        }

        self = int64Value
    }
}

extension UInt: Decodable {
    public init(json: AnyObject) throws {
        guard let uintValue = (json as? NSNumber)?.unsignedLongValue else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: UInt")
        }

        self = uintValue
    }
}

extension Float: Decodable {
    public init(json: AnyObject) throws {
        guard let floatValue = (json as? NSNumber)?.floatValue else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Float")
        }

        self = floatValue
    }
}

extension Double: Decodable {
    public init(json: AnyObject) throws {
        guard let doubleValue = (json as? NSNumber)?.doubleValue else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Double")
        }

        self = doubleValue
    }
}

extension Bool: Decodable {
    public init(json: AnyObject) throws {
        guard let boolValue = (json as? NSNumber)?.boolValue else {
            throw ParserError.Validation(failureReason: "JSON object was not of type: Bool")
        }

        self = boolValue
    }
}