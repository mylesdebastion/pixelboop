//
//  SequencerViewModel.swift
//  pixelboop
//
//  Created by AI Agent on 2026-01-03.
//

import Foundation
import Combine

// MARK: - Grid Layout Constants

struct GridConstants {
    static let columns = 44
    static let rows = 24

    struct Melody {
        static let startRow = 2
        static let endRow = 7
        static let minNoteIndex = 0
        static let maxNoteIndex = 11 // 12 notes
    }
}

// MARK: - Track Types

enum TrackType: String, CaseIterable, Codable {
    case melody = "melody"
    case chords = "chords"
    case bass = "bass"
    case rhythm = "rhythm"
}

// MARK: - Pattern Model

/// Complete pattern state - matches web prototype JSON exactly
/// Uses 2D array: tracks[trackName][noteIndex 0-11][stepIndex 0-31] = velocity
struct Pattern: Codable, Equatable {
    var tracks: [String: [[Int]]]
    var bpm: Int = 120
    var scale: String = "major"
    var rootNote: String = "C"
    var length: Int = 44  // Fixed: Default to full grid width (was 32) (Review Critical #2)

    /// Velocity values (matches prototype lines 611-614, 793-841)
    /// 0 = no note
    /// 1 = normal note
    /// 2 = accent / sustain start
    /// 3 = sustain continuation (for ADSR envelope)

    init() {
        // Initialize 4 tracks with 12 notes × 44 steps
        self.tracks = [
            TrackType.melody.rawValue: Pattern.emptyTrack(),
            TrackType.chords.rawValue: Pattern.emptyTrack(),
            TrackType.bass.rawValue: Pattern.emptyTrack(),
            TrackType.rhythm.rawValue: Pattern.emptyTrack()
        ]
    }

    /// Create empty track: 12 notes × 44 steps, all velocity = 0
    private static func emptyTrack() -> [[Int]] {
        return Array(repeating: Array(repeating: 0, count: 44), count: 12)
    }

    /// Get velocity at specific position
    /// - Parameters:
    ///   - track: TrackType enum
    ///   - note: Note index (0-11, chromatic scale)
    ///   - step: Step index (0-43)
    /// - Returns: Velocity value (0-3), or 0 if out of bounds
    func getVelocity(track: TrackType, note: Int, step: Int) -> Int {
        guard let trackData = tracks[track.rawValue],
              note >= 0, note < 12,
              step >= 0, step < length else {
            return 0
        }
        return trackData[note][step]
    }

    /// Set velocity at specific position
    /// - Parameters:
    ///   - track: TrackType enum
    ///   - note: Note index (0-11)
    ///   - step: Step index (0-43)
    ///   - velocity: Velocity value (0-3)
    mutating func setVelocity(track: TrackType, note: Int, step: Int, velocity: Int) {
        guard note >= 0, note < 12,
              step >= 0, step < length,
              velocity >= 0, velocity <= 3 else {
            return
        }
        tracks[track.rawValue]?[note][step] = velocity
    }

    /// Clear all notes on a track
    mutating func clearTrack(_ track: TrackType) {
        tracks[track.rawValue] = Pattern.emptyTrack()
    }

    /// Clear all notes on all tracks
    mutating func clearAll() {
        for trackType in TrackType.allCases {
            clearTrack(trackType)
        }
    }
}

/// Main sequencer state management (domain logic, NO SwiftUI dependencies)
@MainActor
class SequencerViewModel: ObservableObject {
    // MARK: - Pattern State

    @Published var pattern: Pattern = Pattern()

    // MARK: - Playback State

    @Published var isPlaying: Bool = false

    // MARK: - Tempo State

    @Published var bpm: Int = 120 {
        didSet {
            // Clamp to valid range
            if bpm < 40 { bpm = 40 }
            if bpm > 240 { bpm = 240 }
            // Update pattern
            pattern.bpm = bpm
        }
    }

    // MARK: - Musical Scale State

    @Published var currentScale: Scale = .major
    @Published var rootNote: Note = .C

    // MARK: - UI State

    @Published var showGhostNotes: Bool = true
    @Published var patternLength: Int = 32 {
        didSet {
            // Clamp to valid range
            if patternLength < 8 { patternLength = 8 }
            if patternLength > 32 { patternLength = 32 }
            // Update pattern
            pattern.length = patternLength
        }
    }

    // MARK: - Undo/Redo

    private let undoManager = UndoManager()

    var canUndo: Bool {
        undoManager.canUndo
    }

    var canRedo: Bool {
        undoManager.canRedo
    }

    // MARK: - Initialization

    init() {
        loadState()
    }

    // MARK: - Playback Control

    func togglePlayback() {
        isPlaying.toggle()
        // TODO: Start/stop audio engine (Story 1.5+)
        saveState()
    }

    // MARK: - BPM Control

    func setBPM(_ value: Int) {
        guard value >= 40 && value <= 240 else { return }
        registerUndo(oldValue: bpm, keyPath: \.bpm)
        bpm = value
        saveState()
    }

    func adjustBPM(_ delta: Int) {
        let newBPM = bpm + delta
        setBPM(newBPM)
    }

    // MARK: - Scale Control

    func setScale(_ scale: Scale) {
        registerUndo(oldValue: currentScale, keyPath: \.currentScale)
        currentScale = scale
        saveState()
    }

    // MARK: - Root Note Control

    func setRootNote(_ note: Note) {
        registerUndo(oldValue: rootNote, keyPath: \.rootNote)
        rootNote = note
        saveState()
    }

