//
//  PixelGridUIView.swift
//  pixelboop
//
//  Complete pixel grid rendering matching prototype exactly
//  44x24 grid with all tracks, controls, and gestures
//

import UIKit

// MARK: - Colors

struct AppColors {
    // Note colors - chromatic wheel (from prototype lines 6-10)
    static let noteColors: [UIColor] = [
        UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),      // 0: C  - Red
        UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0),     // 1: C# - Orange
        UIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1.0),     // 2: D  - Dark Orange
        UIColor(red: 1.0, green: 0.78, blue: 0.0, alpha: 1.0),     // 3: D# - Yellow-Orange
        UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),      // 4: E  - Yellow
        UIColor(red: 0.6, green: 0.8, blue: 0.2, alpha: 1.0),      // 5: F  - Yellow-Green
        UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),      // 6: F# - Green
        UIColor(red: 0.0, green: 1.0, blue: 0.67, alpha: 1.0),     // 7: G  - Cyan-Green
        UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),      // 8: G# - Cyan
        UIColor(red: 0.0, green: 0.67, blue: 1.0, alpha: 1.0),     // 9: A  - Sky Blue
        UIColor(red: 0.0, green: 0.33, blue: 1.0, alpha: 1.0),     // 10: A# - Blue
        UIColor(red: 0.54, green: 0.17, blue: 0.89, alpha: 1.0)    // 11: B  - Purple
    ]

    // Track colors (from prototype lines 14-16)
    static let trackColors: [TrackType: UIColor] = [
        .melody: UIColor(red: 0.97, green: 0.86, blue: 0.44, alpha: 1.0),  // #f7dc6f
        .chords: UIColor(red: 0.31, green: 0.80, blue: 0.77, alpha: 1.0),  // #4ecdc4
        .bass: UIColor(red: 0.27, green: 0.72, blue: 0.82, alpha: 1.0),    // #45b7d1
        .rhythm: UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0)    // #ff6b6b
    ]

    static func colorForPitch(_ pitch: Int) -> UIColor {
        let index = ((pitch % 12) + 12) % 12
        return noteColors[index]
    }
}

// MARK: - Pixel Grid UIView

class PixelGridUIView: UIView {

    // MARK: - Constants

    private let COLS = 44
    private let ROWS = 24
    private let GAP_SIZE: CGFloat = 1.0

    // MARK: - Properties

    private var pixelSize: CGFloat = 10.0
    private var gridOffsetX: CGFloat = 0.0
    private var gridOffsetY: CGFloat = 0.0
    private let gridBackgroundColor = UIColor(white: 0.04, alpha: 1.0)  // #0a0a0a
    private let cellOffColor = UIColor(white: 0.1, alpha: 1.0)

    // Grid state
    private var grid: [[UIColor?]] = []

    // ViewModel reference
    private weak var viewModel: SequencerViewModel?

    // Gesture state
    private var touchStartPoint: CGPoint?
    private var touchStartTime: Date?
    private var lastTapTime: Date = .distantPast
    private var lastTapLocation: (row: Int, col: Int)?

