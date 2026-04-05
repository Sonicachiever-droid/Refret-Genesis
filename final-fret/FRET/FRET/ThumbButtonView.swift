import SwiftUI

struct ThumbButtonView: View {
    let gameManager: GameManager
    let screenWidth: CGFloat
    let skinManager: SkinManager
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<6, id: \.self) { index in
                ThumbButton(stringIndex: index, gameManager: gameManager, skinManager: skinManager)
            }
        }
        .padding(.horizontal, 60)
    }
}

struct ThumbButton: View {
    let stringIndex: Int
    @ObservedObject var gameManager: GameManager
    let skinManager: SkinManager
    
    var displayNote: String {
        let targetFret = gameManager.thermometerComplete ? 1 : (gameManager.gamePhase >= 2 ? gameManager.gamePhase : 0)
        return gameManager.getNotesForFret(targetFret)[stringIndex]
    }
    
    var body: some View {
        Button(action: {
            gameManager.handleButtonPress(stringIndex: stringIndex)
        }) {
            ZStack {
                Circle()
                    .fill(skinManager.colors.buttonFill)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(skinManager.colors.buttonBorder, lineWidth: 2)
                    )
                
                Text(displayNote)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(skinManager.colors.textColor)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
