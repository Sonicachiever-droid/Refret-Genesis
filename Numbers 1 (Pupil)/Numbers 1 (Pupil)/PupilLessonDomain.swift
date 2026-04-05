import Foundation

enum PupilHubTab: Hashable {
    case home
    case play
    case instructions
    case settings
}

enum PupilGameStyle: String, CaseIterable, Identifiable {
    case random = "Random"
    case chord = "Chord"

    var id: String { rawValue }

    var title: String { rawValue }

    var shortDescription: String {
        switch self {
        case .random:
            return "Match note names to string locations on one fret."
        case .chord:
            return "Use one fret's notes as chord-building memory aids."
        }
    }
}

enum PupilDirection: String, CaseIterable, Identifiable {
    case ascending = "Ascending"
    case descending = "Descending"

    var id: String { rawValue }
}

enum PupilSoundMode: String, CaseIterable, Identifiable {
    case backingTrack = "Backing Track"
    case click = "Click"
    case silent = "Silent"

    var id: String { rawValue }
}

enum PupilLessonStage {
    case introReveal
    case activePlay
    case finish
}

struct PupilLessonSetup: Equatable {
    var gameStyle: PupilGameStyle = .random
    var startingFret: Int = 0
    var direction: PupilDirection = .ascending
    var repetitions: Int = 2
    var soundMode: PupilSoundMode = .silent
}

struct PupilSettings: Equatable {
    var restartOnMistake: Bool = true
    var gentleOpeningEnabled: Bool = true
    var allowFlexibleStartingFret: Bool = true
    var showReferenceNoteNames: Bool = false
    var showStringNumbers: Bool = true
    var showHomeAtStartup: Bool = true
}

struct PupilProgress: Equatable {
    var bankPoints: Int = 0
    var bestLessonPoints: Int = 0
    var completedLessons: Int = 0
    var lastLessonSummary: String = "No completed Pupil lesson yet."
}

struct PupilRandomChallenge {
    let displayedNotes: [String]
    var usedStrings: Set<Int> = []
    var targetIndex: Int = 0

    var currentTarget: String? {
        guard targetIndex < displayedNotes.count else { return nil }
        return displayedNotes[targetIndex]
    }

    var isComplete: Bool {
        targetIndex >= displayedNotes.count
    }
}

struct PupilChordTemplate {
    let suffix: String
    let intervals: [Int]
}

struct PupilChordChallenge {
    let symbol: String
    let toneNames: [String]
    let requiredStrings: Set<Int>
    var selectedStrings: Set<Int> = []

    var remainingStrings: Int {
        max(requiredStrings.count - selectedStrings.count, 0)
    }

    var isComplete: Bool {
        !requiredStrings.isEmpty && selectedStrings == requiredStrings
    }
}

struct PupilLessonSession {
    static let stringOrder: [Int] = [6, 5, 4, 3, 2, 1]
    static let pitchClassNames: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    static let openPitchByString: [Int: Int] = [6: 4, 5: 9, 4: 2, 3: 7, 2: 11, 1: 4]
    static let chordTemplates: [PupilChordTemplate] = [
        PupilChordTemplate(suffix: "", intervals: [0, 4, 7]),
        PupilChordTemplate(suffix: "m", intervals: [0, 3, 7]),
        PupilChordTemplate(suffix: "sus2", intervals: [0, 2, 7]),
        PupilChordTemplate(suffix: "sus4", intervals: [0, 5, 7]),
        PupilChordTemplate(suffix: "5", intervals: [0, 7])
    ]

    let setup: PupilLessonSetup
    var stage: PupilLessonStage
    var lessonFrets: [Int]
    var currentFretIndex: Int
    var currentRepetition: Int
    var lessonPoints: Int
    var mistakes: Int
    var protectedMistakesRemaining: Int
    var statusMessage: String
    var lastSubmissionWasCorrect: Bool?
    var randomChallenge: PupilRandomChallenge?
    var chordChallenge: PupilChordChallenge?

    init(setup: PupilLessonSetup, settings: PupilSettings) {
        self.setup = setup
        self.stage = .introReveal
        self.lessonFrets = Self.buildLessonFrets(startingFret: setup.startingFret, direction: setup.direction)
        self.currentFretIndex = 0
        self.currentRepetition = 1
        self.lessonPoints = 0
        self.mistakes = 0
        self.protectedMistakesRemaining = settings.gentleOpeningEnabled ? 2 : 0
        self.statusMessage = "Lesson prepared."
        self.lastSubmissionWasCorrect = nil
        self.randomChallenge = nil
        self.chordChallenge = nil
        prepareChallengeForCurrentPosition()
        statusMessage = introMessage
    }

    var currentFret: Int {
        lessonFrets[min(max(currentFretIndex, 0), lessonFrets.count - 1)]
    }

