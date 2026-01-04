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
}
