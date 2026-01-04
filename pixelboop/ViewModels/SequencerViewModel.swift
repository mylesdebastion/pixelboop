//
//  SequencerViewModel.swift
//  pixelboop
//
//  Main sequencer state management matching prototype architecture
//

import Foundation
import Combine

// MARK: - Grid Layout Constants

struct GridConstants {
    static let columns = 44
    static let rows = 24

    // Track row ranges (from prototype lines 623-629, 732-737)
    struct Melody {
        static let startRow = 2
        static let endRow = 7
        static let height = 6
    }

    struct Chords {
        static let startRow = 8
        static let endRow = 13
        static let height = 6
    }

    struct Bass {
        static let startRow = 14
        static let endRow = 17
        static let height = 4
    }

    struct Rhythm {
        static let startRow = 18
        static let endRow = 21
        static let height = 4
    }

    // Overview rows
    static let overviewRow1 = 22
    static let overviewRow2 = 23

    /// Get track for a given row
    static func trackForRow(_ row: Int) -> TrackType? {
        switch row {
        case Melody.startRow...Melody.endRow: return .melody
        case Chords.startRow...Chords.endRow: return .chords
        case Bass.startRow...Bass.endRow: return .bass
        case Rhythm.startRow...Rhythm.endRow: return .rhythm
        default: return nil
        }
    }

    /// Convert row to note index for a track (from prototype lines 631-638)
    static func noteForRow(_ row: Int, track: TrackType) -> Int {
        let start: Int
        let size: Int

        switch track {
        case .melody:
            start = Melody.startRow
            size = Melody.height
        case .chords:
            start = Chords.startRow
            size = Chords.height
        case .bass:
            start = Bass.startRow
            size = Bass.height
        case .rhythm:
            start = Rhythm.startRow
            size = Rhythm.height
        }

        let localRow = row - start
        // Invert: top row = highest pitch (11), bottom = lowest (0)
        return max(0, min(11, Int(round(Double(size - 1 - localRow) / Double(size - 1) * 11))))
    }

    /// Convert step to column (accounting for separator gaps at 8, 16, 24)
    static func columnForStep(_ step: Int) -> Int {
        // Add separator gaps: every 8 steps
        return 4 + step + step / 8
    }

    /// Convert column to step (accounting for separator gaps)
    static func stepForColumn(_ col: Int) -> Int? {
        guard col >= 4 else { return nil }
        var step = col - 4
        // Subtract separator columns (at positions 12, 21, 30)
        if step >= 8 { step -= 1 }
        if step >= 16 { step -= 1 }
        if step >= 24 { step -= 1 }
        guard step >= 0 && step < 32 else { return nil }
        return step
    }
}

// MARK: - Track Types

enum TrackType: String, CaseIterable, Codable {
    case melody = "melody"
    case chords = "chords"
    case bass = "bass"
    case rhythm = "rhythm"
}

// MARK: - Track Colors (from prototype lines 14-16)

struct TrackColors {
    static let colors: [TrackType: (r: CGFloat, g: CGFloat, b: CGFloat)] = [
        .melody: (0.97, 0.86, 0.44),   // #f7dc6f
        .chords: (0.31, 0.80, 0.77),   // #4ecdc4
        .bass: (0.27, 0.72, 0.82),     // #45b7d1
        .rhythm: (1.0, 0.42, 0.42)     // #ff6b6b
    ]

    static let order: [TrackType] = [.melody, .chords, .bass, .rhythm]
}

// MARK: - Pattern Model

/// Complete pattern state - matches web prototype JSON exactly
/// Uses 2D array: tracks[trackName][noteIndex 0-11][stepIndex 0-31] = velocity
struct Pattern: Codable, Equatable {
    var tracks: [String: [[Int]]]
    var bpm: Int = 120
    var scale: String = "major"
    var rootNote: String = "C"
    var length: Int = 32

    /// Velocity values:
    /// 0 = no note
    /// 1 = normal note
    /// 2 = accent / sustain start
    /// 3 = sustain continuation

    init() {
        self.tracks = [
            TrackType.melody.rawValue: Pattern.emptyTrack(),
            TrackType.chords.rawValue: Pattern.emptyTrack(),
            TrackType.bass.rawValue: Pattern.emptyTrack(),
            TrackType.rhythm.rawValue: Pattern.emptyTrack()
        ]
    }

    private static func emptyTrack() -> [[Int]] {
        return Array(repeating: Array(repeating: 0, count: 32), count: 12)
    }

