//
//  ParserError.swift
//  Elevate
//
//  Created by Eric Appel on 8/5/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

// TODO: Add docstring
public enum ParserError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    case Deserialization(failureReason: String)
    case Validation(failureReason: String)

    // TODO: Add docstring
    public var failureReason: String {
        switch self {
        case .Deserialization(let failureReason):
            return failureReason
        case .Validation(let failureReason):
            return failureReason
        }
    }

    // TODO: Add docstring
    public var description: String {
        switch self {
        case .Deserialization(let failureReason):
            return "Parser Deserialization Error - \(failureReason)"
        case .Validation(let failureReason):
            return "Parser Validation Error - \(failureReason)"
        }
    }

    // TODO: Add docstring
    public var debugDescription: String {
        return self.description
    }
}