//
//  ScaleTests.swift
//  pixelboopTests
//
//  Created by AI Agent on 2026-01-03.
//

import XCTest
@testable import pixelboop

final class ScaleTests: XCTestCase {

    func test_majorScaleIntervals() {
        let scale = Scale.major
        XCTAssertEqual(scale.intervals, [0, 2, 4, 5, 7, 9, 11])
    }

    func test_minorScaleIntervals() {
        let scale = Scale.minor
        XCTAssertEqual(scale.intervals, [0, 2, 3, 5, 7, 8, 10])
    }

    func test_pentatonicScaleIntervals() {
        let scale = Scale.pentatonic
        XCTAssertEqual(scale.intervals, [0, 2, 4, 7, 9])
    }

    func test_scaleDisplayNames() {
        XCTAssertEqual(Scale.major.displayName, "Major")
        XCTAssertEqual(Scale.minor.displayName, "Minor")
        XCTAssertEqual(Scale.pentatonic.displayName, "Pentatonic")
    }

    func test_scaleRawValues() {
        XCTAssertEqual(Scale.major.rawValue, "Major")
        XCTAssertEqual(Scale.minor.rawValue, "Minor")
        XCTAssertEqual(Scale.pentatonic.rawValue, "Pentatonic")
    }

    func test_scaleFromRawValue() {
        XCTAssertEqual(Scale(rawValue: "Major"), .major)
        XCTAssertEqual(Scale(rawValue: "Minor"), .minor)
        XCTAssertEqual(Scale(rawValue: "Pentatonic"), .pentatonic)
        XCTAssertNil(Scale(rawValue: "Invalid"))
    }

    func test_scaleAllCases() {
        XCTAssertEqual(Scale.allCases.count, 3)
        XCTAssertTrue(Scale.allCases.contains(.major))
        XCTAssertTrue(Scale.allCases.contains(.minor))
        XCTAssertTrue(Scale.allCases.contains(.pentatonic))
    }
}
