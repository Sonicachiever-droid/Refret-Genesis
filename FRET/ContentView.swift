import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @StateObject private var skinManager = SkinManager()
    @State private var showingSkinSelector = false
    
    var body: some View {
        ZStack {
            // Dynamic material background
            if skinManager.colors.hasTexture {
                DynamicBackgroundView(skinManager: skinManager)
                    .overlay(
                        GeometryReader { geometry in
                            HardwareDetailsView(skinManager: skinManager, size: geometry.size)
                        }
                    )
            } else {
                skinManager.colors.background
                    .ignoresSafeArea()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Thermometer in background with skin colors
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Red blocks stacked from bottom - full width
                        ForEach(0..<gameManager.displayCorrectAnswers, id: \.self) { index in
                            Rectangle()
                                .fill(skinManager.colors.thermometerBlock)
                                .frame(width: geometry.size.width, height: 25)
                        }
                        
                        // Red line at very bottom - full width (only when correct answers > 0)
                        if gameManager.displayCorrectAnswers > 0 {
                            Rectangle()
                                .fill(skinManager.colors.thermometerLine)
                                .frame(width: geometry.size.width, height: 2)
                        }
                    }
                    .allowsHitTesting(false)
                    
                    // Fret number next to "50" on the left - formula-based
                    if gameManager.gamePhase >= 2 {
                        ThemedTextView("\(max(1, gameManager.gamePhase - 1))", skinManager: skinManager)
                            .position(x: 10, y: 50)
                    }
                    
                    // Fret number next to "50" on the right - mirror
                    if gameManager.gamePhase >= 2 {
                        ThemedTextView("\(max(1, gameManager.gamePhase - 1))", skinManager: skinManager)
                            .position(x: geometry.size.width - 10, y: 50)
                    }
                                    
                    // Guitar neck positioned in middle area
                    GuitarNeckView(screenWidth: geometry.size.width, litCircleIndex: gameManager.litCircleIndex, wrongPressCircle: gameManager.wrongPressCircle, showingNote: gameManager.showingNote, currentLitNote: gameManager.currentLitNote, lastLitCircleIndex: gameManager.lastLitCircleIndex, gameManager: gameManager, gamePhase: gameManager.gamePhase, skinManager: skinManager)
                        .frame(height: 200)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4)
                    
                    // Thumb buttons anchored to bottom
                    ThumbButtonView(gameManager: gameManager, screenWidth: geometry.size.width, skinManager: skinManager)
                        .frame(height: 100)
                        .position(x: geometry.size.width / 2, y: geometry.size.height - 100)
                    
                    // Paintbrush icon button at bottom
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showingSkinSelector = true
                            }) {
                                Image(systemName: "paintbrush.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue.opacity(0.8))
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingSkinSelector) {
            SkinSelectorView(skinManager: skinManager, isPresented: $showingSkinSelector)
        }
    }
}

#Preview {
    ContentView()
}
