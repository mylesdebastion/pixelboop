//
//  ContentView.swift
//  pixelboop
//
//  Created by dbi mac mini m4 on 1/2/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // 44×24 pixel grid (fills 100% of vertical canvas height)
            // Menu column integrated within PixelGridUIView (pixel-only rendering)
            // Grid works in both portrait and landscape - user just rotates device
            PixelGridView()
        }
        .statusBar(hidden: true) // Hide status bar for full-screen grid
        .ignoresSafeArea() // Full canvas usage
    }
}

#Preview {
    ContentView()
}
