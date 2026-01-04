//
//  NoteTests.swift
//  pixelboopTests
//
//  Created by AI Agent on 2026-01-03.
//

import XCTest
@testable import pixelboop

final class NoteTests: XCTestCase {

    func test_noteRawValues() {
        XCTAssertEqual(Note.C.rawValue, 0)
        XCTAssertEqual(Note.Cs.rawValue, 1)
        XCTAssertEqual(Note.D.rawValue, 2)
        XCTAssertEqual(Note.Ds.rawValue, 3)
        XCTAssertEqual(Note.E.rawValue, 4)
        XCTAssertEqual(Note.F.rawValue, 5)
        XCTAssertEqual(Note.Fs.rawValue, 6)
        XCTAssertEqual(Note.G.rawValue, 7)
        XCTAssertEqual(Note.Gs.rawValue, 8)
        XCTAssertEqual(Note.A.rawValue, 9)
        XCTAssertEqual(Note.As.rawValue, 10)
        XCTAssertEqual(Note.B.rawValue, 11)
    }

    func test_noteDisplayNames() {
        XCTAssertEqual(Note.C.displayName, "C")
        XCTAssertEqual(Note.Cs.displayName, "C♯")
        XCTAssertEqual(Note.D.displayName, "D")
        XCTAssertEqual(Note.Ds.displayName, "D♯")
        XCTAssertEqual(Note.E.displayName, "E")
        XCTAssertEqual(Note.F.displayName, "F")
        XCTAssertEqual(Note.Fs.displayName, "F♯")
        XCTAssertEqual(Note.G.displayName, "G")
        XCTAssertEqual(Note.Gs.displayName, "G♯")
        XCTAssertEqual(Note.A.displayName, "A")
        XCTAssertEqual(Note.As.displayName, "A♯")
        XCTAssertEqual(Note.B.displayName, "B")
    }

    func test_noteFromRawValue() {
        XCTAssertEqual(Note(rawValue: 0), .C)
        XCTAssertEqual(Note(rawValue: 5), .F)
        XCTAssertEqual(Note(rawValue: 11), .B)
        XCTAssertNil(Note(rawValue: 12))
        XCTAssertNil(Note(rawValue: -1))
    }

    func test_noteAllCases() {
        XCTAssertEqual(Note.allCases.count, 12)
        for i in 0..<12 {
            XCTAssertNotNil(Note(rawValue: i))
        }
    }
}
