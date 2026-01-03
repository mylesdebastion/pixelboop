//
//  PixelGridView.swift
//  pixelboop
//
//  Created by AI Dev Agent on 1/2/26.
//

import SwiftUI

/// SwiftUI wrapper for PixelGridUIView using UIViewRepresentable
/// Bridges UIKit pixel grid rendering to SwiftUI
struct PixelGridView: UIViewRepresentable {

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> PixelGridUIView {
        let gridView = PixelGridUIView()
        return gridView
    }

    func updateUIView(_ uiView: PixelGridUIView, context: Context) {
        // No dynamic updates needed for this story
        // Future stories will pass note data here
    }
}

// MARK: - Preview

#Preview {
    PixelGridView()
        .background(Color.black)
}
