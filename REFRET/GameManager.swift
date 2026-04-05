import Foundation
import SwiftUI
import Combine

class GameManager: ObservableObject {
    @Published var litCircleIndex: Int? = nil
    @Published var wrongPressCircle: Int? = nil
    @Published var showingNote: Bool = false
    @Published var currentLitNote: String? = nil
    @Published var lastLitCircleIndex: Int? = nil
    @Published var shownNotes: [(index: Int, note: String)] = []
    @Published var correctAnswers: Int = 0
    @Published var displayCorrectAnswers: Int = 0
    @Published var thermometerComplete: Bool = false
    @Published var gamePhase: Int = 0
    @Published var isTransitioning: Bool = false
    
    private let maxCorrectAnswers = 2
    var requiredCorrectAnswers: Int { maxCorrectAnswers }
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        showingNote = false
        wrongPressCircle = nil
        lastLitCircleIndex = nil
        shownNotes = []
        correctAnswers = 0
        displayCorrectAnswers = 0
        gamePhase = 0
        lightRandomCircle()
    }
    
    func getNotesForFret(_ fretNumber: Int) -> [String] {
        switch fretNumber {
        case 0: return ["E", "A", "D", "G", "B", "E"]
        case 1: return ["F", "A#", "D#", "G#", "C", "F"]
        case 2: return ["F#", "B", "E", "A", "C#", "F#"]
        case 3: return ["G", "C", "F", "A#", "D", "G"]
        case 4: return ["G#", "C#", "F#", "B", "D#", "G#"]
        case 5: return ["A", "D", "G", "C", "E", "A"]
        case 6: return ["A#", "D#", "G#", "C#", "F", "A#"]
        case 7: return ["B", "E", "A", "D", "F#", "B"]
        case 8: return ["C", "F", "A#", "D#", "G", "C"]
        case 9: return ["C#", "F#", "B", "E", "G#", "C#"]
        case 10: return ["D", "G", "C", "F", "A", "D"]
        case 11: return ["D#", "G#", "C#", "F#", "A#", "D#"]
        case 12: return ["E", "A", "D", "G", "B", "E"]
        default: return ["E", "A", "D", "G", "B", "E"]
        }
    }
    
    func lightRandomCircle() {
        var validIndices = Array(0..<6)
        if let last = lastLitCircleIndex {
            validIndices.removeAll(where: { $0 == last })
        }
        guard let randomIndex = validIndices.randomElement() else { return }
        litCircleIndex = randomIndex
        let targetFret = gamePhase >= 2 ? gamePhase : (thermometerComplete ? 1 : 0)
        currentLitNote = getNotesForFret(targetFret)[randomIndex]
        wrongPressCircle = nil
        showingNote = false
    }
    
    func handleButtonPress(stringIndex: Int) {
        guard let currentLitNote = currentLitNote, let litIndex = litCircleIndex else { return }
        
        if stringIndex == litIndex {
            lastLitCircleIndex = litIndex
            litCircleIndex = nil
            showingNote = true
            shownNotes.append((index: litIndex, note: currentLitNote))
            correctAnswers += 1
            displayCorrectAnswers += 1
            
            if correctAnswers >= maxCorrectAnswers {
                thermometerComplete = true
                isTransitioning = true
                if gamePhase < 12 {
                    gamePhase += 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.displayCorrectAnswers = 0
                    self.correctAnswers = 0
                    self.thermometerComplete = false
                    self.showingNote = false
                    self.shownNotes = []
                    self.isTransitioning = false
                    self.lightRandomCircle()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showingNote = false
                    self.shownNotes = []
                    self.lightRandomCircle()
                }
            }
        } else {
            wrongPressCircle = litIndex
            correctAnswers = 0
            let currentDisplay = displayCorrectAnswers
            for i in (0..<currentDisplay).reversed() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(currentDisplay - 1 - i) * 0.05) {
                    self.displayCorrectAnswers = i
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.wrongPressCircle = nil
            }
        }
    }
}
