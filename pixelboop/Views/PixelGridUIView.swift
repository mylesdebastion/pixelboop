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

    private let COLS = 44  // Timeline steps (vertical)
    private let ROWS = 24  // Tracks/pitches (horizontal)
    private let GAP_SIZE: CGFloat = 1.0

    // MARK: - Properties

    private var pixelSize: CGFloat = 10.0
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
        // FR102: Vertical Fill Approach - Fill 100% of vertical canvas (landscape-only)
        // App is locked to landscape, so this only calculates once on initial layout
        let availableHeight = bounds.height
        let calculatedSize = floor(availableHeight / CGFloat(COLS))
        pixelSize = calculatedSize
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Fill background
        context.setFillColor(gridBackgroundColor.cgColor)
        context.fill(rect)

        // Render the grid by iterating through cells and drawing each one
        // Grid orientation: 44 columns run VERTICALLY (timeline), 24 rows run HORIZONTALLY (tracks)
        for col in 0..<COLS {
            for row in 0..<ROWS {
                // Calculate pixel position
                let x = CGFloat(row) * (pixelSize + GAP_SIZE)
                let y = CGFloat(col) * (pixelSize + GAP_SIZE)
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
    ///   - col: Column index (0-43, vertical timeline)
    ///   - row: Row index (0-23, horizontal track)
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
        let width = CGFloat(ROWS) * pixelSize + CGFloat(ROWS - 1) * GAP_SIZE
        let height = CGFloat(COLS) * pixelSize + CGFloat(COLS - 1) * GAP_SIZE
        return CGSize(width: width, height: height)
    }
}
