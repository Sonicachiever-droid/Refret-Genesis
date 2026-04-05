//
//  ScaleListenerApp.swift
//  ScaleListener
//
//  Created by Thomas Kane on 3/4/26.
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Direction Enum
enum ScaleDirection {
    case ascending, descending
}

// MARK: - Enums & Constants

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
        case .major: return [0,2,4,5,7,9,11,12]
        case .minor: return [0,2,3,5,7,8,10,12]
        case .harmonicMinor: return [0,2,3,5,7,8,11,12]
        case .melodicMinor: return [0,2,3,5,7,9,11,12]
        case .dorian: return [0,2,3,5,7,9,10,12]
        case .phrygian: return [0,1,3,5,7,8,10,12]
        case .lydian: return [0,2,4,6,7,9,11,12]
        case .mixolydian: return [0,2,4,5,7,9,10,12]
        case .locrian: return [0,1,3,5,6,8,10,12]
        case .minorPentatonic: return [0,3,5,7,10,12]
        case .majorPentatonic: return [0,2,4,7,9,12]
        case .blues: return [0,3,5,6,7,10,12]
        case .majorBlues: return [0,2,3,4,7,9,12]
        case .chromatic: return Array(0...12)
        }
    }
}

private let noteNames: [String] = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
private let chromaticSyllables: [String] = ["do", "di", "re", "ri", "mi", "fa", "fi", "sol", "si", "la", "li", "ti", "do"]
private let descendingChromaticSolfege: [String] = ["do", "ti", "te", "le", "sol", "fa", "mi", "re", "ra", "do"]

private let scaleSolfege: [ScaleType: [String]] = [
    .major: ["do", "re", "mi", "fa", "sol", "la", "ti", "do"],
    .minor: ["do", "re", "me", "fa", "sol", "le", "te", "do"],
    .harmonicMinor: ["do", "re", "me", "fa", "sol", "le", "ti", "do"],
    .melodicMinor: ["do", "re", "me", "fa", "sol", "la", "ti", "do"],
    .dorian: ["do", "re", "me", "fa", "sol", "la", "te", "do"],
    .phrygian: ["do", "ra", "me", "fa", "sol", "le", "te", "do"],
    .lydian: ["do", "re", "mi", "fi", "sol", "la", "ti", "do"],
    .mixolydian: ["do", "re", "mi", "fa", "sol", "la", "te", "do"],
    .locrian: ["do", "ra", "me", "fa", "se", "le", "te", "do"],
    .minorPentatonic: ["do", "me", "fa", "sol", "te", "do"],
    .majorPentatonic: ["do", "re", "mi", "sol", "la", "do"],
    .blues: ["do", "me", "fa", "fi", "sol", "te", "do"],
    .majorBlues: ["do", "re", "me", "mi", "fa", "sol", "la", "do"],
    .chromatic: ["do", "di", "re", "ri", "mi", "fa", "fi", "sol", "si", "la", "li", "ti", "do"]
]

private let intervalNames: [Int: String] = [
    0: "P1", 1: "m2", 2: "M2", 3: "m3", 4: "M3", 5: "P4",
    6: "d5", 7: "P5", 8: "m6", 9: "M6", 10: "m7", 11: "M7", 12: "P8"
]

private func scaleDegreeLabels(for scaleType: ScaleType, direction: ScaleDirection) -> [String] {
    switch scaleType {
    case .major: return ["1","2","3","4","5","6","7","8"]
    case .minor: return ["1","2","♭3","4","5","♭6","♭7","8"]
    case .harmonicMinor: return ["1","2","♭3","4","5","♭6","7","8"]
    case .melodicMinor: return direction == .ascending ? ["1","2","♭3","4","5","6","7","8"] : ["1","2","♭3","4","5","♭6","♭7","8"]
    case .dorian: return ["1","2","♭3","4","5","6","♭7","8"]
    case .phrygian: return ["1","♭2","♭3","4","5","♭6","♭7","8"]
    case .lydian: return ["1","2","3","♯4","5","6","7","8"]
    case .mixolydian: return ["1","2","3","4","5","6","♭7","8"]
    case .locrian: return ["1","♭2","♭3","4","♭5","♭6","♭7","8"]
    case .minorPentatonic: return ["1","♭3","4","5","♭7","8"]
    case .majorPentatonic: return ["1","2","3","5","6","8"]
    case .blues: return ["1","♭3","4","♭5","5","♭7","8"]
    case .majorBlues: return ["1","2","♭3","3","5","6","8"]
    case .chromatic: return ["1","♭2","2","♭3","3","4","♭5","5","♭6","6","♭7","7","8"]
    }
}