    var stageTitle: String {
        switch stage {
        case .introReveal:
            return "Intro Reveal"
        case .activePlay:
            return "Active Play"
        case .finish:
            return "Finish"
        }
    }

    var introMessage: String {
        switch setup.gameStyle {
        case .random:
            return "Fret \(currentFret) ready. Match the displayed notes without reusing the same string position twice in one pass."
        case .chord:
            return "Fret \(currentFret) ready. Build a chord from the notes available on this single fret."
        }
    }

    var progressTitle: String {
        "Fret \(currentFret) • Repetition \(currentRepetition) of \(setup.repetitions)"
    }

    var lessonPathText: String {
        lessonFrets.map(String.init).joined(separator: " • ")
    }

    var currentRandomNotes: [String] {
        randomChallenge?.displayedNotes ?? []
    }

    var currentRandomTarget: String? {
        randomChallenge?.currentTarget
    }

    var currentRandomTargetIndex: Int {
        randomChallenge?.targetIndex ?? 0
    }

    var currentChordSymbol: String {
        chordChallenge?.symbol ?? "Chord"
    }

    var currentChordTones: [String] {
        chordChallenge?.toneNames ?? []
    }

    var currentChordRemainingSelections: Int {
        chordChallenge?.remainingStrings ?? 0
    }

    var completionSummary: String {
        "\(setup.gameStyle.title) lesson complete. \(lessonPoints) Bank earned."
    }

    mutating func startActivePlay() {
        guard stage == .introReveal else { return }
        stage = .activePlay
        statusMessage = setup.gameStyle == .random
            ? "Find \(currentRandomTarget ?? "the next note")."
            : "Find the strings that belong to \(currentChordSymbol)."
        lastSubmissionWasCorrect = nil
    }

    mutating func submit(stringNumber: Int, settings: PupilSettings) {
        guard stage == .activePlay else { return }
        switch setup.gameStyle {
        case .random:
            handleRandomTap(stringNumber: stringNumber, settings: settings)
        case .chord:
            handleChordTap(stringNumber: stringNumber, settings: settings)
        }
    }

    mutating func prepareChallengeForCurrentPosition() {
        switch setup.gameStyle {
        case .random:
            randomChallenge = Self.makeRandomChallenge(fret: currentFret)
            chordChallenge = nil
        case .chord:
            chordChallenge = Self.makeChordChallenge(fret: currentFret)
            randomChallenge = nil
        }
    }

    private mutating func handleRandomTap(stringNumber: Int, settings: PupilSettings) {
        guard var challenge = randomChallenge,
              let target = challenge.currentTarget else { return }

        let tappedNote = Self.noteName(forString: stringNumber, fret: currentFret)
        let isCorrect = tappedNote == target && !challenge.usedStrings.contains(stringNumber)

        if isCorrect {
            challenge.usedStrings.insert(stringNumber)
            challenge.targetIndex += 1
            randomChallenge = challenge
            lessonPoints += 8
            lastSubmissionWasCorrect = true
            statusMessage = challenge.isComplete
                ? "Sequence cleared on fret \(currentFret)."
                : "Correct. Next target: \(challenge.currentTarget ?? target)."
            if challenge.isComplete {
                completeCurrentChallenge()
            }
            return
        }

        applyMistake(settings: settings)
    }

    private mutating func handleChordTap(stringNumber: Int, settings: PupilSettings) {
        guard var challenge = chordChallenge else { return }
        let isCorrect = challenge.requiredStrings.contains(stringNumber) && !challenge.selectedStrings.contains(stringNumber)

        if isCorrect {
            challenge.selectedStrings.insert(stringNumber)
            chordChallenge = challenge
            lessonPoints += 12
            lastSubmissionWasCorrect = true
            statusMessage = challenge.isComplete
                ? "Chord shape cleared on fret \(currentFret)."
                : "Correct. \(challenge.remainingStrings) more string\(challenge.remainingStrings == 1 ? "" : "s") to find."
            if challenge.isComplete {
                completeCurrentChallenge()
            }
            return
        }

        applyMistake(settings: settings)
    }

    private mutating func completeCurrentChallenge() {
        lessonPoints += 24
        lastSubmissionWasCorrect = true

        if currentRepetition < setup.repetitions {
            currentRepetition += 1
            prepareChallengeForCurrentPosition()
            statusMessage = setup.gameStyle == .random
                ? "Repetition \(currentRepetition) ready. Target: \(currentRandomTarget ?? "Start")."
                : "Repetition \(currentRepetition) ready. Build \(currentChordSymbol)."
            return
        }

        lessonPoints += 50

        if currentFretIndex < lessonFrets.count - 1 {
            currentFretIndex += 1
            currentRepetition = 1
            stage = .introReveal
            prepareChallengeForCurrentPosition()
            statusMessage = introMessage
            return
        }

        lessonPoints += 100
        stage = .finish
        statusMessage = completionSummary
    }

