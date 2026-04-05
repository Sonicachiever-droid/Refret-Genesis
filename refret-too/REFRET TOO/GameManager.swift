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

    private let stringNotes = ["E", "A", "D", "G", "B", "E"]
    private let maxCorrectAnswers = 20

    var currentFret: Int {
        if thermometerComplete {
            return max(1, gamePhase)
        }
        return 0
    }

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
        thermometerComplete = false
        gamePhase = 0
        isTransitioning = false
        litCircleIndex = nil
        nextRound()
    }

    func handleButtonPress(stringIndex: Int) {
        guard !isTransitioning else { return }

        if let litCircleIndex = litCircleIndex {
            if stringIndex == litCircleIndex {
                correctAnswers += 1
                displayCorrectAnswers = min(correctAnswers, maxCorrectAnswers)
                showingNote = true
                currentLitNote = getNotesForFret(currentFret)[stringIndex]

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showingNote = false
                    self.currentLitNote = nil
                    self.lastLitCircleIndex = self.litCircleIndex
                    self.litCircleIndex = nil

                    if self.correctAnswers >= self.maxCorrectAnswers {
                        self.thermometerComplete = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.nextRound()
                    }
                }
            } else {
                wrongPressCircle = stringIndex
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.wrongPressCircle = nil
                }
            }
        }
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
        default: return stringNotes
        }
    }

    func nextRound() {
        if thermometerComplete && gamePhase < 12 {
            gamePhase += 1
        }

        litCircleIndex = (0..<stringNotes.count).randomElement()
    }
}