private func noteIndex(for pitch: PitchClass) -> Int {
    switch pitch {
    case .c: return 0; case .cSharp: return 1; case .d: return 2; case .dSharp: return 3
    case .e: return 4; case .f: return 5; case .fSharp: return 6; case .g: return 7
    case .gSharp: return 8; case .a: return 9; case .aSharp: return 10; case .b: return 11
    }
}

struct Scale {
    let root: PitchClass
    let spelling: AccidentalSpelling
    let type: ScaleType
}

enum AccidentalSpelling { case sharps, flats }

// MARK: - Audio Controller

class AudioController: ObservableObject {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let dronePlayer = AVAudioPlayerNode()
    
    private var noteBuffers: [AVAudioPCMBuffer] = []
    private var degreeSequence: [Int] = []
    private var singleCycleLength = 0
    private var isDescending = false
    private var isInfiniteRepeat = false
    
    @Published var isPlaying = false
    @Published var currentDegreeIndex = 1
    @Published var currentRoot: PitchClass = .c
    @Published var currentScaleType: ScaleType = .major
    @Published var currentDirection: ScaleDirection = .ascending
    @Published var bpm: Double = 80
    @Published var droneEnabled = false
    
    init() {
        engine.attach(player)
        engine.attach(dronePlayer)
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.connect(dronePlayer, to: engine.mainMixerNode, format: format)
        do { try engine.start() } catch { print("Engine failed: \(error)") }
    }
    
    func playSingleScale(root: PitchClass, scaleType: ScaleType, repeats: Int? = 1) {
        stop()
        
        let scale = Scale(root: root, spelling: .sharps, type: scaleType)
        let (freqs, degrees) = buildScaleSequence(for: scale)
        singleCycleLength = degrees.count
        
        let noteDuration = 60.0 / bpm * 0.5
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        
        if let repeats = repeats, repeats > 0 {
            var repeatedFreqs: [Double] = []
            var repeatedDegrees: [Int] = []
            for _ in 0..<repeats {
                repeatedFreqs += freqs
                repeatedDegrees += degrees
            }
            noteBuffers = repeatedFreqs.compactMap { createSineBuffer(frequency: $0, duration: noteDuration, format: format) }
            degreeSequence = repeatedDegrees
            isInfiniteRepeat = false
        } else {
            noteBuffers = freqs.compactMap { createSineBuffer(frequency: $0, duration: noteDuration, format: format) }
            degreeSequence = degrees
            isInfiniteRepeat = true
        }
        
        guard !noteBuffers.isEmpty else { return }
        
        currentRoot = root
        currentScaleType = scaleType
        currentDirection = .ascending
        isDescending = false
        currentDegreeIndex = degreeSequence.first ?? 1
        isPlaying = true
        
        playNextNote(at: 0)
        if droneEnabled { startDrone(for: root) }
    }
    
    private func playNextNote(at index: Int) {
        guard isPlaying else { return }
        
        let nextIndex = index >= noteBuffers.count ? 0 : index
        let positionInCycle = nextIndex % singleCycleLength
        
        if positionInCycle == 0 {
            currentDirection = .ascending
            isDescending = false
        }
        
        if positionInCycle == (singleCycleLength / 2) && !isDescending {
            currentDirection = .descending
            isDescending = true
        }
        
        currentDegreeIndex = degreeSequence[nextIndex]
        
        let buffer = noteBuffers[nextIndex]
        player.scheduleBuffer(buffer) { [weak self] in
            DispatchQueue.main.async { 
                // Stop if we've reached the end and this isn't an infinite repeat
                if nextIndex + 1 >= (self?.noteBuffers.count ?? 0) && !(self?.isInfiniteRepeat ?? false) {
                    self?.stop()
                } else {
                    self?.playNextNote(at: nextIndex + 1)
                }
            }
        }
        if !player.isPlaying { player.play() }
    }
    
    func stop() {
        isPlaying = false
        currentDegreeIndex = 1
        currentDirection = .ascending
        isDescending = false
        player.stop()
        dronePlayer.stop()
    }
    
    private func startDrone(for root: PitchClass) {
        let freq = 440.0 * pow(2.0, Double(midiNote(for: root) - 69 - 12) / 12.0)
        guard let buffer = createSineBuffer(frequency: freq, duration: 2.0, format: engine.mainMixerNode.outputFormat(forBus: 0)) else { return }
        dronePlayer.scheduleBuffer(buffer, at: nil, options: .loops)
        dronePlayer.play()
    }
    
