//
//  ParserError.swift
//  Elevate
//
//  Created by Eric Appel on 8/5/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

/**
    The error types that can be thrown in Elevate

    - Deserialization:  An error that occurs from deserializing using `NSJSONSerialization`.
    - Validation:       An error that occurs when one or more values fail validation.
*/
public enum ParserError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    case Deserialization(failureReason: String)
    case Validation(failureReason: String)

    /// The failure reason String
    public var failureReason: String {
        switch self {
        case .Deserialization(let failureReason):
            return failureReason
        case .Validation(let failureReason):
            return failureReason
        }
    }

    /// The description of the failure reason
    public var description: String {
        switch self {
        case .Deserialization(let failureReason):
            return "Parser Deserialization Error - \(failureReason)"
        case .Validation(let failureReason):
            return "Parser Validation Error - \(failureReason)"
        }
    }

    /// The debug description of the failure reason
    public var debugDescription: String {
        return self.description
    }
}