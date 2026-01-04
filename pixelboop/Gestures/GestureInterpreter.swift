//
//  GestureInterpreter.swift
//  pixelboop
//
//  Gesture interpretation system matching prototype lines 473-605
//  Converts touch gestures into musical patterns
//

import Foundation

// MARK: - Gesture Types

enum GestureType: String {
    case tap           // Single note
    case accent        // Hold for accent
    case arpeggio      // Horizontal on chords
    case run           // Horizontal on melody
    case walking       // Horizontal on bass
    case roll          // Horizontal on rhythm
    case stack         // Vertical chord
    case multi         // Vertical on rhythm
    case fifth         // Vertical on bass
    case phrase        // Diagonal on melody/chords
    case fill          // Diagonal on rhythm
    case sustain       // Hold + drag horizontal
    case erase         // Double-tap to erase
    case clear         // Shake or double-tap clear
    case swipeUndo     // Double-swipe left
    case swipeRedo     // Double-swipe right
}

// MARK: - Gesture Point

struct GesturePoint {
    let note: Int      // 0-11 (pitch index)
    let step: Int      // 0-31 (time step)
}

// MARK: - Generated Note

struct GeneratedNote {
    let note: Int      // 0-11
    let step: Int      // 0-31
    let velocity: Int  // 1=normal, 2=accent, 3=sustain
}

// MARK: - Gesture Interpreter

class GestureInterpreter {

    // MARK: - Scale Data (from prototype lines 20-24)

    static let scales: [Scale: [Int]] = [
        .major: [0, 2, 4, 5, 7, 9, 11],
        .minor: [0, 2, 3, 5, 7, 8, 10],
        .pentatonic: [0, 2, 4, 7, 9]
    ]

    // MARK: - Chord Intervals (from prototype lines 26-31)

    static let chordIntervals: [String: [Int]] = [
        "major": [0, 4, 7],
        "minor": [0, 3, 7],
        "maj7": [0, 4, 7, 11],
        "min7": [0, 3, 7, 10]
    ]

    // MARK: - Interpret Gesture (from prototype lines 473-605)

