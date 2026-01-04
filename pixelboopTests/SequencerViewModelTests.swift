//
//  SequencerViewModelTests.swift
//  pixelboopTests
//
//  Created by AI Agent on 2026-01-03.
//

import XCTest
@testable import pixelboop

@MainActor
final class SequencerViewModelTests: XCTestCase {

    var viewModel: SequencerViewModel!

    override func setUp() async throws {
        viewModel = SequencerViewModel()
        // Clear UserDefaults to start fresh
        UserDefaults.standard.removeObject(forKey: "sequencer.bpm")
        UserDefaults.standard.removeObject(forKey: "sequencer.scale")
        UserDefaults.standard.removeObject(forKey: "sequencer.rootNote")
        UserDefaults.standard.removeObject(forKey: "sequencer.ghostNotes")
        UserDefaults.standard.removeObject(forKey: "sequencer.patternLength")
    }

    override func tearDown() async throws {
        viewModel = nil
    }

    // MARK: - Playback Tests

    func test_togglePlayback_startsFromStopped() {
        XCTAssertFalse(viewModel.isPlaying)
        viewModel.togglePlayback()
        XCTAssertTrue(viewModel.isPlaying)
    }

    func test_togglePlayback_stopsFromPlaying() {
        viewModel.togglePlayback() // Start playing
        XCTAssertTrue(viewModel.isPlaying)
        viewModel.togglePlayback() // Stop playing
        XCTAssertFalse(viewModel.isPlaying)
    }

    // MARK: - BPM Tests

    func test_setBPM_withinValidRange() {
        viewModel.setBPM(100)
        XCTAssertEqual(viewModel.bpm, 100)
    }

    func test_setBPM_clampsBelowMinimum() {
        viewModel.setBPM(30)
        XCTAssertEqual(viewModel.bpm, 40) // Clamped to minimum
    }

    func test_setBPM_clampsAboveMaximum() {
        viewModel.setBPM(300)
        XCTAssertEqual(viewModel.bpm, 240) // Clamped to maximum
    }

    func test_adjustBPM_increasesByDelta() {
        viewModel.bpm = 120
        viewModel.adjustBPM(5)
        XCTAssertEqual(viewModel.bpm, 125)
    }

    func test_adjustBPM_decreasesByDelta() {
        viewModel.bpm = 120
        viewModel.adjustBPM(-5)
        XCTAssertEqual(viewModel.bpm, 115)
    }

    func test_adjustBPM_respectsMinimum() {
        viewModel.bpm = 40
        viewModel.adjustBPM(-10)
        XCTAssertEqual(viewModel.bpm, 40) // Should not go below 40
    }

    func test_adjustBPM_respectsMaximum() {
        viewModel.bpm = 240
        viewModel.adjustBPM(10)
        XCTAssertEqual(viewModel.bpm, 240) // Should not go above 240
    }

    // MARK: - Scale Tests

    func test_setScale_changesScale() {
        viewModel.setScale(.minor)
        XCTAssertEqual(viewModel.currentScale, .minor)
    }

    func test_setScale_registerUndo() {
        viewModel.setScale(.minor)
        XCTAssertTrue(viewModel.canUndo)
        viewModel.undo()
        XCTAssertEqual(viewModel.currentScale, .major) // Back to default
    }

    // MARK: - Root Note Tests

    func test_setRootNote_changesNote() {
        viewModel.setRootNote(.D)
        XCTAssertEqual(viewModel.rootNote, .D)
    }

    func test_setRootNote_registerUndo() {
        viewModel.setRootNote(.G)
        XCTAssertTrue(viewModel.canUndo)
        viewModel.undo()
        XCTAssertEqual(viewModel.rootNote, .C) // Back to default
    }

    // MARK: - Ghost Notes Tests

    func test_toggleGhostNotes_enablesFromDisabled() {
        viewModel.showGhostNotes = false
        viewModel.toggleGhostNotes()
        XCTAssertTrue(viewModel.showGhostNotes)
    }

    func test_toggleGhostNotes_disablesFromEnabled() {
        viewModel.showGhostNotes = true
        viewModel.toggleGhostNotes()
        XCTAssertFalse(viewModel.showGhostNotes)
    }

    // MARK: - Pattern Length Tests

    func test_setPatternLength_withinValidRange() {
        viewModel.setPatternLength(16)
        XCTAssertEqual(viewModel.patternLength, 16)
    }

    func test_setPatternLength_clampsBelowMinimum() {
        viewModel.setPatternLength(4)
        XCTAssertEqual(viewModel.patternLength, 8) // Clamped to minimum
    }

    func test_setPatternLength_clampsAboveMaximum() {
        viewModel.setPatternLength(40)
        XCTAssertEqual(viewModel.patternLength, 32) // Clamped to maximum
    }

    func test_adjustPatternLength_increasesByDelta() {
        viewModel.patternLength = 16
        viewModel.adjustPatternLength(4)
        XCTAssertEqual(viewModel.patternLength, 20)
    }

    func test_adjustPatternLength_decreasesByDelta() {
        viewModel.patternLength = 16
        viewModel.adjustPatternLength(-4)
        XCTAssertEqual(viewModel.patternLength, 12)
    }

