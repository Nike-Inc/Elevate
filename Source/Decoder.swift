//
//  Decoder.swift
//  Elevate
//
//  Created by Eric Appel on 8/5/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

// MARK: Decoder Protocol Definition

/**
    The `Decoder` protocol declares an interface used to parse an `AnyObject` to an `Any`, which is typically a model
    object.
*/
public protocol Decoder {
    /**
        Parses the given object into a value of type `T`.

        - parameter object: The object to parse.

        - throws:  A ParserError.Validation error if object decoding fails.
        - returns: The parsed object.
    */
    func decodeObject(object: AnyObject) throws -> Any
}

// MARK: - Supplied Decoders

/**
    Decodes a String to an Int.
*/
public class StringToIntDecoder: Decoder {

    /**
        Creates a new instance of the `StringToIntDecoder`.

        - returns: The new `StringToIntDecoder` instance.
    */
    public init() {}

    /**
        Converts the `String` object to an `Int`.

        - parameter object: The `String` to decode.

        - throws:  A ParserError.Validation error if int decoding fails.
        - returns: The decoded `Int`.
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

        - throws: ParserError.Validation
        - returns: The parsed date.
    */
    public func decodeObject(data: AnyObject) throws -> Any {
        guard let string = data as? String else {
            let description = "DateParser object to parse was not a String."
            throw ParserError.Validation(failureReason: description)
        }

        return try dateFromString(string, withFormatter:self.dateFormatter)
    }

    private func dateFromString(string: String, withFormatter formatter: NSDateFormatter) throws -> Any {
        let date = formatter.dateFromString(string)

        if let date = date {
            return date
        }

        let description = "DateParser string could not be parsed to NSDate with the given formatter."
        throw ParserError.Validation(failureReason: description)
    }
}