    /// Interpret a gesture and return notes to place
    /// - Parameters:
    ///   - start: Starting point of gesture
    ///   - end: Ending point of gesture
    ///   - track: Target track
    ///   - velocity: Base velocity (1=normal, 2=accent from hold)
    ///   - scale: Current scale
    ///   - rootNote: Current root note
    ///   - patternLength: Current pattern length
    /// - Returns: Tuple of (notes to place, gesture type)
    static func interpret(
        start: GesturePoint,
        end: GesturePoint,
        track: TrackType,
        velocity: Int,
        scale: Scale,
        rootNote: Note,
        patternLength: Int
    ) -> (notes: [GeneratedNote], gestureType: GestureType) {

        let dx = end.step - start.step
        let dy = end.note - start.note
        let absDx = abs(dx)
        let absDy = abs(dy)

        var notes: [GeneratedNote] = []
        var gestureType: GestureType = .tap

        // Get scale notes for current key
        let scaleNotes = getScaleNotes(scale: scale, rootNote: rootNote)

        // TAP GESTURE: Small or no movement (prototype lines 481-497)
        if absDx <= 1 && absDy <= 1 {
            if track == .rhythm {
                // Rhythm: single hit + optional follow-up
                notes.append(GeneratedNote(note: start.note, step: start.step, velocity: velocity))
                if start.step + 2 < patternLength {
                    notes.append(GeneratedNote(note: start.note, step: start.step + 2, velocity: 1))
                }
            } else if track == .bass {
                // Bass: root + fifth
                notes.append(GeneratedNote(note: start.note, step: start.step, velocity: velocity))
                notes.append(GeneratedNote(note: (start.note + 7) % 12, step: start.step, velocity: 1))
            } else if track == .chords {
                // Chords: full chord
                let chordType = scale == .minor ? "minor" : "major"
                for interval in chordIntervals[chordType] ?? [0, 4, 7] {
                    notes.append(GeneratedNote(note: (start.note + interval) % 12, step: start.step, velocity: velocity))
                }
            } else {
                // Melody: single note snapped to scale
                let snappedNote = snapToScale(note: start.note, scaleNotes: scaleNotes)
                notes.append(GeneratedNote(note: snappedNote, step: start.step, velocity: velocity))
            }
            gestureType = velocity > 1 ? .accent : .tap
        }
        // HORIZONTAL GESTURE (prototype lines 498-549)
        else if absDx > Int(Double(absDy) * 1.3) {
            let direction = dx > 0 ? 1 : -1
            let steps = min(absDx, 8)

            // SUSTAIN: Hold before dragging (velocity > 1) creates sustained note
            if velocity > 1 && track != .rhythm {
                let sustainNotes: [Int]
                if track == .chords {
                    let chordType = scale == .minor ? "minor" : "major"
                    sustainNotes = (chordIntervals[chordType] ?? [0, 4, 7]).map { (start.note + $0) % 12 }
                } else {
                    sustainNotes = [snapToScale(note: start.note, scaleNotes: scaleNotes)]
                }

                for i in 0...steps {
                    let step = (start.step + i * direction + patternLength) % patternLength
                    for n in sustainNotes {
                        // First note is accent (2), continuation is sustain (3)
                        notes.append(GeneratedNote(note: n, step: step, velocity: i == 0 ? 2 : 3))
                    }
                }
                gestureType = .sustain
            }
            // ARPEGGIO: Horizontal on chords (prototype lines 516-524)
            else if track == .chords {
                let chordNotes = chordIntervals["maj7"] ?? [0, 4, 7, 11]
                for i in 0...steps {
                    let noteIdx = i % chordNotes.count
                    let step = (start.step + i * direction + patternLength) % patternLength
                    notes.append(GeneratedNote(note: (start.note + chordNotes[noteIdx]) % 12, step: step, velocity: i == 0 ? velocity : 1))
                }
                gestureType = .arpeggio
            }
            // WALKING BASS: Horizontal on bass (prototype lines 524-532)
            else if track == .bass {
                let pattern = [0, 7, 4, 7]
                for i in 0...steps {
                    let interval = pattern[i % pattern.count]
                    let step = (start.step + i * direction + patternLength) % patternLength
                    notes.append(GeneratedNote(note: (start.note + interval) % 12, step: step, velocity: i % 2 == 0 ? velocity : 1))
                }
                gestureType = .walking
            }
            // ROLL: Horizontal on rhythm (prototype lines 532-538)
            else if track == .rhythm {
                for i in 0...steps {
                    let step = (start.step + i * direction + patternLength) % patternLength
                    notes.append(GeneratedNote(note: start.note, step: step, velocity: (i == 0 || i == steps) ? velocity : 1))
                }
                gestureType = .roll
            }
            // RUN: Horizontal on melody (prototype lines 538-549)
            else {
                var currentScaleIdx = scaleNotes.firstIndex(of: start.note % 12) ?? 0

                for i in 0...steps {
                    let scaleDirection = dy >= 0 ? 1 : -1
                    let scaleIdx = (currentScaleIdx + i * scaleDirection + scaleNotes.count * 10) % scaleNotes.count
                    let step = (start.step + i * direction + patternLength) % patternLength
                    notes.append(GeneratedNote(note: scaleNotes[scaleIdx], step: step, velocity: i == 0 ? velocity : 1))
                }
                gestureType = .run
            }
        }
        // VERTICAL GESTURE (prototype lines 551-570)
        else if absDy > Int(Double(absDx) * 1.3) {
            if track == .chords || track == .melody {
                // STACK: Vertical chord stack
                let chordNotes = chordIntervals["maj7"] ?? [0, 4, 7, 11]
                let span = min(absDy, chordNotes.count - 1)
                for i in 0...span {
                    notes.append(GeneratedNote(note: (start.note + chordNotes[i]) % 12, step: start.step, velocity: velocity))
                }
                gestureType = .stack
            } else if track == .bass {
                // FIFTH: Root + fifth
                notes.append(GeneratedNote(note: start.note, step: start.step, velocity: velocity))
                notes.append(GeneratedNote(note: (start.note + 5) % 12, step: start.step, velocity: 1))
                gestureType = .fifth
            } else {
                // MULTI: Multiple drums at same step
                let minN = min(start.note, end.note)
                let maxN = max(start.note, end.note)
                for n in minN...maxN {
                    notes.append(GeneratedNote(note: n, step: start.step, velocity: velocity))
                }
                gestureType = .multi
            }
        }
        // DIAGONAL GESTURE (prototype lines 572-601)
        else {
            let steps = max(absDx, absDy)

            if track == .melody || track == .chords {
                // PHRASE: Melodic phrase following scale
                var currentScaleIdx = scaleNotes.firstIndex(of: start.note % 12) ?? 0

                for i in 0...steps {
                    let t = Double(i) / Double(steps)
                    let step = Int(round(Double(start.step) + Double(dx) * t))
                    let noteOffset = Int(round(Double(dy) * t / 2))
                    let scaleIdx = (currentScaleIdx + noteOffset + scaleNotes.count * 10) % scaleNotes.count

                    if step >= 0 && step < patternLength {
                        notes.append(GeneratedNote(note: scaleNotes[scaleIdx], step: step, velocity: i == 0 ? velocity : 1))
                    }
                }
                gestureType = .phrase
            } else {
                // FILL: Diagonal fill
                let minS = min(start.step, end.step)
                let maxS = max(start.step, end.step)
                let minN = min(start.note, end.note)
                let maxN = max(start.note, end.note)

                for s in minS...maxS {
                    let t = maxS == minS ? 0.0 : Double(s - minS) / Double(maxS - minS)
                    let n = Int(round(Double(minN) + Double(maxN - minN) * t))
                    notes.append(GeneratedNote(note: n, step: s, velocity: velocity))
                }
                gestureType = .fill
            }
        }

        return (notes, gestureType)
    }

    // MARK: - Helper Methods

    /// Get scale notes for current key (prototype lines 450-452)
    static func getScaleNotes(scale: Scale, rootNote: Note) -> [Int] {
        let intervals = scales[scale] ?? scales[.major]!
        return intervals.map { ($0 + rootNote.rawValue) % 12 }
    }

    /// Snap note to nearest scale note (prototype lines 458-466)
    static func snapToScale(note: Int, scaleNotes: [Int]) -> Int {
        if scaleNotes.contains(note % 12) {
            return note % 12
        }

        // Find nearest scale note
        for offset in 1..<6 {
            if scaleNotes.contains((note + offset) % 12) {
                return (note + offset) % 12
            }
            if scaleNotes.contains((note - offset + 12) % 12) {
                return (note - offset + 12) % 12
            }
        }

        return note % 12
    }

    /// Check if note is in scale (prototype lines 454-456)
    static func isInScale(note: Int, scaleNotes: [Int]) -> Bool {
        return scaleNotes.contains(note % 12)
    }
}
