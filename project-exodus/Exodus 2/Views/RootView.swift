import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        Group {
            if let mode = appState.layoutMode {
                GameView(mode: mode)
            } else {
                ModeSelectionView()
            }
        }
    }
}
