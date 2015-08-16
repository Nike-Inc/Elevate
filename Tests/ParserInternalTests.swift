//
//  InternalParserTests.swift
//  Elevate
//
//  Created by Eric Appel on 8/16/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import XCTest
@testable import Elevate

class ParserInternalTests: BaseTestCase {
    func testThatSpecifiedTypeCheckFailsForInvalidValue() {
        class ComplexType {}

        // Given
        let value = ComplexType()

        // When
        let isSpecifiedType = Parser.valueIsSpecifiedType(value: value, type: .Dictionary)

        // Then
        XCTAssertFalse(isSpecifiedType, "Invalid value for specified type was returned as valid")
    }
}