    func getVelocity(track: TrackType, note: Int, step: Int) -> Int {
        guard let trackData = tracks[track.rawValue],
              note >= 0, note < 12,
              step >= 0, step < length else {
            return 0
        }
        return trackData[note][step]
    }

    mutating func setVelocity(track: TrackType, note: Int, step: Int, velocity: Int) {
        guard note >= 0, note < 12,
              step >= 0, step < length,
              velocity >= 0, velocity <= 3 else {
            return
        }
        tracks[track.rawValue]?[note][step] = velocity
    }

    mutating func clearTrack(_ track: TrackType) {
        tracks[track.rawValue] = Pattern.emptyTrack()
    }

    mutating func clearAll() {
        for trackType in TrackType.allCases {
            clearTrack(trackType)
        }
    }
}

// MARK: - Mute/Solo State

struct TrackMuteState {
    var muted: [TrackType: Bool] = [
        .melody: false, .chords: false, .bass: false, .rhythm: false
    ]
    var soloed: TrackType? = nil

    func isMuted(_ track: TrackType) -> Bool {
        if let solo = soloed {
            return track != solo
        }
        return muted[track] ?? false
    }
}

// MARK: - Sequencer ViewModel

@MainActor
class SequencerViewModel: ObservableObject {

    // MARK: - Pattern State

    @Published var pattern: Pattern = Pattern()

    // MARK: - Playback State

    @Published var isPlaying: Bool = false
    @Published var currentStep: Int = 0
    @Published var pulseStep: Int = -1  // For visual pulse effect

    private var playbackTimer: Timer?

    // MARK: - Audio

    let audioEngine = AudioEngine()

    // MARK: - Tempo State

    @Published var bpm: Int = 120 {
        didSet {
            let clamped = max(60, min(200, bpm))
            if bpm != clamped {
                bpm = clamped  // Only re-assign if actually changed (avoids recursion)
                return
            }
            pattern.bpm = bpm
            restartPlaybackIfNeeded()
        }
    }

    // MARK: - Musical State

    @Published var currentScale: Scale = .major
    @Published var rootNote: Note = .C

    // MARK: - UI State

    @Published var showGhostNotes: Bool = true
    @Published var patternLength: Int = 32 {
        didSet {
            let clamped = max(8, min(32, patternLength))
            if patternLength != clamped {
                patternLength = clamped  // Only re-assign if actually changed (avoids recursion)
                return
            }
            pattern.length = patternLength
        }
    }

    // MARK: - Track Mute/Solo (from prototype lines 167-168, 640-647)

    @Published var muteState = TrackMuteState()

    // MARK: - Tooltip State

    @Published var currentTooltip: TooltipKey?
    @Published var tooltipPixels: [TooltipPixel] = []
    private var tooltipTimer: Timer?

    // MARK: - Shake Detection (from prototype lines 190-196, 278-319)

    @Published var isShaking: Bool = false
    @Published var shakeDirectionChanges: Int = 0
    private var lastShakeCol: Int?
    private var lastShakeDirection: Int = 0
    private var shakeTimer: Timer?

    // MARK: - Double Swipe Detection (from prototype lines 198-200, 254-275)

    private var lastSwipeTime: Date = .distantPast
    private var lastSwipeDirection: String?

    // MARK: - Gesture State

    @Published var gesturePreview: [GeneratedNote] = []
    @Published var lastGestureType: GestureType?
    private var gestureStartTime: Date?
    private var gestureStartPoint: (row: Int, col: Int)?

    // MARK: - History

    private var history: [Data] = []
    private var historyIndex: Int = -1
    private let maxHistory = 50

    var canUndo: Bool { historyIndex > 0 }
    var canRedo: Bool { historyIndex < history.count - 1 }

    // MARK: - Initialization

    init() {
        loadState()
        saveToHistory()
    }

