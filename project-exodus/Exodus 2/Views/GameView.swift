import SwiftUI

struct GameView: View {
    let mode: LayoutMode

    private var showMaestroOverlays: Bool { mode == .maestro }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TopBarView()
                FretboardView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(white: 0.12))
            }

            HStack {
                ThumbButtonView(title: "Thumb L")
                Spacer()
                ThumbButtonView(title: "Thumb R")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .opacity(showMaestroOverlays ? 1 : 0)
            .allowsHitTesting(showMaestroOverlays)
            .accessibilityHidden(!showMaestroOverlays)
        }
        .overlay(alignment: .center) {
            VStack(spacing: 16) {
                NoteScreensOverlay()
                StringScreensOverlay()
            }
            .padding()
            .opacity(showMaestroOverlays ? 1 : 0)
            .allowsHitTesting(showMaestroOverlays)
            .accessibilityHidden(!showMaestroOverlays)
        }
    }
}

struct TopBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    Text("TV Panel")
                        .foregroundColor(.white)
                        .font(.headline)
                )
                .frame(height: 56)

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 4) {
                Text("Score: 0000")
                    .font(.subheadline).bold()
                Text("Wallet: $000")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

struct FretboardView: View {
    let stringCount = 6
    let fretCount = 12

    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height

            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.brown.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(white: 0.15), lineWidth: 2)
                    )

                Rectangle()
                    .fill(Color(white: 0.9))
                    .frame(height: 8)
                    .offset(y: -height/2 + 8)

                ForEach(1...fretCount, id: \.self) { i in
                    Rectangle()
                        .fill(Color(white: 0.8))
                        .frame(height: 2)
                        .offset(y: -height/2 + 8 + (height - 16) * CGFloat(i) / CGFloat(fretCount + 1))
                }

                ForEach(0..<stringCount, id: \.self) { i in
                    let y = (-height/2) + (height * (CGFloat(i) + 0.5) / CGFloat(stringCount))
                    Rectangle()
                        .fill(Color.yellow.opacity(0.9))
                        .frame(height: i == 0 ? 2.5 : 1.5)
                        .offset(y: y)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
    }
}

struct NoteScreensOverlay: View {
    var body: some View {
        HStack(spacing: 10) {
            NoteBox("E")
            NoteBox("G")
            NoteBox("B")
        }
    }

    @ViewBuilder
    func NoteBox(_ note: String) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
            .overlay(
                Text(note)
                    .font(.title2).bold()
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            )
            .frame(height: 44)
    }
}

struct StringScreensOverlay: View {
    var body: some View {
        HStack(spacing: 8) {
            TagBox("open")
            TagBox("string 1")
            TagBox("string 2")
            TagBox("string 3")
            TagBox("string 4")
            TagBox("string 5")
            TagBox("string 6")
        }
        .fixedSize()
    }

    @ViewBuilder
    func TagBox(_ text: String) -> some View {
        Capsule()
            .fill(Color.white)
            .overlay(
                Text(text)
                    .font(.caption).bold()
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            )
            .shadow(radius: 1)
    }
}

struct ThumbButtonView: View {
    var title: String

    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(.headline).bold()
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.blue)
                        .shadow(radius: 3)
                )
        }
    }
}
