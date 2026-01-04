//
//  Scale.swift
//  pixelboop
//
//  Created by AI Agent on 2026-01-03.
//

import Foundation

/// Musical scale types supported by the sequencer
enum Scale: String, CaseIterable, Codable {
    case major = "Major"
    case minor = "Minor"
    case pentatonic = "Pentatonic"

    var displayName: String {
        rawValue
    }

    /// Semitone intervals from root note
    /// - major: Ionian mode (W-W-H-W-W-W-H)
    /// - minor: Aeolian mode (W-H-W-W-H-W-W)
    /// - pentatonic: Major pentatonic (5-note scale)
    var intervals: [Int] {
        switch self {
        case .major:
            return [0, 2, 4, 5, 7, 9, 11]
        case .minor:
            return [0, 2, 3, 5, 7, 8, 10]
        case .pentatonic:
            return [0, 2, 4, 7, 9]
        }
    }
}