    // Control colors
    private let COLOR_PLAY = UIColor(red: 0.27, green: 1.0, blue: 0.27, alpha: 1.0)
    private let COLOR_STOP = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
    private let COLOR_SCALE_MAJOR = UIColor(red: 1.0, green: 0.67, blue: 0.0, alpha: 1.0)
    private let COLOR_SCALE_MINOR = UIColor(red: 0.0, green: 0.67, blue: 1.0, alpha: 1.0)
    private let COLOR_SCALE_PENTA = UIColor(red: 0.67, green: 0.0, blue: 1.0, alpha: 1.0)
    private let COLOR_ACTIVE = UIColor(white: 0.53, alpha: 1.0)
    private let COLOR_INACTIVE = UIColor(white: 0.2, alpha: 1.0)
    private let COLOR_GHOST_ENABLED = UIColor(white: 0.4, alpha: 1.0)
    private let COLOR_GHOST_DISABLED = UIColor(white: 0.13, alpha: 1.0)
    private let COLOR_CONTROL_BUTTON = UIColor(white: 0.27, alpha: 1.0)
    private let COLOR_CLEAR = UIColor(red: 0.4, green: 0.13, blue: 0.13, alpha: 1.0)

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        initializeGrid()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        initializeGrid()
    }

    private func setupView() {
        backgroundColor = gridBackgroundColor
        isOpaque = true
        isMultipleTouchEnabled = false
    }

    private func initializeGrid() {
        grid = Array(repeating: Array(repeating: nil, count: ROWS), count: COLS)
    }

    func configure(viewModel: SequencerViewModel) {
        self.viewModel = viewModel
        setNeedsDisplay()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        calculatePixelSize()
        setNeedsDisplay()
    }

    private func calculatePixelSize() {
        let minMargin: CGFloat = 8.0

        let availableWidth = bounds.width - (minMargin * 2)
        let availableHeight = bounds.height - (minMargin * 2)

        let pixelSizeFromWidth = (availableWidth - CGFloat(COLS - 1) * GAP_SIZE) / CGFloat(COLS)
        let pixelSizeFromHeight = (availableHeight - CGFloat(ROWS - 1) * GAP_SIZE) / CGFloat(ROWS)

        pixelSize = floor(min(pixelSizeFromWidth, pixelSizeFromHeight))

        let gridWidth = CGFloat(COLS) * pixelSize + CGFloat(COLS - 1) * GAP_SIZE
        let gridHeight = CGFloat(ROWS) * pixelSize + CGFloat(ROWS - 1) * GAP_SIZE

        gridOffsetX = floor((bounds.width - gridWidth) / 2.0)
        gridOffsetY = floor((bounds.height - gridHeight) / 2.0)
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let vm = viewModel else { return }

        // Fill background
        context.setFillColor(gridBackgroundColor.cgColor)
        context.fill(rect)

        // Build grid state
        buildGrid(viewModel: vm)

        // Render grid
        for col in 0..<COLS {
            for row in 0..<ROWS {
                let x = gridOffsetX + CGFloat(col) * (pixelSize + GAP_SIZE)
                let y = gridOffsetY + CGFloat(row) * (pixelSize + GAP_SIZE)
                let pixelRect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)

                if let cellColor = grid[col][row] {
                    context.setFillColor(cellColor.cgColor)
                } else {
                    context.setFillColor(cellOffColor.cgColor)
                }
                context.fill(pixelRect)
            }
        }
    }

    // MARK: - Grid Building (matches prototype getPixelGrid lines 671-922)

    private func buildGrid(viewModel vm: SequencerViewModel) {
        // Clear grid
        for col in 0..<COLS {
            for row in 0..<ROWS {
                grid[col][row] = nil
            }
        }

        // Row 0: Controls (lines 676-713)
        renderRow0Controls(vm)

        // Row 1: Step markers (lines 716-729)
        renderRow1StepMarkers(vm)

        // Rows 2-21: Track grids (lines 732-877)
        renderTracks(vm)

        // Rows 22-23: Overview (lines 879-907)
        renderOverview(vm)

        // Apply gesture preview
        applyGesturePreview(vm)

        // Apply tooltips LAST so they're always visible on top (lines 909-919)
        applyTooltips(vm)
    }

    // MARK: - Row 0: Controls (from prototype lines 676-713)

    private func renderRow0Controls(_ vm: SequencerViewModel) {
        let row = 0

        // Play/Stop (cols 0-2)
        let playColor = vm.isPlaying ? COLOR_STOP : COLOR_PLAY
        for col in 0..<3 {
            grid[col][row] = playColor
        }

        // Undo (col 4)
        grid[4][row] = vm.canUndo ? COLOR_ACTIVE : COLOR_INACTIVE

        // Redo (col 5)
        grid[5][row] = vm.canRedo ? COLOR_ACTIVE : COLOR_INACTIVE

        // Scale selectors (cols 7-9)
        grid[7][row] = vm.currentScale == .major ? COLOR_SCALE_MAJOR : dimColor(COLOR_SCALE_MAJOR)
        grid[8][row] = vm.currentScale == .minor ? COLOR_SCALE_MINOR : dimColor(COLOR_SCALE_MINOR)
        grid[9][row] = vm.currentScale == .pentatonic ? COLOR_SCALE_PENTA : dimColor(COLOR_SCALE_PENTA)

        // Root note selectors (cols 11-22)
        for noteIndex in 0..<12 {
            let col = 11 + noteIndex
            let isSelected = noteIndex == vm.rootNote.rawValue
            grid[col][row] = isSelected ? AppColors.noteColors[noteIndex] : dimColor(AppColors.noteColors[noteIndex])
        }

        // Ghost toggle (col 24)
        grid[24][row] = vm.showGhostNotes ? COLOR_GHOST_ENABLED : COLOR_GHOST_DISABLED

        // BPM controls (cols 26-28)
        grid[26][row] = COLOR_CONTROL_BUTTON
        grid[27][row] = hslColor(hue: CGFloat(vm.bpm), saturation: 0.7, lightness: 0.5)
        grid[28][row] = COLOR_CONTROL_BUTTON

        // Pattern length controls (cols 30-32)
        grid[30][row] = COLOR_CONTROL_BUTTON
        grid[31][row] = hslColor(hue: CGFloat(vm.patternLength * 8), saturation: 0.7, lightness: 0.5)
        grid[32][row] = COLOR_CONTROL_BUTTON

        // Shake indicator (cols 34-37)
        let shakeColor = vm.isShaking ?
            hslColor(hue: CGFloat(360 - vm.shakeDirectionChanges * 60), saturation: 1.0, lightness: 0.5) :
            UIColor(white: 0.13, alpha: 1.0)
        for col in 34..<38 {
            grid[col][row] = shakeColor
        }

        // Clear button (cols 40-43)
        for col in 40..<44 {
            grid[col][row] = COLOR_CLEAR
        }
    }

    // MARK: - Row 1: Step Markers (from prototype lines 716-729)

    private func renderRow1StepMarkers(_ vm: SequencerViewModel) {
        let row = 1

        // Left columns (track label area)
        for col in 0..<4 {
            grid[col][row] = UIColor(white: 0.13, alpha: 1.0)
        }

        // Step markers
        for step in 0..<vm.patternLength {
            let col = GridConstants.columnForStep(step)
            guard col < COLS else { continue }

            let isBeat = step % 4 == 0
            let isBar = step % 8 == 0
            let isPulse = step == vm.pulseStep
            let isPlayhead = step == vm.currentStep && vm.isPlaying

            let color: UIColor
            if isPulse {
                color = .white
            } else if isPlayhead {
                color = UIColor(white: 0.67, alpha: 1.0)
            } else if isBar {
                color = UIColor(white: 0.33, alpha: 1.0)
            } else if isBeat {
                color = UIColor(white: 0.2, alpha: 1.0)
            } else {
                color = UIColor(white: 0.1, alpha: 1.0)
            }

            grid[col][row] = color
        }
    }

    // MARK: - Tracks (from prototype lines 732-877)

    private func renderTracks(_ vm: SequencerViewModel) {
        let trackConfigs: [(track: TrackType, startRow: Int, height: Int)] = [
            (.melody, GridConstants.Melody.startRow, GridConstants.Melody.height),
            (.chords, GridConstants.Chords.startRow, GridConstants.Chords.height),
            (.bass, GridConstants.Bass.startRow, GridConstants.Bass.height),
            (.rhythm, GridConstants.Rhythm.startRow, GridConstants.Rhythm.height)
        ]

        let scaleNotes = GestureInterpreter.getScaleNotes(scale: vm.currentScale, rootNote: vm.rootNote)

        for config in trackConfigs {
            let track = config.track
            let startRow = config.startRow
            let height = config.height

            let isMuted = vm.muteState.isMuted(track)
            let isSoloed = vm.muteState.soloed == track

            // Track labels (cols 0-3)
            for localRow in 0..<height {
                let row = startRow + localRow
                let intensity = 1.0 - CGFloat(localRow) / CGFloat(height) * 0.5
                let trackColor = AppColors.trackColors[track]!

                // Mute button (col 0)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                trackColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                let alpha: CGFloat = isMuted ? 0.2 : (isSoloed ? 1.0 : intensity * 0.8)
                grid[0][row] = UIColor(red: r, green: g, blue: b, alpha: alpha)

                // Solo button (col 1)
                grid[1][row] = isSoloed ? .white : UIColor(white: 0.2, alpha: 1.0)

                // Separator (cols 2-3)
                grid[2][row] = UIColor(white: 0.07, alpha: 1.0)
                grid[3][row] = nil
            }

            // Grid cells
            for localRow in 0..<height {
                let row = startRow + localRow
                let noteBase = GridConstants.noteForRow(row, track: track)

                for step in 0..<vm.patternLength {
                    let col = GridConstants.columnForStep(step)
                    guard col < COLS else { continue }

                    // Check for notes in this cell (with tolerance for pitch mapping)
                    let noteStart = max(0, noteBase - 1)
                    let noteEnd = min(11, noteBase + 1)

                    var velocity = 0
                    var activeNote = noteBase

                    for n in noteStart...noteEnd {
                        let v = vm.pattern.getVelocity(track: track, note: n, step: step)
                        if v > 0 {
                            velocity = v
                            activeNote = n
                            break
                        }
                    }

                    let isPlayhead = step == vm.currentStep && vm.isPlaying
                    let inScale = track != .rhythm && GestureInterpreter.isInScale(note: noteBase, scaleNotes: scaleNotes)

                    // Ghost notes from other tracks
                    var ghostColor: UIColor? = nil
                    if vm.showGhostNotes && velocity == 0 {
                        for otherTrack in TrackColors.order {
                            if otherTrack != track {
                                for n in noteStart...noteEnd {
                                    if vm.pattern.getVelocity(track: otherTrack, note: n, step: step) > 0 {
                                        ghostColor = AppColors.trackColors[otherTrack]?.withAlphaComponent(0.13)
                                        break
                                    }
                                }
                            }
                            if ghostColor != nil { break }
                        }
                    }

                    // Determine cell color
                    var color: UIColor? = nil

                    if velocity > 0 {
                        let noteColor = AppColors.colorForPitch(activeNote)
                        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                        noteColor.getRed(&r, green: &g, blue: &b, alpha: &a)

                        switch velocity {
                        case 2:
                            // Accent - full brightness
                            color = noteColor
                        case 3:
                            // Sustain continuation - faded
                            let sustainFade = calculateSustainFade(track: track, note: activeNote, step: step, vm: vm)
                            color = UIColor(red: r, green: g, blue: b, alpha: sustainFade)
                        default:
                            // Normal note - 0.73 alpha (0xBB)
                            color = UIColor(red: r, green: g, blue: b, alpha: 0.73)
                        }

                        // Apply mute dimming
                        if isMuted {
                            color = color?.withAlphaComponent(0.4)
                        }
                    } else if let ghost = ghostColor {
                        color = ghost
                    } else if isPlayhead {
                        color = UIColor(white: 0.1, alpha: 1.0)
                    } else if step % 8 == 0 {
                        color = UIColor(white: 0.07, alpha: 1.0)
                    } else if !inScale && track != .rhythm {
                        color = UIColor(white: 0.02, alpha: 1.0)
                    }

                    grid[col][row] = color
                }
            }
        }
    }

    // MARK: - Calculate Sustain Fade (from prototype lines 793-825)

    private func calculateSustainFade(track: TrackType, note: Int, step: Int, vm: SequencerViewModel) -> CGFloat {
        // Find sustain start
        var sustainStart = step
        var sustainLength = 1

        for s in 1..<vm.patternLength {
            let prevStep = (step - s + vm.patternLength) % vm.patternLength
            let prevVel = vm.pattern.getVelocity(track: track, note: note, step: prevStep)
            if prevVel == 3 {
                sustainStart = prevStep
                sustainLength += 1
            } else if prevVel == 1 || prevVel == 2 {
                sustainStart = prevStep
                sustainLength += 1
                break
            } else {
                break
            }
        }

        // Count forward for total length
        for s in 1..<vm.patternLength {
            let nextStep = (step + s) % vm.patternLength
            if vm.pattern.getVelocity(track: track, note: note, step: nextStep) == 3 {
                sustainLength += 1
            } else {
                break
            }
        }

        // Calculate position and fade
        let positionInSustain = CGFloat((step - sustainStart + vm.patternLength) % vm.patternLength) / CGFloat(sustainLength)

        // ADSR-like fade: hold at ~80% for first 40%, then fade
        if positionInSustain < 0.4 {
            return 0.85
        } else {
            return max(0.25, 1.0 - positionInSustain * 0.9)
        }
    }

    // MARK: - Overview Rows (from prototype lines 879-907)

    private func renderOverview(_ vm: SequencerViewModel) {
        // Left columns
        for col in 0..<4 {
            grid[col][22] = UIColor(white: 0.13, alpha: 1.0)
            grid[col][23] = UIColor(white: 0.07, alpha: 1.0)
        }

        // Step overview
        for step in 0..<vm.patternLength {
            let col = GridConstants.columnForStep(step)
            guard col < COLS else { continue }

            var activeTrack: TrackType? = nil
            var activeNote = 0

            for track in TrackColors.order {
                guard !vm.muteState.isMuted(track) else { continue }

                for n in 0..<12 {
                    if vm.pattern.getVelocity(track: track, note: n, step: step) > 0 {
                        activeTrack = track
                        activeNote = n
                        break
                    }
                }
                if activeTrack != nil { break }
            }

            let isPlayhead = step == vm.currentStep && vm.isPlaying

            // Row 22: Track color
            if let track = activeTrack {
                grid[col][22] = AppColors.trackColors[track]
            } else {
                grid[col][22] = isPlayhead ? UIColor(white: 0.13, alpha: 1.0) : nil
            }

            // Row 23: Note color
            if activeTrack != nil {
                grid[col][23] = AppColors.colorForPitch(activeNote)
            } else {
                grid[col][23] = UIColor(white: 0.02, alpha: 1.0)
            }
        }
    }

    // MARK: - Tooltips (from prototype lines 909-919)

    private func applyTooltips(_ vm: SequencerViewModel) {
        for pixel in vm.tooltipPixels {
            guard pixel.row >= 0 && pixel.row < ROWS && pixel.col >= 0 && pixel.col < COLS else { continue }

            // Get the base color, forcing full opacity for consistent blending
            // (matches prototype which uses baseColor without alpha modifications)
            let currentColor = grid[pixel.col][pixel.row] ?? cellOffColor
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            currentColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            let opaqueBase = UIColor(red: r, green: g, blue: b, alpha: 1.0)
            grid[pixel.col][pixel.row] = opaqueBase.blendedWithWhite(amount: pixel.intensity)
        }
    }

    // MARK: - Gesture Preview

    private func applyGesturePreview(_ vm: SequencerViewModel) {
        guard !vm.gesturePreview.isEmpty else { return }
        guard let startRow = vm.gesturePreview.first.flatMap({ _ in
            // Get track from gesture
            nil as Int?  // We need the row from the gesture start, handled differently
        }) else { return }

        // For each preview note, highlight the corresponding cell
        for note in vm.gesturePreview {
            let col = GridConstants.columnForStep(note.step)
            guard col < COLS else { continue }

            // Find the row for this note - need to map through all tracks
            // This is a simplification - the gesture preview should include row info
            // For now, apply a general highlight
            grid[col][2] = UIColor(white: 1.0, alpha: 0.5)  // Placeholder
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        touchStartPoint = location
        touchStartTime = Date()

        guard let (col, row) = gridCellAtPoint(location) else { return }

        // Check for double-tap
        let now = Date()
        if let lastLoc = lastTapLocation,
           now.timeIntervalSince(lastTapTime) < 0.3,
           abs(lastLoc.row - row) <= 1,
           abs(lastLoc.col - col) <= 1 {
            // Double-tap detected
            handleDoubleTap(row: row, col: col)
            lastTapLocation = nil
            lastTapTime = .distantPast
            return
        }

        lastTapLocation = (row, col)
        lastTapTime = now

        // Handle Row 0 controls immediately
        if row == 0 {
            handleControlTap(col: col)
            return
        }

        // Start gesture tracking
        viewModel?.startGesture(row: row, col: col)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        guard let (col, row) = gridCellAtPoint(location) else { return }

        viewModel?.updateGesture(row: row, col: col)
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewModel?.endGesture()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        touchStartPoint = nil
        touchStartTime = nil
        setNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewModel?.endGesture()
        touchStartPoint = nil
        touchStartTime = nil
        setNeedsDisplay()
    }

    // MARK: - Double Tap Handling

    private func handleDoubleTap(row: Int, col: Int) {
        guard let vm = viewModel else { return }

        // Double-tap on non-grid area toggles play
        guard let track = GridConstants.trackForRow(row) else {
            vm.togglePlayback()
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            setNeedsDisplay()
            return
        }

        // Double-tap on grid erases step
        vm.eraseStep(col: col, row: row)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        setNeedsDisplay()
    }

    // MARK: - Control Tap Handling (from prototype lines 924-968)

    private func handleControlTap(col: Int) {
        guard let vm = viewModel else { return }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()

        switch col {
        case 0...2:  // Play/Stop
            vm.togglePlayback()
            generator.impactOccurred()

        case 4:  // Undo
            guard vm.canUndo else { return }
            vm.undo()
            generator.impactOccurred()

        case 5:  // Redo
            guard vm.canRedo else { return }
            vm.redo()
            generator.impactOccurred()

        case 7:  // Major scale
            vm.setScale(.major)
            generator.impactOccurred()

        case 8:  // Minor scale
            vm.setScale(.minor)
            generator.impactOccurred()

        case 9:  // Pentatonic scale
            vm.setScale(.pentatonic)
            generator.impactOccurred()

        case 11...22:  // Root notes
            let noteIndex = col - 11
            if let note = Note(rawValue: noteIndex) {
                vm.setRootNote(note)
                generator.impactOccurred()
            }

        case 24:  // Ghost notes toggle
            vm.toggleGhostNotes()
            generator.impactOccurred()

        case 26:  // BPM down
            vm.adjustBPM(-5)
            generator.impactOccurred()

        case 28:  // BPM up
            vm.adjustBPM(5)
            generator.impactOccurred()

        case 30:  // Pattern length down
            vm.adjustPatternLength(-4)
            generator.impactOccurred()

        case 32:  // Pattern length up
            vm.adjustPatternLength(4)
            generator.impactOccurred()

        case 40...43:  // Clear
            vm.clearPattern()
            generator.impactOccurred()

        default:
            break
        }

        setNeedsDisplay()
    }

    // MARK: - Mute/Solo Handling

    private func handleMuteSoloTap(row: Int, col: Int) {
        guard let vm = viewModel else { return }
        guard let track = GridConstants.trackForRow(row) else { return }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if col == 0 {
            vm.toggleMute(track)
        } else if col == 1 {
            vm.toggleSolo(track)
        }

        setNeedsDisplay()
    }

    // MARK: - Helper Methods

    private func gridCellAtPoint(_ point: CGPoint) -> (col: Int, row: Int)? {
        let adjustedX = point.x - gridOffsetX
        let adjustedY = point.y - gridOffsetY

        let col = Int(adjustedX / (pixelSize + GAP_SIZE))
        let row = Int(adjustedY / (pixelSize + GAP_SIZE))

        guard col >= 0 && col < COLS && row >= 0 && row < ROWS else {
            return nil
        }

        return (col, row)
    }

    private func dimColor(_ color: UIColor) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r * 0.3, green: g * 0.3, blue: b * 0.3, alpha: a)
    }

    private func hslColor(hue: CGFloat, saturation: CGFloat, lightness: CGFloat) -> UIColor {
        let normalizedHue = (hue.truncatingRemainder(dividingBy: 360)) / 360.0
        return UIColor(hue: normalizedHue, saturation: saturation, brightness: lightness, alpha: 1.0)
    }
}