    private mutating func applyMistake(settings: PupilSettings) {
        mistakes += 1
        lastSubmissionWasCorrect = false
        lessonPoints = max(lessonPoints - (settings.restartOnMistake ? 18 : 10), 0)

        if protectedMistakesRemaining > 0 {
            protectedMistakesRemaining -= 1
            resetCurrentChallengeKeepingProgress()
            statusMessage = "Protected mistake used. Try the challenge again."
            return
        }

        if settings.restartOnMistake {
            restartLessonProgress()
            statusMessage = "Mistake reset the lesson to the first fret."
        } else {
            resetCurrentChallengeKeepingProgress()
            statusMessage = "Mistake repeated the current challenge."
        }
    }

    private mutating func restartLessonProgress() {
        currentFretIndex = 0
        currentRepetition = 1
        lessonPoints = 0
        stage = .introReveal
        prepareChallengeForCurrentPosition()
    }

    private mutating func resetCurrentChallengeKeepingProgress() {
        prepareChallengeForCurrentPosition()
    }

    static func buildLessonFrets(startingFret: Int, direction: PupilDirection) -> [Int] {
        let clampedStart = min(max(startingFret, 0), 12)
        let strideValues: [Int]
        switch direction {
        case .ascending:
            strideValues = Array(clampedStart...12)
        case .descending:
            strideValues = Array((0...clampedStart).reversed())
        }
        let sliced = Array(strideValues.prefix(4))
        return sliced.isEmpty ? [clampedStart] : sliced
    }

    static func noteName(forString stringNumber: Int, fret: Int) -> String {
        pitchClassNames[pitchClass(forString: stringNumber, fret: fret)]
    }

    static func pitchClass(forString stringNumber: Int, fret: Int) -> Int {
        let openPitch = openPitchByString[stringNumber] ?? 0
        return (openPitch + max(fret, 0)) % 12
    }

    static func noteMap(forFret fret: Int) -> [Int: String] {
        Dictionary(uniqueKeysWithValues: stringOrder.map { stringNumber in
            (stringNumber, noteName(forString: stringNumber, fret: fret))
        })
    }

    static func makeRandomChallenge(fret: Int) -> PupilRandomChallenge {
        let notes = stringOrder.map { noteName(forString: $0, fret: fret) }.shuffled()
        return PupilRandomChallenge(displayedNotes: notes)
    }

    static func makeChordChallenge(fret: Int) -> PupilChordChallenge {
        let pitchByString = Dictionary(uniqueKeysWithValues: stringOrder.map { stringNumber in
            (stringNumber, pitchClass(forString: stringNumber, fret: fret))
        })
        let availablePitchClasses = Set(pitchByString.values)
        var candidates: [PupilChordChallenge] = []

        for rootPitch in 0..<12 {
            for template in chordTemplates {
                let chordPitchClasses = Set(template.intervals.map { (rootPitch + $0) % 12 })
                guard chordPitchClasses.isSubset(of: availablePitchClasses) else { continue }
                let matchingStrings = Set(pitchByString.compactMap { stringNumber, pitchClass in
                    chordPitchClasses.contains(pitchClass) ? stringNumber : nil
                })
                guard matchingStrings.count >= 3 else { continue }
                let toneNames = template.intervals.map { interval in
                    pitchClassNames[(rootPitch + interval) % 12]
                }
                let symbol = pitchClassNames[rootPitch] + template.suffix
                candidates.append(
                    PupilChordChallenge(
                        symbol: symbol,
                        toneNames: toneNames,
                        requiredStrings: matchingStrings
                    )
                )
            }
        }

        if let best = candidates.sorted(by: { lhs, rhs in
            if lhs.requiredStrings.count == rhs.requiredStrings.count {
                return lhs.symbol < rhs.symbol
            }
            return lhs.requiredStrings.count > rhs.requiredStrings.count
        }).first {
            return best
        }

        let noteByString = noteMap(forFret: fret)
        var orderedUniqueNotes: [String] = []
        for stringNumber in stringOrder {
            let note = noteByString[stringNumber] ?? "C"
            if !orderedUniqueNotes.contains(note) {
                orderedUniqueNotes.append(note)
            }
        }
        let toneNames = Array(orderedUniqueNotes.prefix(3))
        let requiredStrings = Set(stringOrder.filter { stringNumber in
            toneNames.contains(noteByString[stringNumber] ?? "")
        })

        return PupilChordChallenge(
            symbol: toneNames.isEmpty ? "Cluster" : toneNames.joined(separator: "-"),
            toneNames: toneNames,
            requiredStrings: requiredStrings
        )
    }
}
