import SwiftUI

struct ModeSelectionView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Text("Exodus 2")
                .font(.largeTitle).bold()
            Text("Choose your console")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(spacing: 16) {
                Button {
                    appState.layoutMode = .beginner
                } label: {
                    Text("Beginner Console")
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    appState.layoutMode = .maestro
                } label: {
                    Text("Maestro Console")
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
