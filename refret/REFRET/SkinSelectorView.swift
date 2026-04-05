import SwiftUI

struct SkinSelectorView: View {
    @Binding var showSelector: Bool
    @EnvironmentObject var skinManager: SkinManager
    private let columns = [GridItem(.adaptive(minimum: 90))]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Skins")
                    .font(.headline)
                Spacer()
                Button("Close") {
                    withAnimation { showSelector = false }
                }
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(SkinManager.SkinTheme.allCases) { theme in
                    Button(action: {
                        withAnimation {
                            skinManager.currentSkin = theme
                            showSelector = false
                        }
                    }) {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(preview(for: theme).background)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(preview(for: theme).border, lineWidth: 3)
                                )
                                .overlay(
                                    Circle()
                                        .fill(preview(for: theme).button)
                                        .frame(width: 28, height: 28)
                                )
                            Text(theme.rawValue)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(skinManager.currentSkin == theme ? Color.white : Color.white.opacity(0.3), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.25))
                                )
                        )
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(radius: 20)
    }
    
    private func preview(for theme: SkinManager.SkinTheme) -> (background: Color, button: Color, border: Color) {
        switch theme {
        case .blank: return (.black, .white.opacity(0.3), .white.opacity(0.6))
        case .empty: return (.black, .clear, .white.opacity(0.2))
        case .default: return (.black, .orange, .white)
        case .futuristic: return (Color(red: 0.02, green: 0.02, blue: 0.08), .cyan.opacity(0.5), .cyan)
        case .retro50s: return (Color(red: 0.94, green: 0.95, blue: 0.9), Color(red: 1.0, green: 0.65, blue: 0.75), .gray)
        case .western: return (Color(red: 0.32, green: 0.18, blue: 0.08), Color(red: 0.6, green: 0.3, blue: 0.15), Color(red: 0.82, green: 0.71, blue: 0.55))
        case .artNouveau: return (Color(red: 0.99, green: 0.97, blue: 0.92), Color(red: 0.53, green: 0.66, blue: 0.42), Color(red: 0.8, green: 0.7, blue: 0.3))
        case .zen: return (Color(red: 0.95, green: 0.95, blue: 0.92), Color(red: 0.56, green: 0.74, blue: 0.56), Color(red: 0.18, green: 0.31, blue: 0.31))
        case .artDeco: return (Color(red: 0.05, green: 0.05, blue: 0.2), Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 0.4, green: 0.4, blue: 0.4))
        case .steampunk: return (Color(red: 0.2, green: 0.12, blue: 0.08), Color(red: 0.72, green: 0.45, blue: 0.2), Color(red: 0.82, green: 0.71, blue: 0.55))
        case .bauhaus: return (.white, .red, .black)
        case .tropical: return (Color(red: 0.92, green: 0.84, blue: 0.7), Color(red: 1.0, green: 0.41, blue: 0.71), Color(red: 0.13, green: 0.55, blue: 0.13))
        case .gothic: return (Color(red: 0.16, green: 0.16, blue: 0.18), Color(red: 0.1, green: 0.1, blue: 0.3), Color(red: 1.0, green: 0.84, blue: 0.0))
        }
    }
}