    func test_adjustPatternLength_respectsMinimum() {
        viewModel.patternLength = 8
        viewModel.adjustPatternLength(-4)
        XCTAssertEqual(viewModel.patternLength, 8) // Should not go below 8
    }

    func test_adjustPatternLength_respectsMaximum() {
        viewModel.patternLength = 32
        viewModel.adjustPatternLength(4)
        XCTAssertEqual(viewModel.patternLength, 32) // Should not go above 32
    }

    // MARK: - Undo/Redo Tests

    func test_undo_canUndoInitiallyFalse() {
        XCTAssertFalse(viewModel.canUndo)
    }

    func test_undo_canUndoAfterChange() {
        viewModel.setBPM(100)
        XCTAssertTrue(viewModel.canUndo)
    }

    func test_undo_restoresPreviousBPM() {
        let originalBPM = viewModel.bpm
        viewModel.setBPM(100)
        viewModel.undo()
        XCTAssertEqual(viewModel.bpm, originalBPM)
    }

    func test_redo_canRedoAfterUndo() {
        viewModel.setBPM(100)
        viewModel.undo()
        XCTAssertTrue(viewModel.canRedo)
    }

    func test_redo_restoresUndoneChange() {
        viewModel.setBPM(100)
        viewModel.undo()
        viewModel.redo()
        XCTAssertEqual(viewModel.bpm, 100)
    }

    func test_undo_canRedoInitiallyFalse() {
        XCTAssertFalse(viewModel.canRedo)
    }

    // MARK: - State Persistence Tests

    func test_saveState_persistsBPM() {
        viewModel.setBPM(150)
        let newViewModel = SequencerViewModel()
        XCTAssertEqual(newViewModel.bpm, 150)
    }

    func test_saveState_persistsScale() {
        viewModel.setScale(.minor)
        let newViewModel = SequencerViewModel()
        XCTAssertEqual(newViewModel.currentScale, .minor)
    }

    func test_saveState_persistsRootNote() {
        viewModel.setRootNote(.F)
        let newViewModel = SequencerViewModel()
        XCTAssertEqual(newViewModel.rootNote, .F)
    }

    func test_saveState_persistsGhostNotes() {
        viewModel.showGhostNotes = false
        viewModel.toggleGhostNotes() // Force save
        let newViewModel = SequencerViewModel()
        XCTAssertTrue(newViewModel.showGhostNotes)
    }

    func test_saveState_persistsPatternLength() {
        viewModel.setPatternLength(24)
        let newViewModel = SequencerViewModel()
        XCTAssertEqual(newViewModel.patternLength, 24)
    }

    func test_loadState_defaultsWhenNoSavedState() {
        // Clear all saved state
        UserDefaults.standard.removeObject(forKey: "sequencer.bpm")
        UserDefaults.standard.removeObject(forKey: "sequencer.scale")
        UserDefaults.standard.removeObject(forKey: "sequencer.rootNote")
        UserDefaults.standard.removeObject(forKey: "sequencer.ghostNotes")
        UserDefaults.standard.removeObject(forKey: "sequencer.patternLength")
        UserDefaults.standard.removeObject(forKey: "sequencer.ghostNotes.hasBeenSet")

        let newViewModel = SequencerViewModel()
        XCTAssertEqual(newViewModel.bpm, 120)
        XCTAssertEqual(newViewModel.currentScale, .major)
        XCTAssertEqual(newViewModel.rootNote, .C)
        XCTAssertTrue(newViewModel.showGhostNotes)
        XCTAssertEqual(newViewModel.patternLength, 32)
    }

    // MARK: - Pattern Model Tests (Story 1.2)

    func test_pattern_initializedEmpty() {
        XCTAssertEqual(viewModel.pattern.bpm, 120)
        XCTAssertEqual(viewModel.pattern.scale, "major")
        XCTAssertEqual(viewModel.pattern.rootNote, "C")
        XCTAssertEqual(viewModel.pattern.length, 44) // Updated

        // Verify all tracks are empty
        for track in TrackType.allCases {
            for note in 0..<12 {
                for step in 0..<44 { // Updated
                    XCTAssertEqual(viewModel.pattern.getVelocity(track: track, note: note, step: step), 0)
                }
            }
        }
    }

