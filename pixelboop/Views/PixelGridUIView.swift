//
//  PixelGridUIView.swift
//  pixelboop
//
//  Created by AI Dev Agent on 1/2/26.
//

import UIKit

/// UIKit view that renders the 44×24 pixel grid using CoreGraphics
/// This view handles custom pixel-level rendering for performance
class PixelGridUIView: UIView {

    // MARK: - Constants

    private let COLS = 44
    private let ROWS = 24
    private let GAP_SIZE: CGFloat = 1.0

    // MARK: - Properties

    private var pixelSize: CGFloat = 10.0
    private let gridBackgroundColor = UIColor(red: 0x0a/255.0, green: 0x0a/255.0, blue: 0x0a/255.0, alpha: 1.0) // #0a0a0a

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = gridBackgroundColor
        self.isOpaque = true
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        calculatePixelSize()
        setNeedsDisplay()
    }

    private func calculatePixelSize() {
        // Calculate available space
        let availableWidth = bounds.width
        let availableHeight = bounds.height

        // Grid orientation: 44 columns run VERTICALLY (timeline), 24 rows run HORIZONTALLY (tracks)
        // In portrait: height accommodates 44 cols, width accommodates 24 rows
        let widthPerPixel = (availableWidth - CGFloat(ROWS - 1) * GAP_SIZE) / CGFloat(ROWS)
        let heightPerPixel = (availableHeight - CGFloat(COLS - 1) * GAP_SIZE) / CGFloat(COLS)

        // Use the smaller dimension to ensure grid fits
        var calculatedSize = floor(min(widthPerPixel, heightPerPixel))

        // Constrain to 6-20px range
        calculatedSize = max(6.0, min(20.0, calculatedSize))

        pixelSize = calculatedSize
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Fill background
        context.setFillColor(gridBackgroundColor.cgColor)
        context.fill(rect)

        // Draw pixels with 90° rotation:
        // - 44 columns run VERTICALLY (y-axis) - this is the timeline
        // - 24 rows run HORIZONTALLY (x-axis) - these are the tracks/pitches
        for col in 0..<COLS {
            for row in 0..<ROWS {
                let x = CGFloat(row) * (pixelSize + GAP_SIZE)
                let y = CGFloat(col) * (pixelSize + GAP_SIZE)
                let pixelRect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)

                // For now, draw empty pixels (slightly lighter than background for visibility)
                // Future stories will add colored notes here
                context.setFillColor(UIColor(white: 0.1, alpha: 1.0).cgColor)
                context.fill(pixelRect)
            }
        }
    }

    // MARK: - Public Interface

    /// Returns the intrinsic content size based on pixel size and grid dimensions
    /// Note: 44 columns run vertically (height), 24 rows run horizontally (width)
    override var intrinsicContentSize: CGSize {
        let width = CGFloat(ROWS) * pixelSize + CGFloat(ROWS - 1) * GAP_SIZE
        let height = CGFloat(COLS) * pixelSize + CGFloat(COLS - 1) * GAP_SIZE
        return CGSize(width: width, height: height)
    }
}
