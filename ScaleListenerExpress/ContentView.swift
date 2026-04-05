import SwiftUI

// MARK: - Grid Layout Types
enum GridLayout {
    case threeByThree   // 8-note scales (9 boxes, 1 empty)
    case twoByThree     // 6-note scales (6 boxes)
    case threeByFour    // 12-note scales (12 boxes)
    
    var columns: Int {
        switch self {
        case .threeByThree: return 3
        case .twoByThree: return 3
        case .threeByFour: return 4
        }
    }
    
    var rows: Int {
        switch self {
        case .threeByThree: return 3
        case .twoByThree: return 2
        case .threeByFour: return 3
        }
    }
    
    var totalBoxes: Int {
        switch self {
        case .threeByThree: return 9
        case .twoByThree: return 6
        case .threeByFour: return 12
        }
    }
    
    var activeBoxes: Int {
        switch self {
        case .threeByThree: return 8
        case .twoByThree: return 6
        case .threeByFour: return 12
        }
    }
}

// MARK: - Repeat Options
enum RepeatOption: Int, CaseIterable {
    case one = 1, three = 3, five = 5, infinity = 0
    
    var displayName: String {
        switch self {
        case .one: return "1×"
        case .three: return "3×"
        case .five: return "5×"
        case .infinity: return "∞"
        }
    }
}

// MARK: - Display Mode Enums
enum DisplayMode: String, CaseIterable {
    case note, degree, solfege, interval
}

// MARK: - Tempo Options
enum TempoOption: Int, CaseIterable {
    case sixty = 60, eighty = 80, ninety = 90, oneHundred = 100, oneTwenty = 120, oneForty = 140
    
    var displayName: String {
        switch self {
        case .sixty: return "60 BPM"
        case .eighty: return "80 BPM"
        case .ninety: return "90 BPM"
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
    @State private var selectedTempo: TempoOption = .ninety
    @State private var selectedRepeats: RepeatOption = .one
    @State private var displayMode: DisplayMode = .note
    @State private var currentBoxIndex: Int = 0
    @State private var boxContents: [String] = []
    @State private var boxStates: [Bool] = []
    @State private var isCycling: Bool = false
    @State private var timer: Timer?
    @State private var isAscending: Bool = true
    @State private var currentGridLayout: GridLayout = .threeByThree
    @State private var isTransitioning: Bool = false
    @State private var completedCycles: Int = 0
    
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
                
                // Repeat Selector
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Repeats")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("Repeats", selection: $selectedRepeats) {
                            ForEach(RepeatOption.allCases, id: \.self) { repeatOption in
                                Text(repeatOption.displayName)
                                    .tag(repeatOption)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .frame(height: geometry.size.height * 0.25)
                
                // Middle Section - Grid Display
                VStack {
                    Spacer()
                    
                    if boxContents.isEmpty {
                        Text("Select key and Scale to begin")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    } else {
                        // Dynamic Grid Layout
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: currentGridLayout.columns), spacing: 8) {
                            ForEach(0..<currentGridLayout.totalBoxes, id: \.self) { index in
                                BoxView(
                                    content: index < boxContents.count ? boxContents[index] : "",
                                    isActive: index < boxStates.count ? boxStates[index] : false,
                                    isCurrent: index == currentBoxIndex
                                )
                            }
                        }
                        .frame(maxWidth: geometry.size.width * 0.8)
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
        .onAppear(perform: updateGrid)
        .onChange(of: selectedKey) { _, _ in updateGrid() }
        .onChange(of: selectedScale) { _, _ in updateGrid() }
        .onChange(of: displayMode) { _, _ in updateBoxContents() }
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
                updateBoxContents()
            }
        )
    }
    
    private func getGridLayout(for scaleType: ScaleType) -> GridLayout {
        switch scaleType {
        case .minorPentatonic, .majorPentatonic, .blues, .majorBlues:
            return .twoByThree
        case .chromatic:
            return .threeByFour
        default:
            return .threeByThree
        }
    }
    
    private func updateGrid() {
        currentGridLayout = getGridLayout(for: selectedScale)
        currentBoxIndex = -1  // Start with no box lit
        isAscending = true
        updateBoxContents()
    }
    