    func test_pattern_setVelocity_storesCorrectly() {
        viewModel.pattern.setVelocity(track: .melody, note: 5, step: 10, velocity: 1)
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: 5, step: 10), 1)
    }

    func test_pattern_setVelocity_acceptsAllVelocityTypes() {
        viewModel.pattern.setVelocity(track: .melody, note: 0, step: 0, velocity: 1) // Normal
        viewModel.pattern.setVelocity(track: .melody, note: 1, step: 1, velocity: 2) // Accent
        viewModel.pattern.setVelocity(track: .melody, note: 2, step: 2, velocity: 3) // Sustain

        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: 0, step: 0), 1)
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: 1, step: 1), 2)
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: 2, step: 2), 3)
    }

    func test_pattern_setVelocity_ignoresOutOfBounds() {
        viewModel.pattern.setVelocity(track: .melody, note: -1, step: 0, velocity: 1) // Invalid note
        viewModel.pattern.setVelocity(track: .melody, note: 0, step: -1, velocity: 1) // Invalid step
        viewModel.pattern.setVelocity(track: .melody, note: 0, step: 45, velocity: 1) // Step beyond length
        viewModel.pattern.setVelocity(track: .melody, note: 0, step: 0, velocity: 4) // Invalid velocity

        // All should be ignored, pattern remains empty
        for note in 0..<12 {
            for step in 0..<44 {
                XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: note, step: step), 0)
            }
        }
    }

    func test_pattern_clearAll_removesAllNotes() {
        // Add some notes
        viewModel.pattern.setVelocity(track: .melody, note: 0, step: 0, velocity: 1)
        viewModel.pattern.setVelocity(track: .chords, note: 5, step: 10, velocity: 2)
        viewModel.pattern.setVelocity(track: .bass, note: 3, step: 8, velocity: 1)

        // Clear all
        viewModel.pattern.clearAll()

        // Verify all tracks are empty
        for track in TrackType.allCases {
            for note in 0..<12 {
                for step in 0..<44 {
                    XCTAssertEqual(viewModel.pattern.getVelocity(track: track, note: note, step: step), 0)
                }
            }
        }
    }

    // MARK: - Note Placement Tests (Story 1.2)

    func test_toggleNote_placesNoteOnEmptyGrid() {
        viewModel.toggleNote(col: 0, row: 2)

        // Should place note at melody track
        let noteIndex = 7 - 2  // row 2 → note 5
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: noteIndex, step: 0), 1)
    }

    func test_toggleNote_removesNoteWhenTappedAgain() {
        viewModel.toggleNote(col: 5, row: 3)
        let noteIndex = 7 - 3  // row 3 → note 4

        // First tap places note
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: noteIndex, step: 5), 1)

        // Second tap removes note
        viewModel.toggleNote(col: 5, row: 3)
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: noteIndex, step: 5), 0)
    }

    func test_toggleNote_replacesNoteAtSameColumn() {
        // Tap row 2 at column 10
        viewModel.toggleNote(col: 10, row: 2)
        let noteIndex1 = 7 - 2  // row 2 → note 5

        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: noteIndex1, step: 10), 1)

        // Tap row 3 at same column 10 (should replace)
        viewModel.toggleNote(col: 10, row: 3)
        let noteIndex2 = 7 - 3  // row 3 → note 4

        // Old note should be gone
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: noteIndex1, step: 10), 0)
        // New note should be present
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: noteIndex2, step: 10), 1)
    }

    func test_toggleNote_ignoresRowsOutsideMelodyTrack() {
        // Row 0 (controls)
        viewModel.toggleNote(col: 10, row: 0)
        // Row 1 (step markers)
        viewModel.toggleNote(col: 10, row: 1)
        // Row 8 (outside melody track)
        viewModel.toggleNote(col: 10, row: 8)

        // Verify no notes placed on melody track at col 10
        for note in 0..<12 {
            XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: note, step: 10), 0)
        }
    }

    func test_toggleNote_ignoresColumnsOutsideGrid() {
        viewModel.toggleNote(col: -1, row: 3)
        viewModel.toggleNote(col: 44, row: 3)

        // Verify no notes placed anywhere
        for note in 0..<12 {
            for step in 0..<44 {
                XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: note, step: step), 0)
            }
        }
    }

    func test_toggleNote_correctRowToPitchMapping() {
        // Row 2 should be highest pitch (note index 5)
        viewModel.toggleNote(col: 0, row: 2)
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: 5, step: 0), 1)

        // Row 7 should be lowest pitch (note index 0)
        viewModel.toggleNote(col: 1, row: 7)
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: 0, step: 1), 1)

        // Row 4 should be middle pitch (note index 3)
        viewModel.toggleNote(col: 2, row: 4)
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: 3, step: 2), 1)
    }

    func test_clearPattern_removesAllNotes() {
        // Place some notes
        viewModel.toggleNote(col: 0, row: 2)
        viewModel.toggleNote(col: 5, row: 3)
        viewModel.toggleNote(col: 10, row: 5)

        // Clear pattern
        viewModel.clearPattern()

        // Verify all tracks are empty
        for track in TrackType.allCases {
            for note in 0..<12 {
                for step in 0..<44 {
                    XCTAssertEqual(viewModel.pattern.getVelocity(track: track, note: note, step: step), 0)
                }
            }
        }
    }

    func test_clearPattern_canBeUndone() {
        // Place notes
        viewModel.toggleNote(col: 0, row: 2)
        viewModel.toggleNote(col: 5, row: 3)

        // Clear pattern
        viewModel.clearPattern()

        // Undo clear
        viewModel.undo()

        // Notes should be restored
        let noteIndex1 = 7 - 2
        let noteIndex2 = 7 - 3
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: noteIndex1, step: 0), 1)
        XCTAssertEqual(viewModel.pattern.getVelocity(track: .melody, note: noteIndex2, step: 5), 1)
    }
}
