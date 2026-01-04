//
//  Note.swift
//  pixelboop
//
//  Created by AI Agent on 2026-01-03.
//

import Foundation

/// Musical note (chromatic scale, 12 semitones)
enum Note: Int, CaseIterable, Codable {
    case C = 0
    case Cs = 1
    case D = 2
    case Ds = 3
    case E = 4
    case F = 5
    case Fs = 6
    case G = 7
    case Gs = 8
    case A = 9
    case As = 10
    case B = 11

    /// Display name for UI and VoiceOver
    var displayName: String {
        switch self {
        case .C: return "C"
        case .Cs: return "C♯"
        case .D: return "D"
        case .Ds: return "D♯"
        case .E: return "E"
        case .F: return "F"
        case .Fs: return "F♯"
        case .G: return "G"
        case .Gs: return "G♯"
        case .A: return "A"
        case .As: return "A♯"
        case .B: return "B"
        }
    }
}
