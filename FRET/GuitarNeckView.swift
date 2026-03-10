import SwiftUI

struct GuitarNeckView: View {
    let screenWidth: CGFloat
    let litCircleIndex: Int?
    let wrongPressCircle: Int?
    let showingNote: Bool
    let currentLitNote: String?
    let lastLitCircleIndex: Int?
    let gameManager: GameManager
    let gamePhase: Int
    let skinManager: SkinManager
    
    var body: some View {
        ZStack {
            // Fretboard background
            Rectangle()
                .fill(skinManager.colors.fretboard)
                .frame(width: screenWidth * 0.85, height: 200)
            
            // Strings
            ForEach(0..<6, id: \.self) { index in
                Rectangle()
                    .fill(skinManager.colors.string)
                    .frame(width: 2, height: 200)
                    .offset(x: (CGFloat(index) - 2.5) * (screenWidth * 0.15))
            }
            
            // Fret lines
            ForEach(0..<3, id: \.self) { index in
                Rectangle()
                    .fill(skinManager.colors.fret)
                    .frame(width: screenWidth * 0.85, height: 2)
                    .offset(y: CGFloat(index - 1) * 50)
            }
            
            // Translucent circles (on top of fretboard and strings)
            ForEach(0..<6, id: \.self) { index in
                Rectangle()
                    .fill(wrongPressCircle == index ? Color.red : litCircleIndex == index ? Color.green : Color.white)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Rectangle()
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .offset(x: (CGFloat(index) - 2.5) * (screenWidth * 0.15), y: gameManager.thermometerComplete ? -50 : -130)
                    .animation(.easeInOut(duration: 1.0), value: gameManager.thermometerComplete)
            }
        }
    }
}