    // MARK: - Ghost Notes Control

    func toggleGhostNotes() {
        registerUndo(oldValue: showGhostNotes, keyPath: \.showGhostNotes)
        showGhostNotes.toggle()
        saveState()
    }

    // MARK: - Pattern Length Control

    func setPatternLength(_ length: Int) {
        guard length >= 8 && length <= 32 else { return }
        registerUndo(oldValue: patternLength, keyPath: \.patternLength)
        patternLength = length
        saveState()
    }

    func adjustPatternLength(_ delta: Int) {
        let newLength = patternLength + delta
        setPatternLength(newLength)
    }

    // MARK: - Pattern Control

    func clearPattern() {
        let oldPattern = pattern
        registerUndo(oldValue: oldPattern, keyPath: \.pattern)
        pattern.clearAll()
        saveState()
    }

    // MARK: - Note Placement (Story 1.2)

    /// Toggle note at grid position (tap gesture)
    /// - Parameters:
    ///   - col: Grid column (0-43, step in pattern)
    ///   - row: Grid row (0-23, pitch on track)
    func toggleNote(col: Int, row: Int) {
        // Only handle melody track for Story 1.2 (rows 2-7)
        guard row >= GridConstants.Melody.startRow && row <= GridConstants.Melody.endRow else { return }
        guard col >= 0 && col < GridConstants.columns else { return }

        let step = col
        let track = TrackType.melody

        // Convert row to note index (row 2 = highest pitch, row 7 = lowest)
        // Melody track: 6 rows (2-7) map to 6 semitones
        let noteIndex = GridConstants.Melody.endRow - row  // row 2 → note 5, row 7 → note 0

        // Check if note already exists at this exact position BEFORE clearing
        let existingVelocity = pattern.getVelocity(track: track, note: noteIndex, step: step)

        if existingVelocity > 0 {
            // Toggle off - remove the note at this exact position
            pattern.setVelocity(track: track, note: noteIndex, step: step, velocity: 0)
        } else {
            // Clear any other notes at this step (one note per step rule)
            for n in 0..<12 {
                if pattern.getVelocity(track: track, note: n, step: step) > 0 {
                    pattern.setVelocity(track: track, note: n, step: step, velocity: 0)
                }
            }
            // Add new note
            pattern.setVelocity(track: track, note: noteIndex, step: step, velocity: 1)
        }

        // Manually trigger @Published update (struct mutation doesn't auto-trigger)
        objectWillChange.send()

        saveState()
    }

    /// Add note at specific position with velocity
    func addNote(track: TrackType, note: Int, step: Int, velocity: Int = 1) {
        let oldPattern = pattern
        registerUndo(oldValue: oldPattern, keyPath: \.pattern)
        pattern.setVelocity(track: track, note: note, step: step, velocity: velocity)
        saveState()
    }

    /// Remove note at specific position
    func removeNote(track: TrackType, note: Int, step: Int) {
        let oldPattern = pattern
        registerUndo(oldValue: oldPattern, keyPath: \.pattern)
        pattern.setVelocity(track: track, note: note, step: step, velocity: 0)
        saveState()
    }

    // MARK: - Undo/Redo

    func undo() {
        guard undoManager.canUndo else { return }
        undoManager.undo()
    }

    func redo() {
        guard undoManager.canRedo else { return }
        undoManager.redo()
    }

    // MARK: - State Persistence

    private func saveState() {
        UserDefaults.standard.set(bpm, forKey: "sequencer.bpm")
        UserDefaults.standard.set(currentScale.rawValue, forKey: "sequencer.scale")
        UserDefaults.standard.set(rootNote.rawValue, forKey: "sequencer.rootNote")
        UserDefaults.standard.set(showGhostNotes, forKey: "sequencer.ghostNotes")
        UserDefaults.standard.set(patternLength, forKey: "sequencer.patternLength")
    }

    private func loadState() {
        // Load BPM
        let savedBPM = UserDefaults.standard.integer(forKey: "sequencer.bpm")
        if savedBPM >= 40 && savedBPM <= 240 {
            bpm = savedBPM
        }

        // Load scale
        if let scaleRaw = UserDefaults.standard.string(forKey: "sequencer.scale"),
           let scale = Scale(rawValue: scaleRaw) {
            currentScale = scale
        }

        // Load root note
        let rootNoteRaw = UserDefaults.standard.integer(forKey: "sequencer.rootNote")
        if let note = Note(rawValue: rootNoteRaw) {
            rootNote = note
        }

        // Load ghost notes
        showGhostNotes = UserDefaults.standard.bool(forKey: "sequencer.ghostNotes")
        // Default to true if never set
        if !UserDefaults.standard.bool(forKey: "sequencer.ghostNotes.hasBeenSet") {
            showGhostNotes = true
            UserDefaults.standard.set(true, forKey: "sequencer.ghostNotes.hasBeenSet")
        }

        // Load pattern length
        let savedLength = UserDefaults.standard.integer(forKey: "sequencer.patternLength")
        if savedLength >= 8 && savedLength <= 32 { // NOTE: MVP limited to 32, but Pattern supports 44
            patternLength = savedLength
        }
    }

    private func registerUndo<T>(oldValue: T, keyPath: ReferenceWritableKeyPath<SequencerViewModel, T>) {
        undoManager.registerUndo(withTarget: self) { target in
            let currentValue = target[keyPath: keyPath]
            target[keyPath: keyPath] = oldValue
            target.registerUndo(oldValue: currentValue, keyPath: keyPath)
            target.saveState()
        }
    }
}
