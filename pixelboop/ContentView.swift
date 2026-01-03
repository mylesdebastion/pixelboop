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

            PixelGridView()
                .padding()
        }
    }
}

#Preview {
    ContentView()
}
