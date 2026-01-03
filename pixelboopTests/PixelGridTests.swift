//
//  PixelGridTests.swift
//  pixelboopTests
//
//  Created by AI Dev Agent on 1/2/26.
//

import XCTest
@testable import pixelboop

final class PixelGridTests: XCTestCase {

    // MARK: - Grid Dimension Tests

    func test_gridDimensions_match44x24() {
        let gridView = PixelGridUIView(frame: .zero)
        // Access via mirror since properties are private
        let mirror = Mirror(reflecting: gridView)

        let cols = mirror.children.first(where: { $0.label == "COLS" })?.value as? Int
        let rows = mirror.children.first(where: { $0.label == "ROWS" })?.value as? Int

        XCTAssertEqual(cols, 44, "Grid should have 44 columns")
        XCTAssertEqual(rows, 24, "Grid should have 24 rows")
    }

    func test_gapSize_is1px() {
        let gridView = PixelGridUIView(frame: .zero)
        let mirror = Mirror(reflecting: gridView)

        let gapSize = mirror.children.first(where: { $0.label == "GAP_SIZE" })?.value as? CGFloat

        XCTAssertEqual(gapSize, 1.0, "Gap size should be 1px")
    }

    // MARK: - Background Color Tests

    func test_backgroundColor_isDark() {
        let gridView = PixelGridUIView(frame: .zero)

        // Background should be #0a0a0a (dark)
        let expectedColor = UIColor(red: 0x0a/255.0, green: 0x0a/255.0, blue: 0x0a/255.0, alpha: 1.0)

        XCTAssertNotNil(gridView.backgroundColor, "Background color should be set")

        // Extract RGB components
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        gridView.backgroundColor?.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        expectedColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        XCTAssertEqual(r1, r2, accuracy: 0.01, "Red component should match")
        XCTAssertEqual(g1, g2, accuracy: 0.01, "Green component should match")
        XCTAssertEqual(b1, b2, accuracy: 0.01, "Blue component should match")
    }

    // MARK: - Responsive Sizing Tests

    func test_intrinsicContentSize_calculatesCorrectly() {
        let gridView = PixelGridUIView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))

        // Trigger layout to calculate pixel size
        gridView.layoutIfNeeded()

        let size = gridView.intrinsicContentSize

        // Intrinsic size should be positive
        XCTAssertGreaterThan(size.width, 0, "Intrinsic width should be positive")
        XCTAssertGreaterThan(size.height, 0, "Intrinsic height should be positive")

        // Aspect ratio check: 44 cols / 24 rows ≈ 1.833
        let aspectRatio = size.width / size.height
        XCTAssertEqual(aspectRatio, 44.0/24.0, accuracy: 0.1, "Aspect ratio should match grid dimensions")
    }

    func test_pixelSize_staysInRange() {
        // Test various device sizes
        let testSizes = [
            CGSize(width: 375, height: 667),   // iPhone SE
            CGSize(width: 430, height: 932),   // iPhone 15 Pro Max
            CGSize(width: 390, height: 844),   // iPhone 14 Pro
        ]

        for deviceSize in testSizes {
            let gridView = PixelGridUIView(frame: CGRect(origin: .zero, size: deviceSize))
            gridView.layoutIfNeeded()

            let intrinsicSize = gridView.intrinsicContentSize

            // Calculate implied pixel size (reverse engineer from intrinsic size)
            // intrinsicSize.width = 44 * pixelSize + 43 * 1.0
            let impliedPixelSize = (intrinsicSize.width - 43.0) / 44.0

            XCTAssertGreaterThanOrEqual(impliedPixelSize, 6.0, "Pixel size should be at least 6px for device size \(deviceSize)")
            XCTAssertLessThanOrEqual(impliedPixelSize, 20.0, "Pixel size should be at most 20px for device size \(deviceSize)")
        }
    }
}
