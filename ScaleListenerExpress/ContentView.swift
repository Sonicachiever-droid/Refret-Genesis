import SwiftUI

// MARK: - Display Mode Enums
enum DisplayMode: String, CaseIterable {
    case note, degree, solfege, interval
}

// MARK: - Tempo Options
enum TempoOption: Int, CaseIterable {
    case sixty = 60, eighty = 80, oneHundred = 100, oneTwenty = 120, oneForty = 140
    
    var displayName: String {
        switch self {
        case .sixty: return "60 BPM"
        case .eighty: return "80 BPM"
        case .oneHundred: return "100 BPM"
        case .oneTwenty: return "120 BPM"
        case .oneForty: return "140 BPM"
        }
    }
}

// MARK: - Scale Data Dictionaries (from original)
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
    .blues: ["do", "me", "fa", "se", "sol", "te", "do"],
    .majorBlues: ["do", "re", "me", "mi", "sol", "la", "do"],
    .chromatic: ["do", "di", "re", "ri", "mi", "fa", "fi", "sol", "si", "la", "li", "ti", "do"]
]

private let intervalNames: [Int: String] = [
    0: "P1", 1: "m2", 2: "M2", 3: "m3", 4: "M3", 5: "P4",
    6: "d5", 7: "P5", 8: "m6", 9: "M6", 10: "m7", 11: "M7", 12: "P8"
]

private let noteNames: [String] = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]

// MARK: - Scale Degree Labels (from original)
private func scaleDegreeLabels(for scaleType: ScaleType) -> [String] {
    switch scaleType {
    case .major: return ["1","2","3","4","5","6","7","8"]
    case .minor: return ["1","2","♭3","4","5","♭6","♭7","8"]
    case .harmonicMinor: return ["1","2","♭3","4","5","♭6","7","8"]
    case .melodicMinor: return ["1","2","♭3","4","5","6","7","8"]
    case .dorian: return ["1","2","♭3","4","5","6","♭7","8"]
    case .phrygian: return ["1","♭2","♭3","4","5","♭6","♭7","8"]
    case .lydian: return ["1","2","3","♯4","5","6","7","8"]
    case .mixolydian: return ["1","2","3","4","5","6","♭7","8"]
    case .locrian: return ["1","♭2","♭3","4","♭5","♭6","♭7","8"]
    case .minorPentatonic: return ["1","♭3","4","5","♭7","8"]
    case .majorPentatonic: return ["1","2","3","5","6","8"]
    case .blues: return ["1","♭3","4","♭5","5","♭7","8"]
    case .majorBlues: return ["1","2","♭3","3","5","6","8"]
    case .chromatic: return ["1","♭2","2","♭3","3","4","♯4","5","♭6","6","♭7","7","8"]
    }
}