    private func updateBoxContents() {
        let scale = Scale(root: selectedKey, spelling: .sharps, type: selectedScale)
        let offsets = scale.type.semitoneOffsetsFromRoot
        
        // Build ascending scale
        let ascendingOffsets = offsets
        let topOffset = ascendingOffsets.last!
        let descendingOffsets = Array(ascendingOffsets.dropLast().reversed())
        let fullOffsets = ascendingOffsets + [topOffset] + descendingOffsets
        
        var contents: [String] = []
        
        switch displayMode {
        case .note:
            contents = fullOffsets.map { offset in
                let rootIndex = PitchClass.allCases.firstIndex(of: selectedKey)!
                let noteIndex = (rootIndex + offset) % 12
                return PitchClass.allCases[noteIndex].displayName
            }
            
        case .degree:
            contents = scaleDegreeLabels(for: selectedScale)
            
        case .solfege:
            let ascendSolfege = scaleSolfege[selectedScale] ?? ["?"]
            let topSolfege = ascendSolfege.last!
            let descendSolfege = Array(ascendSolfege.dropLast().reversed())
            contents = ascendSolfege + [topSolfege] + descendSolfege
            
        case .interval:
            let ascendIntervals = offsets.map { offset in
                intervalNames[offset] ?? "?"
            }
            let topInterval = ascendIntervals.last!
            let descendIntervals = Array(ascendIntervals.dropLast().reversed())
            contents = ascendIntervals + [topInterval] + descendIntervals
        }
        
        // Trim to active boxes for the current grid
        boxContents = Array(contents.prefix(currentGridLayout.activeBoxes))
        boxStates = Array(repeating: false, count: currentGridLayout.totalBoxes)
    }
    
    private func startCycling() {
        guard !boxContents.isEmpty else { return }
        isCycling = true
        completedCycles = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(selectedTempo.rawValue), repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                // Turn off all boxes first
                boxStates = Array(repeating: false, count: currentGridLayout.totalBoxes)
                
                // Handle transition state
                if isTransitioning {
                    // We just lit the empty box, now start descending from the top note
                    isTransitioning = false
                    isAscending = false
                    currentBoxIndex = currentGridLayout.activeBoxes - 1  // Start from top note
                } else {
                    // Normal cycling
                    if isAscending {
                        currentBoxIndex += 1
                        
                        // Check if we've reached the top
                        if currentBoxIndex >= currentGridLayout.activeBoxes {
                            // Light the empty box to signal transition
                            isTransitioning = true
                            currentBoxIndex = currentGridLayout.activeBoxes  // Empty box position
                            // Light the empty box
                            if currentBoxIndex < boxStates.count {
                                boxStates[currentBoxIndex] = true
                            }
                            return
                        }
                    } else {
                        currentBoxIndex -= 1
                        
                        // Check if we've completed a full cycle
                        if currentBoxIndex < 0 {
                            completedCycles += 1
                            
                            // Check if we've reached the repeat limit
                            if selectedRepeats != .infinity && completedCycles >= selectedRepeats.rawValue {
                                stopCycling()
                                return
                            }
                            
                            // Reset for next cycle
                            currentBoxIndex = -1  // Reset to start position
                            isAscending = true
                        }
                    }
                }
                
                // Light only the current box (if valid)
                if currentBoxIndex >= 0 && currentBoxIndex < boxStates.count {
                    boxStates[currentBoxIndex] = true
                }
            }
        }
    }
    
    private func stopCycling() {
        isCycling = false
        timer?.invalidate()
        timer = nil
        currentBoxIndex = -1  // Reset to no box lit
        isAscending = true
        isTransitioning = false
        completedCycles = 0
        boxStates = Array(repeating: false, count: currentGridLayout.totalBoxes)
    }
}

// MARK: - Box View Component
struct BoxView: View {
    let content: String
    let isActive: Bool
    let isCurrent: Bool
    
    var body: some View {
        Text(content.isEmpty && isCurrent ? "↩" : content)
            .font(.system(size: 32, weight: .medium, design: .rounded))
            .foregroundColor(isCurrent ? .white : .primary)
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isCurrent ? Color.blue : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? Color.gray : Color.clear, lineWidth: 1)
            )
            .scaleEffect(isCurrent ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isCurrent)
    }
}
