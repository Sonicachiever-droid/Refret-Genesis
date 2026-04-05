import SwiftUI

enum LayoutMode: String, CaseIterable, Identifiable {
    case beginner
    case maestro
    var id: String { rawValue }
}

final class AppState: ObservableObject {
    @Published var layoutMode: LayoutMode? = nil
}
