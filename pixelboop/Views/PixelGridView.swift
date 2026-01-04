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

    @ObservedObject var viewModel: SequencerViewModel

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> PixelGridUIView {
        let gridView = PixelGridUIView()
        gridView.configure(viewModel: viewModel)
        return gridView
    }

    func updateUIView(_ uiView: PixelGridUIView, context: Context) {
        // Trigger redraw when ViewModel state changes
        uiView.setNeedsDisplay()
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @StateObject var viewModel = SequencerViewModel()

        var body: some View {
            PixelGridView(viewModel: viewModel)
                .background(Color.black)
        }
    }

    return PreviewWrapper()
}
