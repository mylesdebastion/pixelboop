//
//  PixelGridUIView.swift
//  pixelboop
//
//  Created by AI Dev Agent on 1/2/26.
//  Corrected: Grid-cell-based rendering (like LED matrix)
//

import UIKit

/// UIKit view that renders the 44×24 pixel grid using CoreGraphics
/// Grid is a 2D array of colored cells - THE GRID IS THE DISPLAY
/// Row 0 = Controls, Rows 1-23 = Sequencer notes
class PixelGridUIView: UIView {

    // MARK: - Constants

    private let COLS = 44  // Grid width (44 cells horizontally in landscape)
    private let ROWS = 24  // Grid height (24 cells vertically in landscape)
    private let GAP_SIZE: CGFloat = 1.0

    // MARK: - Properties

    private var pixelSize: CGFloat = 10.0
    private var gridOffsetX: CGFloat = 0.0  // For centering and touch coordinate conversion
    private var gridOffsetY: CGFloat = 0.0
    private let gridBackgroundColor = UIColor(red: 0x0a/255.0, green: 0x0a/255.0, blue: 0x0a/255.0, alpha: 1.0) // #0a0a0a

    // THE GRID - 2D array of cell colors (like an LED matrix)
    // grid[col][row] = color for that cell
    private var grid: [[UIColor?]] = Array(repeating: Array(repeating: nil, count: 24), count: 44)

    // ViewModel reference for Row 0 controls
    private weak var sequencerViewModel: SequencerViewModel?

    // MARK: - Color Constants (from prototype)