    private func midiNote(for pitch: PitchClass) -> Int {
        switch pitch {
        case .c: 60; case .cSharp: 61; case .d: 62; case .dSharp: 63
        case .e: 64; case .f: 65; case .fSharp: 66; case .g: 67
        case .gSharp: 68; case .a: 69; case .aSharp: 70; case .b: 71
        }
    }
    
    private func buildScaleSequence(for scale: Scale) -> ([Double], [Int]) {
        let base = midiNote(for: scale.root)
        
        let ascendOffsets: [Int]
        let descendOffsets: [Int]
        
        if scale.type == .melodicMinor {
            ascendOffsets = [0,2,3,5,7,9,11,12]
            descendOffsets = [10,8,7,5,3,2,0]
        } else {
            let offsets = scale.type.semitoneOffsetsFromRoot
            ascendOffsets = offsets
            descendOffsets = Array(offsets.dropLast().reversed())
        }
        
        let ascendFreq = ascendOffsets.map { 440 * pow(2.0, Double(base + $0 - 69) / 12) }
        let ascendDeg = Array(1...ascendOffsets.count)
        
        let topFreq = ascendFreq.last!
        let topDeg = ascendDeg.last!
        
        let descendFreq = descendOffsets.map { 440 * pow(2.0, Double(base + $0 - 69) / 12) }
        let descendDeg = Array(stride(from: ascendDeg.count - 1, to: 0, by: -1))
        
        return (ascendFreq + [topFreq] + descendFreq, ascendDeg + [topDeg] + descendDeg)
    }
    
    private func createSineBuffer(frequency: Double, duration: TimeInterval, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sr = format.sampleRate
        let frames = AVAudioFrameCount(duration * sr)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else { return nil }
        buf.frameLength = frames
        for ch in 0..<Int(format.channelCount) {
            guard let ptr = buf.floatChannelData?[ch] else { continue }
            for i in 0..<Int(frames) {
                ptr[i] = Float(sin(2 * .pi * frequency * Double(i) / sr) * 0.28)
            }
        }
        return buf
    }
}

// MARK: - Views

struct ContentView: View {
    @StateObject private var audio = AudioController()
    var body: some View { PracticeView(audioController: audio) }
}

struct PracticeView: View {
    @ObservedObject var audioController: AudioController
    
    @State private var root: PitchClass = .c
    @State private var scaleType: ScaleType = .major
    @State private var repeats: Int? = 1
    @State private var bpm: Double = 80
    @State private var droneEnabled = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                ScaleSelectorView(root: $root, scaleType: $scaleType)
                TempoControlView(bpm: $bpm)
                DroneControlView(isOn: $droneEnabled)
                
                Picker("Repeats", selection: $repeats) {
                    Text("1×").tag(1 as Int?)
                    Text("2×").tag(2 as Int?)
                    Text("3×").tag(3 as Int?)
                    Text("∞").tag(nil as Int?)
                }
                .pickerStyle(.segmented)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            ScaleInfoView(
                root: root,
                spelling: .sharps,
                scaleType: scaleType,
                currentDegreeIndex: audioController.isPlaying ? audioController.currentDegreeIndex : nil,
                currentDirection: audioController.currentDirection
            )
            
            HStack(spacing: 20) {
                Button(action: {
                    audioController.playSingleScale(root: root, scaleType: scaleType, repeats: repeats)
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.green)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: { audioController.stop() }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .opacity(audioController.isPlaying ? 1 : 0.3)
            }
            .padding(.bottom, 30)
        }
        .padding()
        .navigationTitle("Scale Listener")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            audioController.bpm = bpm
            audioController.droneEnabled = droneEnabled
        }
        .onChange(of: bpm) { _, new in audioController.bpm = new }
        .onChange(of: droneEnabled) { _, new in audioController.droneEnabled = new }
    }
}

// MARK: - Supporting Views

