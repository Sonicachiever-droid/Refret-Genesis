//
//  Models.swift
//  ScaleListenerExpress
//
//  Created by Thomas Kane on 3/6/26.
//

import Foundation

// MARK: - Core Enums (from original project)

enum PitchClass: String, CaseIterable {
    case c, cSharp, d, dSharp, e, f, fSharp, g, gSharp, a, aSharp, b
    
    var displayName: String {
        rawValue.replacingOccurrences(of: "Sharp", with: "♯").capitalized
    }
}

enum ScaleType: String, CaseIterable {
    case major, minor, harmonicMinor, melodicMinor, dorian, phrygian, lydian, mixolydian, locrian,
         minorPentatonic, majorPentatonic, blues, majorBlues, chromatic
    
    var displayName: String {
        switch self {
        case .major:              "Major"
        case .minor:              "Minor"
        case .harmonicMinor:      "Harmonic Minor"
        case .melodicMinor:       "Melodic Minor"
        case .dorian:             "Dorian"
        case .phrygian:           "Phrygian"
        case .lydian:             "Lydian"
        case .mixolydian:         "Mixolydian"
        case .locrian:            "Locrian"
        case .minorPentatonic:    "Minor Pentatonic"
        case .majorPentatonic:    "Major Pentatonic"
        case .blues:              "Blues"
        case .majorBlues:         "Major Blues"
        case .chromatic:          "Chromatic"
        }
    }
    
    var semitoneOffsetsFromRoot: [Int] {
        switch self {
        case .major:              return [0,2,4,5,7,9,11,12]
        case .minor:              return [0,2,3,5,7,8,10,12]
        case .harmonicMinor:      return [0,2,3,5,7,8,11,12]
        case .melodicMinor:       return [0,2,3,5,7,9,11,12]
        case .dorian:             return [0,2,3,5,7,9,10,12]
        case .phrygian:           return [0,1,3,5,7,8,10,12]
        case .lydian:             return [0,2,4,6,7,9,11,12]
        case .mixolydian:         return [0,2,4,5,7,9,10,12]
        case .locrian:            return [0,1,3,5,6,8,10,12]
        case .minorPentatonic:    return [0,3,5,7,10]
        case .majorPentatonic:    return [0,2,4,7,9,11]
        case .blues:              return [0,3,5,6,7,10]
        case .majorBlues:         return [0,2,3,5,6,9,12,14]
        case .chromatic:          return [0,1,2,3,4,5,6,7,8,9,10,11]
        }
    }
}

// MARK: - Scale Data Structure

struct Scale {
    let root: PitchClass
    let spelling: AccidentalSpelling
    let type: ScaleType
    
    enum AccidentalSpelling {
        case sharps, flats
    }
}