    // MARK: - Playback Control (from prototype lines 419-423, 1509-1528)

    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            audioEngine.start()
            startPlayback()
        } else {
            stopPlayback()
        }
        showTooltip(.togglePlay)
        saveState()
    }

    private func startPlayback() {
        stopPlayback()  // Clear any existing timer

        let interval = 60.0 / Double(bpm) / 4.0  // 16th notes
        playbackTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advanceStep()
            }
        }
    }

    private func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func restartPlaybackIfNeeded() {
        if isPlaying {
            startPlayback()
        }
    }

    private func advanceStep() {
        currentStep = (currentStep + 1) % patternLength
        playCurrentStep()

        // Pulse effect
        pulseStep = currentStep
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms
            await MainActor.run {
                self.pulseStep = -1
            }
        }
    }

    // MARK: - Audio Playback (from prototype lines 1467-1507)

    private func playCurrentStep() {
        let stepDuration = 60.0 / Double(bpm) / 4.0

        for track in TrackType.allCases {
            guard !muteState.isMuted(track) else { continue }

            for note in 0..<12 {
                let velocity = pattern.getVelocity(track: track, note: note, step: currentStep)
                guard velocity > 0 else { continue }

                if track == .rhythm {
                    // Drums always trigger
                    if let drumType = DrumType(rawValue: note) {
                        audioEngine.playDrum(drumType, velocity: velocity)
                    }
                } else if velocity != 3 {
                    // velocity 3 = sustain continuation, don't retrigger
                    // Count sustain length
                    var sustainSteps = 1
                    for s in 1..<patternLength {
                        let nextStep = (currentStep + s) % patternLength
                        if pattern.getVelocity(track: track, note: note, step: nextStep) == 3 {
                            sustainSteps += 1
                        } else {
                            break
                        }
                    }
                    let duration = max(0.15, stepDuration * Double(sustainSteps) * 0.95)
                    audioEngine.playNote(track: track, noteIndex: note, velocity: velocity, duration: duration)
                }
            }
        }
    }

    // MARK: - BPM Control

    func adjustBPM(_ delta: Int) {
        let oldBPM = bpm
        bpm = bpm + delta
        if bpm != oldBPM {
            saveToHistory()
            showTooltip(delta > 0 ? .bpmUp : .bpmDown)
            saveState()
        }
    }

    // MARK: - Scale Control

    func setScale(_ scale: Scale) {
        guard currentScale != scale else { return }
        saveToHistory()
        currentScale = scale
        switch scale {
        case .major: showTooltip(.scaleMajor)
        case .minor: showTooltip(.scaleMinor)
        case .pentatonic: showTooltip(.scalePenta)
        }
        saveState()
    }

    // MARK: - Root Note Control

    func setRootNote(_ note: Note) {
        guard rootNote != note else { return }
        saveToHistory()
        rootNote = note
        saveState()
    }

    // MARK: - Ghost Notes Control

    func toggleGhostNotes() {
        saveToHistory()
        showGhostNotes.toggle()
        showTooltip(.toggleGhosts)
        saveState()
    }

    // MARK: - Pattern Length Control

    func adjustPatternLength(_ delta: Int) {
        let oldLength = patternLength
        patternLength = patternLength + delta
        if patternLength != oldLength {
            saveToHistory()
            showTooltip(delta > 0 ? .lenUp : .lenDown)
            saveState()
        }
    }

    // MARK: - Mute/Solo Control (from prototype lines 640-647)

    func toggleMute(_ track: TrackType) {
        var newState = muteState
        let wasMuted = newState.muted[track] ?? false

        if newState.soloed == track {
            newState.soloed = nil
        } else {
            newState.muted[track]?.toggle()
        }
        muteState = newState  // Reassign to trigger @Published

        // Show tooltip - track-specific when muting, generic when unmuting
        let tooltipKey: TooltipKey
        if wasMuted {
            tooltipKey = .unmute
        } else {
            tooltipKey = switch track {
            case .melody: .muteMelody
            case .chords: .muteChords
            case .bass: .muteBass
            case .rhythm: .muteRhythm
            }
        }
        showTooltip(tooltipKey)
    }

    func toggleSolo(_ track: TrackType) {
        var newState = muteState
        newState.soloed = newState.soloed == track ? nil : track
        muteState = newState  // Reassign to trigger @Published

        // Show tooltip
        let tooltipKey: TooltipKey = switch track {
        case .melody: .soloMelody
        case .chords: .soloChords
        case .bass: .soloBass
        case .rhythm: .soloRhythm
        }
        showTooltip(tooltipKey)
    }

    // MARK: - Pattern Control

    func clearPattern(fromShake: Bool = false) {
        saveToHistory()
        pattern.clearAll()
        resetShake()
        lastGestureType = fromShake ? .clear : .clear
        showTooltip(fromShake ? .gestureShake : .clearAll)
        objectWillChange.send()
        saveState()
    }

    // MARK: - Note Placement

    /// Toggle note at grid position
    func toggleNote(col: Int, row: Int) {
        guard let track = GridConstants.trackForRow(row) else { return }
        guard let step = GridConstants.stepForColumn(col) else { return }

        let noteIndex = GridConstants.noteForRow(row, track: track)
        let existingVelocity = pattern.getVelocity(track: track, note: noteIndex, step: step)

        if existingVelocity > 0 {
            // Toggle off
            pattern.setVelocity(track: track, note: noteIndex, step: step, velocity: 0)
        } else {
            // Clear other notes at this step (one note per step per track for clarity)
            for n in 0..<12 {
                if pattern.getVelocity(track: track, note: n, step: step) > 0 {
                    pattern.setVelocity(track: track, note: n, step: step, velocity: 0)
                }
            }
            // Add new note
            pattern.setVelocity(track: track, note: noteIndex, step: step, velocity: 1)
        }

        objectWillChange.send()
        saveState()
    }

    /// Apply generated notes from gesture
    func applyGesture(_ notes: [GeneratedNote], track: TrackType) {
        saveToHistory()
        for note in notes {
            if note.note >= 0 && note.note < 12 && note.step >= 0 && note.step < 32 {
                let velocity = note.velocity > 2 ? 3 : (note.velocity > 1 ? 2 : 1)
                pattern.setVelocity(track: track, note: note.note, step: note.step, velocity: velocity)
            }
        }
        objectWillChange.send()
        saveState()
    }

    /// Erase all notes at step (double-tap, from prototype lines 992-1004)
    func eraseStep(col: Int, row: Int) {
        guard let track = GridConstants.trackForRow(row) else { return }
        guard let step = GridConstants.stepForColumn(col) else { return }

        saveToHistory()
        for n in 0..<12 {
            pattern.setVelocity(track: track, note: n, step: step, velocity: 0)
        }
        lastGestureType = .erase
        showTooltipForGesture(.erase)
        objectWillChange.send()
        saveState()
    }

    // MARK: - Gesture Handling

    func startGesture(row: Int, col: Int) {
        gestureStartTime = Date()
        gestureStartPoint = (row, col)

        // Create initial preview for tap (in case there's no drag)
        guard let track = GridConstants.trackForRow(row),
              let step = GridConstants.stepForColumn(col) else {
            return
        }

        let note = GridConstants.noteForRow(row, track: track)
        let (notes, gestureType) = GestureInterpreter.interpret(
            start: GesturePoint(note: note, step: step),
            end: GesturePoint(note: note, step: step),
            track: track,
            velocity: 1,
            scale: currentScale,
            rootNote: rootNote,
            patternLength: patternLength
        )

        gesturePreview = notes
        lastGestureType = gestureType
    }

    func updateGesture(row: Int, col: Int) {
        // Shake detection
        if detectShake(col: col) {
            clearPattern(fromShake: true)
            gesturePreview = []  // Clear preview to prevent note application in endGesture
            endGesture()
            return
        }

        guard let startPoint = gestureStartPoint,
              let track = GridConstants.trackForRow(row),
              GridConstants.trackForRow(startPoint.row) == track else {
            return
        }

        guard let startStep = GridConstants.stepForColumn(startPoint.col),
              let currentStep = GridConstants.stepForColumn(col) else {
            return
        }

        let startNote = GridConstants.noteForRow(startPoint.row, track: track)
        let currentNote = GridConstants.noteForRow(row, track: track)

        let holdDuration = Date().timeIntervalSince(gestureStartTime ?? Date())
        let velocity = holdDuration > 0.4 ? 2 : 1

        let (notes, gestureType) = GestureInterpreter.interpret(
            start: GesturePoint(note: startNote, step: startStep),
            end: GesturePoint(note: currentNote, step: currentStep),
            track: track,
            velocity: velocity,
            scale: currentScale,
            rootNote: rootNote,
            patternLength: patternLength
        )

        gesturePreview = notes
        lastGestureType = gestureType
    }

    func endGesture() {
        // Check for double swipe
        if let startPoint = gestureStartPoint,
           let startStep = GridConstants.stepForColumn(startPoint.col) {
            let now = Date()
            let duration = now.timeIntervalSince(gestureStartTime ?? now)

            // Calculate end column based on preview
            if let lastNote = gesturePreview.last {
                let endCol = GridConstants.columnForStep(lastNote.step)
                if let doubleSwipe = detectDoubleSwipe(startCol: startPoint.col, endCol: endCol, duration: duration) {
                    if doubleSwipe == "left" {
                        undo()
                        lastGestureType = .swipeUndo
                        showTooltipForGesture(.swipeUndo)
                    } else {
                        redo()
                        lastGestureType = .swipeRedo
                        showTooltipForGesture(.swipeRedo)
                    }
                    gesturePreview = []
                    gestureStartPoint = nil
                    gestureStartTime = nil
                    resetShake()
                    return
                }
            }
        }

        // Apply gesture if we have preview notes
        if !gesturePreview.isEmpty && !isShaking,
           let startPoint = gestureStartPoint,
           let track = GridConstants.trackForRow(startPoint.row) {

            applyGesture(gesturePreview, track: track)
            if let gestureType = lastGestureType {
                showTooltipForGesture(gestureType)
            }
        }

        gesturePreview = []
        gestureStartPoint = nil
        gestureStartTime = nil
        resetShake()
    }

    // MARK: - Shake Detection (from prototype lines 278-319)

    private func detectShake(col: Int) -> Bool {
        // Reset shake timer
        shakeTimer?.invalidate()
        shakeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.resetShake()
            }
        }

        if let lastCol = lastShakeCol {
            let diff = col - lastCol
            let direction = diff > 0 ? 1 : (diff < 0 ? -1 : 0)

            if direction != 0 && abs(diff) >= 2 {
                if lastShakeDirection != 0 && direction != lastShakeDirection {
                    shakeDirectionChanges += 1
                    isShaking = true

                    if shakeDirectionChanges >= 5 {
                        return true
                    }
                }
                lastShakeDirection = direction
            }
        }

        lastShakeCol = col
        return false
    }

    private func resetShake() {
        shakeDirectionChanges = 0
        lastShakeCol = nil
        lastShakeDirection = 0
        isShaking = false
        shakeTimer?.invalidate()
        shakeTimer = nil
    }

    // MARK: - Double Swipe Detection (from prototype lines 254-275)

    private func detectDoubleSwipe(startCol: Int, endCol: Int, duration: TimeInterval) -> String? {
        let swipeDistance = endCol - startCol
        let minSwipeDistance = 6

        guard abs(swipeDistance) >= minSwipeDistance, duration <= 0.3 else {
            return nil
        }

        let direction = swipeDistance > 0 ? "right" : "left"
        let now = Date()

        if now.timeIntervalSince(lastSwipeTime) < 0.5 && direction == lastSwipeDirection {
            lastSwipeTime = .distantPast
            lastSwipeDirection = nil
            return direction
        }

        lastSwipeTime = now
        lastSwipeDirection = direction
        return nil
    }

    // MARK: - Undo/Redo

    func undo() {
        guard canUndo else { return }
        historyIndex -= 1
        loadFromHistory()
        showTooltip(.undo)
    }

    func redo() {
        guard canRedo else { return }
        historyIndex += 1
        loadFromHistory()
        showTooltip(.redo)
    }

    private func saveToHistory() {
        if let data = try? JSONEncoder().encode(pattern) {
            // Remove any redo history
            if historyIndex < history.count - 1 {
                history = Array(history.prefix(historyIndex + 1))
            }
            history.append(data)
            if history.count > maxHistory {
                history.removeFirst()
            }
            historyIndex = history.count - 1
        }
    }

    private func loadFromHistory() {
        guard historyIndex >= 0 && historyIndex < history.count else { return }
        if let loadedPattern = try? JSONDecoder().decode(Pattern.self, from: history[historyIndex]) {
            pattern = loadedPattern
            objectWillChange.send()
        }
    }

    // MARK: - Tooltips

    func showTooltip(_ key: TooltipKey) {
        tooltipTimer?.invalidate()
        currentTooltip = key
        tooltipPixels = TooltipSystem.generatePixels(for: key.displayText)

        tooltipTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.currentTooltip = nil
                self?.tooltipPixels = []
            }
        }
    }

    func showTooltipForGesture(_ gestureType: GestureType) {
        if let key = TooltipSystem.tooltipKey(for: gestureType) {
            showTooltip(key)
        }
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
        let savedBPM = UserDefaults.standard.integer(forKey: "sequencer.bpm")
        if savedBPM >= 60 && savedBPM <= 200 {
            bpm = savedBPM
        }

        if let scaleRaw = UserDefaults.standard.string(forKey: "sequencer.scale"),
           let scale = Scale(rawValue: scaleRaw) {
            currentScale = scale
        }

        let rootNoteRaw = UserDefaults.standard.integer(forKey: "sequencer.rootNote")
        if let note = Note(rawValue: rootNoteRaw) {
            rootNote = note
        }

        showGhostNotes = UserDefaults.standard.bool(forKey: "sequencer.ghostNotes")
        if !UserDefaults.standard.bool(forKey: "sequencer.ghostNotes.hasBeenSet") {
            showGhostNotes = true
            UserDefaults.standard.set(true, forKey: "sequencer.ghostNotes.hasBeenSet")
        }

        let savedLength = UserDefaults.standard.integer(forKey: "sequencer.patternLength")
        if savedLength >= 8 && savedLength <= 32 {
            patternLength = savedLength
        }
    }
}
