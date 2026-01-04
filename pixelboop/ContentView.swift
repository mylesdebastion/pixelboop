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

            // 44×24 pixel grid (fills 100% of vertical canvas height in landscape)
            // App is locked to landscape-only (44 wide × 24 tall aspect ratio)
            PixelGridView()
        }
        .statusBar(hidden: true) // Hide status bar for full-screen grid
        .ignoresSafeArea() // Full canvas usage
    }
}

#Preview {
    ContentView()
}