// MARK: - Main View
struct ContentView: View {
    @State private var selectedKey: PitchClass = .c
    @State private var selectedScale: ScaleType = .major
    @State private var selectedTempo: TempoOption = .sixty
    @State private var displayMode: DisplayMode = .note
    @State private var currentSymbolIndex: Int = 0
    @State private var scaleSymbols: [String] = []
    @State private var isCycling: Bool = false
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Section - Controls
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        // Key Signature Dropdown
                        VStack(alignment: .leading) {
                            Text("Key")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Key", selection: $selectedKey) {
                                ForEach(PitchClass.allCases, id: \.self) { pitch in
                                    Text(pitch.displayName)
                                        .tag(pitch)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        // Scale Type Dropdown
                        VStack(alignment: .leading) {
                            Text("Scale")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Scale", selection: $selectedScale) {
                                ForEach(ScaleType.allCases, id: \.self) { scale in
                                    Text(scale.displayName)
                                        .tag(scale)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        // Tempo Dropdown
                        VStack(alignment: .leading) {
                            Text("Tempo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Tempo", selection: $selectedTempo) {
                                ForEach(TempoOption.allCases, id: \.self) { tempo in
                                    Text(tempo.displayName)
                                        .tag(tempo)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: geometry.size.height * 0.25)
                
                // Middle Section - Symbol Display
                VStack {
                    Spacer()
                    
                    if scaleSymbols.isEmpty {
                        Text("Select key and Scale to begin")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    } else {
                        Text(scaleSymbols[currentSymbolIndex])
                            .font(.system(size: min(geometry.size.width * 0.15, 80), weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .animation(.easeInOut(duration: 0.3), value: currentSymbolIndex)
                    }
                    
                    Spacer()
                }
                .frame(height: geometry.size.height * 0.35)
                
                // Bottom Section - Controls
                VStack(spacing: 16) {
                    // Toggle Controls
                    HStack(spacing: 20) {
                        // Note Toggle
                        Toggle("Notes", isOn: binding(for: .note))
                            .toggleStyle(.button)
                        
                        // Degree Toggle
                        Toggle("Degrees", isOn: binding(for: .degree))
                            .toggleStyle(.button)
                        
                        // Solfege Toggle
                        Toggle("Solfege", isOn: binding(for: .solfege))
                            .toggleStyle(.button)
                        
                        // Interval Toggle
                        Toggle("Intervals", isOn: binding(for: .interval))
                            .toggleStyle(.button)
                    }
                    .padding(.horizontal)
                    
                    // Play/Stop Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            startCycling()
                        }) {
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                        .disabled(isCycling)
                        
                        Button(action: {
                            stopCycling()
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .disabled(!isCycling)
                    }
                }
                .frame(height: geometry.size.height * 0.4)
            }
        }
        .padding()
        .onAppear(perform: updateScale)
        .onChange(of: selectedKey) { _, _ in updateScale() }
        .onChange(of: selectedScale) { _, _ in updateScale() }
        .onChange(of: displayMode) { _, _ in updateSymbols() }
        .onChange(of: selectedTempo) { _, _ in 
            if isCycling {
                stopCycling()
                startCycling()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func binding(for mode: DisplayMode) -> Binding<Bool> {
        Binding<Bool>(
            get: { displayMode == mode },
            set: { _ in 
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayMode = mode
                }
                updateSymbols()
            }
        )
    }
    
    private func updateScale() {
        let scale = Scale(root: selectedKey, spelling: .sharps, type: selectedScale)
        let offsets = scale.type.semitoneOffsetsFromRoot
        
        // Build ascending scale (up one octave)
        let ascendOffsets = offsets
        
        // Build descending scale (back down, excluding the top octave note)
        let descendOffsets = Array(ascendOffsets.dropLast().reversed())
        
        // Combine: ascend + top note + descend
        let fullScaleOffsets = ascendOffsets + [ascendOffsets.last!] + descendOffsets
        
        scaleSymbols = fullScaleOffsets.map { offset in
            let rootIndex = PitchClass.allCases.firstIndex(of: selectedKey)!
            let noteIndex = (rootIndex + offset) % 12
            return PitchClass.allCases[noteIndex].displayName
        }
        currentSymbolIndex = 0
        updateSymbols()
    }
    
    private func updateSymbols() {
        guard !scaleSymbols.isEmpty else { return }
        
        let scale = Scale(root: selectedKey, spelling: .sharps, type: selectedScale)
        let offsets = scale.type.semitoneOffsetsFromRoot
        
        switch displayMode {
        case .note:
            // Already handled in updateScale() - no change needed
            break
            
        case .degree:
            // Build ascending degrees (1,2,3,4,5,6,7,8)
            let ascendDegrees = Array(1...offsets.count).map { String($0) }
            let topDegree = ascendDegrees.last!
            // Build descending degrees (7,6,5,4,3,2,1)
            let descendDegrees = Array(stride(from: ascendDegrees.count - 1, to: 0, by: -1)).map { String($0) }
            // Combine: ascend + top + descend
            scaleSymbols = ascendDegrees + [topDegree] + descendDegrees
            
        case .solfege:
            // Get scale-specific solfege
            let ascendSolfege = scaleSolfege[selectedScale] ?? ["?"]
            let topSolfege = ascendSolfege.last!
            // Build descending (excluding top note)
            let descendSolfege = Array(ascendSolfege.dropLast().reversed())
            // Combine: ascend + top + descend
            scaleSymbols = ascendSolfege + [topSolfege] + descendSolfege
            
        case .interval:
            // Get intervals for ascending
            let ascendIntervals = offsets.map { offset in
                intervalNames[offset] ?? "?"
            }
            let topInterval = ascendIntervals.last!
            // Build descending (excluding top note)
            let descendIntervals = Array(ascendIntervals.dropLast().reversed())
            // Combine: ascend + top + descend
            scaleSymbols = ascendIntervals + [topInterval] + descendIntervals
        }
        
        currentSymbolIndex = 0
    }
    
    private func startCycling() {
        guard !scaleSymbols.isEmpty else { return }
        isCycling = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(selectedTempo.rawValue), repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentSymbolIndex = (currentSymbolIndex + 1) % scaleSymbols.count
            }
        }
    }
    
    private func stopCycling() {
        isCycling = false
        timer?.invalidate()
        timer = nil
        currentSymbolIndex = 0
    }
}