struct ScaleSelectorView: View {
    @Binding var root: PitchClass
    @Binding var scaleType: ScaleType
    var body: some View {
        VStack(spacing: 16) {
            Picker("Root", selection: $root) {
                ForEach(PitchClass.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            
            Picker("Scale", selection: $scaleType) {
                ForEach(ScaleType.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
        }
    }
}

struct TempoControlView: View {
    @Binding var bpm: Double
    var body: some View {
        VStack(spacing: 8) {
            Text("Tempo: \(Int(bpm)) BPM").font(.caption.bold())
            Slider(value: $bpm, in: 40...200, step: 1)
        }
    }
}

struct DroneControlView: View {
    @Binding var isOn: Bool
    var body: some View {
        Toggle("Drone (continuous root)", isOn: $isOn)
    }
}

struct NoteRow: View {
    let offsets: [Int]
    let currentDegree: Int?
    let root: PitchClass
    let scaleType: ScaleType
    var body: some View {
        HStack(spacing: scaleType == .chromatic ? 6 : 12) {
            Text("Note").font(.caption.bold()).frame(width: scaleType == .chromatic ? 40 : 50, alignment: .leading)
            ForEach(Array(offsets.enumerated()), id: \.offset) { i, offset in
                let rootIndex = noteIndex(for: root)
                let noteIndex = (rootIndex + offset) % 12
                Text(noteNames[noteIndex])
                    .font(.caption)
                    .frame(width: scaleType == .chromatic ? 20 : 25)
                    .background(currentDegree == i + 1 ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(scaleType == .chromatic ? 3 : 4)
            }
            Spacer()
        }
    }
}

struct SolfegeRow: View {
    let offsets: [Int]
    let currentDegree: Int?
    let scaleType: ScaleType
    let currentDirection: ScaleDirection
    
    var body: some View {
        HStack(spacing: scaleType == .chromatic ? 6 : 12) {
            Text("Solfege").font(.caption.bold()).frame(width: scaleType == .chromatic ? 40 : 50, alignment: .leading)
            ForEach(Array(offsets.enumerated()), id: \.offset) { i, _ in
                let syllables: [String] = {
                    if scaleType == .chromatic && currentDirection == .descending {
                        return descendingChromaticSolfege
                    }
                    if scaleType == .melodicMinor && currentDirection == .descending {
                        return ["do", "re", "me", "fa", "sol", "le", "te", "do"]
                    }
                    return scaleSolfege[scaleType] ?? chromaticSyllables
                }()
                
                let syllable = i < syllables.count ? syllables[i] : "?"
                Text(syllable)
                    .font(.caption)
                    .frame(width: scaleType == .chromatic ? 20 : 25)
                    .background(currentDegree == i + 1 ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(scaleType == .chromatic ? 3 : 4)
            }
            Spacer()
        }
    }
}

struct ScaleInfoView: View {
    let root: PitchClass
    let spelling: AccidentalSpelling
    let scaleType: ScaleType
    let currentDegreeIndex: Int?
    let currentDirection: ScaleDirection
    
    private var displayName: String {
        if scaleType == .melodicMinor {
            return currentDirection == .ascending ? "Melodic Minor (ascending)" : "Natural Minor (descending)"
        }
        if scaleType == .chromatic {
            return currentDirection == .ascending ? "Chromatic (ascending)" : "Chromatic (descending)"
        }
        return "\(root.displayName) \(scaleType.displayName)"
    }
    
    private var scale: Scale { Scale(root: root, spelling: spelling, type: scaleType) }
    
    private func isCurrent(_ offset: Int) -> Bool {
        guard let current = currentDegreeIndex else { return false }
        return scale.type.semitoneOffsetsFromRoot.firstIndex(of: offset).map { $0 + 1 == current } ?? false
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(displayName)
                .font(.title2.bold())
            
            HStack(spacing: scaleType == .chromatic ? 6 : 12) {
                Text("Degree").font(.caption.bold()).frame(width: scaleType == .chromatic ? 40 : 50, alignment: .leading)
                ForEach(Array(scaleDegreeLabels(for: scaleType, direction: currentDirection).enumerated()), id: \.offset) { i, label in
                    Text(label)
                        .font(.caption)
                        .frame(width: scaleType == .chromatic ? 20 : 25)
                        .background(currentDegreeIndex == i + 1 ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1))
                        .cornerRadius(scaleType == .chromatic ? 3 : 4)
                }
                Spacer()
            }
            
            HStack(spacing: scaleType == .chromatic ? 6 : 12) {
                Text("Interval").font(.caption.bold()).frame(width: scaleType == .chromatic ? 40 : 50, alignment: .leading)
                ForEach(scale.type.semitoneOffsetsFromRoot, id: \.self) { offset in
                    Text(intervalNames[offset, default: "?"])
                        .font(.caption)
                        .frame(width: scaleType == .chromatic ? 20 : 25)
                        .background(isCurrent(offset) ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1))
                        .cornerRadius(scaleType == .chromatic ? 3 : 4)
                }
                Spacer()
            }
            
            NoteRow(offsets: scale.type.semitoneOffsetsFromRoot, currentDegree: currentDegreeIndex, root: root, scaleType: scaleType)
            SolfegeRow(offsets: scale.type.semitoneOffsetsFromRoot, currentDegree: currentDegreeIndex, scaleType: scaleType, currentDirection: currentDirection)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    PracticeView(audioController: AudioController())
}

