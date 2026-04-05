import SwiftUI

@main
struct Exodus2App: App {
    @StateObject private var appState = AppState()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