    // Note colors - chromatic wheel (12 notes)
    private let NOTE_COLORS: [UIColor] = [
        UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),      // 0: C - Red
        UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0),     // 1: C# - Orange
        UIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1.0),     // 2: D - Dark Orange
        UIColor(red: 1.0, green: 0.78, blue: 0.0, alpha: 1.0),     // 3: D# - Yellow-Orange
        UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),      // 4: E - Yellow
        UIColor(red: 0.6, green: 0.8, blue: 0.2, alpha: 1.0),      // 5: F - Yellow-Green
        UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),      // 6: F# - Green
        UIColor(red: 0.0, green: 1.0, blue: 0.67, alpha: 1.0),     // 7: G - Cyan-Green
        UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),      // 8: G# - Cyan
        UIColor(red: 0.0, green: 0.67, blue: 1.0, alpha: 1.0),     // 9: A - Sky Blue
        UIColor(red: 0.0, green: 0.33, blue: 1.0, alpha: 1.0),     // 10: A# - Blue
        UIColor(red: 0.54, green: 0.17, blue: 0.89, alpha: 1.0)    // 11: B - Purple
    ]

    // Control colors
    private let COLOR_PLAY = UIColor(red: 0.27, green: 1.0, blue: 0.27, alpha: 1.0)  // #44ff44
    private let COLOR_STOP = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)  // #ff4444
    private let COLOR_SCALE_MAJOR = UIColor(red: 1.0, green: 0.67, blue: 0.0, alpha: 1.0)  // #ffaa00
    private let COLOR_SCALE_MINOR = UIColor(red: 0.0, green: 0.67, blue: 1.0, alpha: 1.0)  // #00aaff
    private let COLOR_SCALE_PENTA = UIColor(red: 0.67, green: 0.0, blue: 1.0, alpha: 1.0)  // #aa00ff
    private let COLOR_ACTIVE = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.0)  // #888
    private let COLOR_INACTIVE = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)  // #333
    private let COLOR_GHOST_ENABLED = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)  // #666
    private let COLOR_GHOST_DISABLED = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)  // #222
    private let COLOR_CONTROL_BUTTON = UIColor(red: 0.27, green: 0.27, blue: 0.27, alpha: 1.0)  // #444
    private let COLOR_CLEAR = UIColor(red: 0.4, green: 0.13, blue: 0.13, alpha: 1.0)  // #662222

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
        self.backgroundColor = gridBackgroundColor
        self.isOpaque = true

        // Add tap gesture recognizer for Row 0 controls
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    private func initializeGrid() {
        // Initialize all cells to default (empty) color
        let defaultCellColor = UIColor(white: 0.1, alpha: 1.0) // Slightly lighter than background
        for col in 0..<COLS {
            for row in 0..<ROWS {
                grid[col][row] = defaultCellColor
            }
        }

        // Row 0 will be set by Row 0 controls (Story 1.3)
        // For now, just leave it as default
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        calculatePixelSize()
        setNeedsDisplay()
    }

    private func calculatePixelSize() {
        // FR102: Responsive sizing for landscape (44 wide × 24 tall)
        // Minimum margin to keep edge pixels accessible for touch
        let minMargin: CGFloat = 8.0

        let availableWidth = bounds.width - (minMargin * 2)
        let availableHeight = bounds.height - (minMargin * 2)

        // Calculate pixel size that fits both dimensions
        // Total width = COLS * pixelSize + (COLS - 1) * GAP_SIZE
        // Total height = ROWS * pixelSize + (ROWS - 1) * GAP_SIZE
        let pixelSizeFromWidth = (availableWidth - CGFloat(COLS - 1) * GAP_SIZE) / CGFloat(COLS)
        let pixelSizeFromHeight = (availableHeight - CGFloat(ROWS - 1) * GAP_SIZE) / CGFloat(ROWS)

        // Use smaller dimension to ensure grid fits without cutoff
        pixelSize = floor(min(pixelSizeFromWidth, pixelSizeFromHeight))

        // Calculate actual grid dimensions
        let gridWidth = CGFloat(COLS) * pixelSize + CGFloat(COLS - 1) * GAP_SIZE
        let gridHeight = CGFloat(ROWS) * pixelSize + CGFloat(ROWS - 1) * GAP_SIZE

        // Center the grid in the available space
        gridOffsetX = floor((bounds.width - gridWidth) / 2.0)
        gridOffsetY = floor((bounds.height - gridHeight) / 2.0)
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Fill background
        context.setFillColor(gridBackgroundColor.cgColor)
        context.fill(rect)

        // Update Row 0 controls if we have a ViewModel
        if let viewModel = sequencerViewModel {
            renderRow0Controls(viewModel: viewModel)
        }

        // Render the grid: 44 columns horizontally (x-axis), 24 rows vertically (y-axis)
        // Landscape orientation: 44 cells wide × 24 cells tall, centered in view
        for col in 0..<COLS {
            for row in 0..<ROWS {
                // Calculate pixel position with centering offset
                let x = gridOffsetX + CGFloat(col) * (pixelSize + GAP_SIZE)
                let y = gridOffsetY + CGFloat(row) * (pixelSize + GAP_SIZE)
                let pixelRect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)

                // Get cell color from grid array
                if let cellColor = grid[col][row] {
                    context.setFillColor(cellColor.cgColor)
                    context.fill(pixelRect)
                }
            }
        }
    }

    // MARK: - Public Interface

    /// Set the color of a specific grid cell (like setting an LED in a matrix)
    /// - Parameters:
    ///   - col: Column index (0-43, horizontal position in landscape)
    ///   - row: Row index (0-23, vertical position in landscape)
    ///   - color: Color to set the cell to (nil = use default)
    func setGridCell(col: Int, row: Int, color: UIColor?) {
        guard col >= 0 && col < COLS && row >= 0 && row < ROWS else { return }
        grid[col][row] = color
        setNeedsDisplay()
    }

    /// Get the color of a specific grid cell
    func getGridCell(col: Int, row: Int) -> UIColor? {
        guard col >= 0 && col < COLS && row >= 0 && row < ROWS else { return nil }
        return grid[col][row]
    }

    /// Clear all grid cells to default color
    func clearGrid() {
        let defaultCellColor = UIColor(white: 0.1, alpha: 1.0)
        for col in 0..<COLS {
            for row in 0..<ROWS {
                grid[col][row] = defaultCellColor
            }
        }
        setNeedsDisplay()
    }

    /// Returns the intrinsic content size based on pixel size and grid dimensions
    override var intrinsicContentSize: CGSize {
        // Landscape: 44 wide × 24 tall, centered with calculated offsets
        let width = (gridOffsetX * 2) + CGFloat(COLS) * pixelSize + CGFloat(COLS - 1) * GAP_SIZE
        let height = (gridOffsetY * 2) + CGFloat(ROWS) * pixelSize + CGFloat(ROWS - 1) * GAP_SIZE
        return CGSize(width: width, height: height)
    }

    /// Convert touch coordinates to grid cell coordinates
    /// - Parameter point: Touch point in view coordinates
    /// - Returns: (col, row) tuple, or nil if outside grid bounds
    func gridCellAtPoint(_ point: CGPoint) -> (col: Int, row: Int)? {
        // Adjust for grid offset (centering)
        let adjustedX = point.x - gridOffsetX
        let adjustedY = point.y - gridOffsetY

        // Calculate which cell was touched
        let col = Int(adjustedX / (pixelSize + GAP_SIZE))
        let row = Int(adjustedY / (pixelSize + GAP_SIZE))

        // Validate bounds
        guard col >= 0 && col < COLS && row >= 0 && row < ROWS else {
            return nil
        }

        return (col, row)
    }

    /// Configure view with SequencerViewModel reference
    func configure(viewModel: SequencerViewModel) {
        self.sequencerViewModel = viewModel
        setNeedsDisplay()
    }

    // MARK: - Row 0 Control Rendering (from prototype lines 676-713)

    private func renderRow0Controls(viewModel: SequencerViewModel) {
        let row = 0

        // Play/Stop button (cols 0-2) - green when stopped, red when playing
        let playColor = viewModel.isPlaying ? COLOR_STOP : COLOR_PLAY
        for col in 0..<3 {
            grid[col][row] = playColor
        }

        // Undo button (col 4) - gray when available, dark when not
        grid[4][row] = viewModel.canUndo ? COLOR_ACTIVE : COLOR_INACTIVE

        // Redo button (col 5) - gray when available, dark when not
        grid[5][row] = viewModel.canRedo ? COLOR_ACTIVE : COLOR_INACTIVE

        // Scale selectors (cols 7-9) - highlight selected scale
        grid[7][row] = viewModel.currentScale == .major ? COLOR_SCALE_MAJOR : dimColor(COLOR_SCALE_MAJOR)
        grid[8][row] = viewModel.currentScale == .minor ? COLOR_SCALE_MINOR : dimColor(COLOR_SCALE_MINOR)
        grid[9][row] = viewModel.currentScale == .pentatonic ? COLOR_SCALE_PENTA : dimColor(COLOR_SCALE_PENTA)

        // Root note selectors (cols 11-22) - 12 chromatic notes
        for noteIndex in 0..<12 {
            let col = 11 + noteIndex
            let isSelected = noteIndex == viewModel.rootNote.rawValue
            grid[col][row] = isSelected ? NOTE_COLORS[noteIndex] : dimColor(NOTE_COLORS[noteIndex])
        }

        // Ghost toggle (col 24) - bright when enabled, dark when disabled
        grid[24][row] = viewModel.showGhostNotes ? COLOR_GHOST_ENABLED : COLOR_GHOST_DISABLED

        // BPM controls (cols 26-28)
        // For MVP: Show BPM as single color indicator (future: 3x5 pixel font)
        grid[26][row] = COLOR_CONTROL_BUTTON  // BPM down
        grid[27][row] = hslColor(hue: CGFloat(viewModel.bpm), saturation: 0.7, lightness: 0.5)  // BPM display
        grid[28][row] = COLOR_CONTROL_BUTTON  // BPM up

        // Pattern length controls (cols 30-32)
        // For MVP: Show length as single color indicator (future: 3x5 pixel font)
        grid[30][row] = COLOR_CONTROL_BUTTON  // Length down
        grid[31][row] = hslColor(hue: CGFloat(viewModel.patternLength * 8), saturation: 0.7, lightness: 0.5)  // Length display
        grid[32][row] = COLOR_CONTROL_BUTTON  // Length up

        // Clear button (cols 40-43) - dark red warning color
        for col in 40..<44 {
            grid[col][row] = COLOR_CLEAR
        }
    }

    // MARK: - Gesture Handling

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let viewModel = sequencerViewModel else { return }

        let location = gesture.location(in: self)
        guard let (col, row) = gridCellAtPoint(location) else { return }

        // Only handle Row 0 taps (controls)
        guard row == 0 else { return }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()

        // Handle control taps based on column (from prototype lines 924-968)
        switch col {
        case 0...2:  // Play/Stop
            viewModel.togglePlayback()
            generator.impactOccurred()
            let announcement = viewModel.isPlaying ? "Pattern playing" : "Pattern stopped"
            UIAccessibility.post(notification: .announcement, argument: announcement)

        case 4:  // Undo
            guard viewModel.canUndo else { return }
            viewModel.undo()
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Action undone")

        case 5:  // Redo
            guard viewModel.canRedo else { return }
            viewModel.redo()
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Action redone")

        case 7:  // Major scale
            viewModel.setScale(.major)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Scale changed to Major")

        case 8:  // Minor scale
            viewModel.setScale(.minor)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Scale changed to Minor")

        case 9:  // Pentatonic scale
            viewModel.setScale(.pentatonic)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Scale changed to Pentatonic")

        case 11...22:  // Root notes (12 chromatic notes)
            let noteIndex = col - 11
            if let note = Note(rawValue: noteIndex) {
                viewModel.setRootNote(note)
                generator.impactOccurred()
                UIAccessibility.post(notification: .announcement, argument: "Root note changed to \(note.displayName)")
            }

        case 24:  // Ghost notes toggle
            viewModel.toggleGhostNotes()
            generator.impactOccurred()
            let ghostAnnouncement = viewModel.showGhostNotes ? "Ghost notes enabled" : "Ghost notes disabled"
            UIAccessibility.post(notification: .announcement, argument: ghostAnnouncement)

        case 26:  // BPM down
            viewModel.adjustBPM(-5)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "BPM decreased to \(viewModel.bpm)")

        case 28:  // BPM up
            viewModel.adjustBPM(5)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "BPM increased to \(viewModel.bpm)")

        case 30:  // Pattern length down
            viewModel.adjustPatternLength(-4)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Pattern length decreased to \(viewModel.patternLength)")

        case 32:  // Pattern length up
            viewModel.adjustPatternLength(4)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Pattern length increased to \(viewModel.patternLength)")

        case 40...43:  // Clear button
            viewModel.clearPattern()
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Pattern cleared")

        default:
            break
        }

        setNeedsDisplay()
    }

    // MARK: - Helper Methods

    /// Dim a color for inactive state (reduce brightness to 30%)
    private func dimColor(_ color: UIColor) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r * 0.3, green: g * 0.3, blue: b * 0.3, alpha: a)
    }

    /// Convert HSL to UIColor (for BPM/length displays)
    private func hslColor(hue: CGFloat, saturation: CGFloat, lightness: CGFloat) -> UIColor {
        // Normalize hue to 0-360 range, then to 0-1 for UIColor
        let normalizedHue = (hue.truncatingRemainder(dividingBy: 360)) / 360.0

        // Convert HSL to HSB (UIColor uses HSB)
        // Lightness = 0.5 means saturation is unchanged
        // For simplicity, using hue and saturation directly
        return UIColor(hue: normalizedHue, saturation: saturation, brightness: lightness, alpha: 1.0)
    }
}
