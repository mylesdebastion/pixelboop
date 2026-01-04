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
}
