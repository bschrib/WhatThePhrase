import SwiftUI

@main
struct WhatThePhraseApp: App {
    @State private var showLaunchScreen = true
    @UIApplicationDelegateAdaptor(FirebaseDelegate.self) var firebaseDelegate

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreen()
                } else {
                    ContentView()
                }
            }
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
