import SwiftUI

@main
struct WhatThePhraseApp: App {
    @State private var showLaunchScreen = true
    @UIApplicationDelegateAdaptor(FirebaseDelegate.self) var firebaseDelegate
    
    // Check for light mode launch argument (used for UI tests/screenshots)
    private var shouldForceLightMode: Bool {
        let args = ProcessInfo.processInfo.arguments
        if let index = args.firstIndex(of: "-UIUserInterfaceStyle"), 
           index + 1 < args.count,
           args[index + 1] == "Light" {
            return true
        }
        return false
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreen()
                } else {
                    ContentView()
                }
            }
            .preferredColorScheme(shouldForceLightMode ? .light : nil)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}
