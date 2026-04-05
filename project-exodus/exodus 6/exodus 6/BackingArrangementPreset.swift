import Foundation

enum BackingArrangementPreset: String, CaseIterable, Identifiable {
    case epDrumsPad = "EP + Drums + Pad"
    case keysDrumsStrings = "Keys + Drums + Strings"
    case epDrumsOnly = "EP + Drums Only"
    case padDrumsOnly = "Pad + Drums Only"

    var id: String { rawValue }
}
