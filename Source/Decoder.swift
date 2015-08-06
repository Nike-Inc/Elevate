//
//  Decoder.swift
//  Elevate
//
//  Created by Eric Appel on 8/5/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

// MARK: Decoder Protocol Definition

// TODO: Add docstring
public protocol Decoder {
    func decodeObject(object: AnyObject) throws -> Any
}

// MARK: - Supplied Decoders

/**
Decodes a String to an Int.
*/
public class StringToIntDecoder: Decoder {

    /**
    Converts the `String` object to an `Int`.

    - parameter object: The `String` to decode.

    - returns: The decoded `Int` or throws.
    */
    public func decodeObject(object: AnyObject) throws -> Any {
        if let
            intString = object as? String,
            intValue = Int(intString)
        {
            return intValue
        }

        throw ParserError.Validation(failureReason: "Could not convert String to Int")
    }
}

/**
The date decoder converts a `String` into an `NSDate` object using the provided date format string
or `NSDateFormatter`.
*/
public class DateDecoder: Decoder {
    private let dateFormatter: NSDateFormatter

    /**
    Creates a data decoder with the given date format string.

    - parameter dateFormatString: The date format string.

    - returns: The date decoder.
    */
    public init(dateFormatString: String) {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateFormat = dateFormatString
    }

    /**
    Creates a date decoder with the given date formatter.

    - parameter dateFormatter: A `NSDateFormatter` instance.

    - returns: The date decoder.
    */
    public init(dateFormatter: NSDateFormatter) {
        self.dateFormatter = dateFormatter
    }

    /**
    Decodes the data parameter into an `NSDate`.

    - parameter data: The string to parse. MUST be of type `String` or `NSString`.

    - returns: The parsed date.
    */
    public func decodeObject(data: AnyObject) throws -> Any {
        if let string = data as? String {
            return try dateFromString(string, withFormatter:self.dateFormatter)
        } else {
            let description = "DateParser object to parse was not a String."
            throw ParserError.Validation(failureReason: description)
        }
    }

    private func dateFromString<T>(string: String, withFormatter formatter: NSDateFormatter) throws -> T {
        let date = formatter.dateFromString(string)

        if let date = date {
            return date as! T
        }

        let description = "DateParser string could not be parsed to NSDate with the given formatter."
        throw ParserError.Validation(failureReason: description)
    }
}
