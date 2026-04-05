//
//  ContentView.swift
//  REFRET
//
//  Created by Thomas Kane on 3/10/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var gameManager: GameManager
    @EnvironmentObject var skinManager: SkinManager
    @State private var showSkinSelector = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MaterialShaderView(skinManager: skinManager)
                    .ignoresSafeArea()
                
                HardwareDetailsView(skinManager: skinManager, size: geometry.size)
                    .allowsHitTesting(false)
                
                if !skinManager.currentSkin.hidesInterface {
                    VStack(spacing: 24) {
                        headerSection
                            .padding(.top, 32)
                            .padding(.horizontal, 32)
                        
                        GuitarNeckView(
                            screenWidth: geometry.size.width * 0.9,
                            litCircleIndex: gameManager.litCircleIndex,
                            wrongPressCircle: gameManager.wrongPressCircle,
                            showingNote: gameManager.showingNote,
                            currentLitNote: gameManager.currentLitNote,
                            lastLitCircleIndex: gameManager.lastLitCircleIndex,
                            gameManager: gameManager,
                            gamePhase: gameManager.gamePhase
                        )
                        .padding(.horizontal)
                        
                        ThumbButtonView(
                            gameManager: gameManager,
                            screenWidth: geometry.size.width,
                            skinManager: skinManager
                        )
                        .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if showSkinSelector {
                    SkinSelectorView(showSelector: $showSkinSelector)
                        .environmentObject(skinManager)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSkinSelector)
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("FRET")
                    .font(.custom(skinManager.colors.fontName, size: 24))
                    .tracking(skinManager.colors.letterSpacing)
                    .fontWeight(skinManager.colors.fontWeight)
                    .foregroundColor(skinManager.colors.textColor)
                
                Text("Phase \(gameManager.gamePhase + 1)")
                    .foregroundColor(skinManager.colors.accent)
                    .font(.caption)
            }
            
            Spacer()
            
            ThermometerView(
                progress: CGFloat(gameManager.displayCorrectAnswers) / CGFloat(max(gameManager.requiredCorrectAnswers, 1)),
                color: skinManager.colors.thermometerBlock,
                lineColor: skinManager.colors.thermometerLine
            )
            .frame(width: 40, height: 120)
            
            Spacer()
            
            Button(action: { withAnimation { showSkinSelector.toggle() } }) {
                Label("Skins", systemImage: "paintpalette")
                    .font(.headline)
                    .foregroundColor(skinManager.colors.textColor)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(skinManager.colors.accent, lineWidth: 1.5)
                    )
            }
        }
    }
}

struct ThermometerView: View {
    let progress: CGFloat
    let color: Color
    let lineColor: Color
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineColor, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.2))
                )
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(height: 120 * progress)
        }
    }
}

struct GuitarNeckView: View {
    let screenWidth: CGFloat
    let litCircleIndex: Int?
    let wrongPressCircle: Int?
    let showingNote: Bool
    let currentLitNote: String?
    let lastLitCircleIndex: Int?
    let gameManager: GameManager
    let gamePhase: Int
    
    var stringNotes: [String] {
        let targetFret = gamePhase >= 2 ? gamePhase : (gameManager.thermometerComplete ? 1 : 0)
        return gameManager.getNotesForFret(targetFret)
    }
    
    var body: some View {
        let boardWidth = screenWidth * 0.9
        let boardHeight: CGFloat = 240
        
        return ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.2))
                .frame(width: boardWidth, height: boardHeight)
            
            VStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    HStack {
                        WoundStringView(level: index)
                            .frame(height: index < 2 ? 4 : 2)
                        Spacer()
                        noteIndicator(for: index)
                    }
                }
            }
            .padding(.horizontal, 32)
            .frame(width: boardWidth, height: boardHeight)
        }
        .rotationEffect(.degrees(-90))
        .frame(width: boardHeight, height: boardWidth)
    }
    
    private func noteIndicator(for index: Int) -> some View {
        let isLit = litCircleIndex == index
        let isWrong = wrongPressCircle == index
        let baseColor: Color = isWrong ? Color.red : (isLit ? Color.green : Color.white.opacity(0.25))
        
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(baseColor)
                .frame(width: 46, height: 46)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.2))
                )
            
            if showingNote, let shown = gameManager.shownNotes.first(where: { $0.index == index }) {
                Text(shown.note)
                    .font(.title2)
                    .foregroundColor(.black)
                    .rotationEffect(.degrees(90))
            }
        }
    }
}

struct ThumbButtonView: View {
    @ObservedObject var gameManager: GameManager
    let screenWidth: CGFloat
    let skinManager: SkinManager
    
    var body: some View {
        HStack(spacing: 60) {
            VStack(spacing: 20) {
                labeledThumb(index: 2, label: "D")
                labeledThumb(index: 1, label: "A")
                labeledThumb(index: 0, label: "E")
            }
            VStack(spacing: 20) {
                labeledThumb(index: 3, label: "G")
                labeledThumb(index: 4, label: "B")
                labeledThumb(index: 5, label: "E")
            }
        }
    }
    
    private func labeledThumb(index: Int, label: String) -> some View {
        ThumbButton(stringIndex: index, gameManager: gameManager, skinManager: skinManager, label: label)
    }
}

struct ThumbButton: View {
    let stringIndex: Int
    @ObservedObject var gameManager: GameManager
    let skinManager: SkinManager
    let label: String
    
    var displayNote: String {
        let targetFret = gameManager.gamePhase >= 2 ? gameManager.gamePhase : (gameManager.thermometerComplete ? 1 : 0)
        return gameManager.getNotesForFret(targetFret)[stringIndex]
    }
    
    var body: some View {
        Button {
            gameManager.handleButtonPress(stringIndex: stringIndex)
        } label: {
            ZStack {
                Circle()
                    .fill(skinManager.colors.buttonFill)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(skinManager.colors.buttonBorder, lineWidth: 2)
                    )
                
                Text(displayNote)
                    .font(.custom(skinManager.colors.fontName, size: 24))
                    .foregroundColor(skinManager.colors.textColor)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WoundStringView: View {
    let level: Int
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0.8), .gray.opacity(0.6)]), startPoint: .leading, endPoint: .trailing)
            )
            .frame(height: CGFloat(max(1, 4 - level/2)))
            .overlay(
                Rectangle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
            )
    }
}

