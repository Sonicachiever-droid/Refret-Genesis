import Foundation

enum Numbers3HubTab: Hashable {
    case home
    case play
    case instructions
    case settings
}

enum GameMode: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case maestro = "Maestro"

    var id: String { rawValue }

    var title: String { rawValue }
}

enum LessonDirection: String, CaseIterable, Identifiable {
    case ascending = "Ascending"
    case descending = "Descending"

    var id: String { rawValue }
}

enum SoundMode: String, CaseIterable, Identifiable {
    case backingTrack = "Backing Track"
    case click = "Click"
    case silent = "Silent"

    var id: String { rawValue }
}

struct LessonSetup: Equatable {
    var startingFret: Int = 0
    var direction: LessonDirection = .ascending
    var repetitions: Int = 2
    var soundMode: SoundMode = .silent
}

struct LessonSettings: Equatable {
    var restartOnMistake: Bool = true
    var gentleOpeningEnabled: Bool = true
    var allowFlexibleStartingFret: Bool = true
    var showReferenceNoteNames: Bool = false
    var showStringNumbers: Bool = true
}

struct LessonProgress: Equatable {
    var walletPoints: Int = 0
    var bestLessonPoints: Int = 0
    var completedLessons: Int = 0
    var lastLessonSummary: String = "No completed lesson yet."
}
