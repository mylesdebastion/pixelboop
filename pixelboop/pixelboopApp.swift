//
//  pixelboopApp.swift
//  pixelboop
//
//  Created by dbi mac mini m4 on 1/2/26.
//

import SwiftUI

@main
struct PixelBoopApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Lock app to landscape-only - grid is 44×24 (landscape aspect ratio)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .landscape // Landscape left and right only
    }
}
