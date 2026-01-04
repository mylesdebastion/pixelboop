//
//  SequencerViewModel.swift
//  pixelboop
//
//  Created by AI Agent on 2026-01-03.
//

import Foundation
import Combine

/// Main sequencer state management (domain logic, NO SwiftUI dependencies)
@MainActor
class SequencerViewModel: ObservableObject {
    // MARK: - Playback State

    @Published var isPlaying: Bool = false

    // MARK: - Tempo State

    @Published var bpm: Int = 120 {
        didSet {
            // Clamp to valid range
            if bpm < 40 { bpm = 40 }
            if bpm > 240 { bpm = 240 }
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
        // TODO: Clear all notes from grid (Story 1.5+)
        // For now, just register undo point
        undoManager.registerUndo(withTarget: self) { target in
            // Placeholder for pattern restoration
        }
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
        if savedLength >= 8 && savedLength <= 32 {
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
