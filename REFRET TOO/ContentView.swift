//
//  ContentView.swift
//  REFRET TOO
//
//  Created by Thomas Kane on 3/10/26.
//

import SwiftUI

enum AppPhase: Equatable {
    case welcome
    case instructions
    case round(number: Int, description: String)
    case chord(name: String, hint: String)

    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .instructions:
            return "How to Play"
        case .round(let number, _):
            return "Round \(number)"
        case .chord(let name, _):
            return "Chord Quiz: \(name)"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome:
            return "Tap START to wake the fretboard"
        case .instructions:
            return "Match the lit string by tapping the correct note"
        case .round(_, let description):
            return description
        case .chord(_, let hint):
            return hint
        }
    }
}

struct ContentView: View {
    @State private var fretsShiftedDown: Bool = true
    @State private var noteOptions: [String] = []
    @State private var correctNote: String = ""
    @State private var selectedNote: String? = nil
    @State private var appPhase: AppPhase = .welcome
    @State private var isToggleOn: Bool = false
    @State private var currentRound: Int = 1
    @State private var woodOnlyMode: Bool = true

    private let notePool: [String] = [
        "E", "F", "F♯", "G", "G♯", "A", "A♯", "B", "C", "C♯", "D", "D♯"
    ]

    var body: some View {
        GeometryReader { proxy in
            let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)
            let rows = 10
            let totalCells = columns.count * rows
            let gridPadding: CGFloat = 12
            let rowSpacing: CGFloat = 2
            let rowHeight = proxy.size.height / CGFloat(rows) - rowSpacing
            let gridWidth = proxy.size.width - gridPadding * 2
            ZStack {
                Color(red: 0.92, green: 0.92, blue: 0.9)
                    .ignoresSafeArea()
                VStack(spacing: 8) {
                    textScreenView(height: (proxy.size.height / CGFloat(rows)) * 1.2)
                        .padding(.horizontal, 24)
                    Spacer()
                }
                ZStack(alignment: .topLeading) {
                    fretWoodOverlay(
                        width: gridWidth,
                        rowHeight: rowHeight,
                        rowSpacing: rowSpacing,
                        offsetRows: fretsShiftedDown ? 1 : 0
                    )
                    .padding(.horizontal, gridPadding)
                    .padding(.top, gridPadding)
                    if !woodOnlyMode {
                        bindingOverlay(
                            width: gridWidth,
                            rowHeight: rowHeight,
                            rowSpacing: rowSpacing,
                            offsetRows: fretsShiftedDown ? 1 : 0
                        )
                        .padding(.horizontal, gridPadding)
                        .padding(.top, gridPadding)

                        fretWireOverlay(
                            width: gridWidth,
                            rowHeight: rowHeight,
                            rowSpacing: rowSpacing,
                            offsetRows: fretsShiftedDown ? 1 : 0
                        )
                        .padding(.horizontal, gridPadding)
                        .padding(.top, gridPadding)

                        markerOverlay(
                            width: gridWidth,
                            rowHeight: rowHeight,
                            rowSpacing: rowSpacing,
                            offsetRows: fretsShiftedDown ? 1 : 0
                        )
                        .padding(.horizontal, gridPadding)
                        .padding(.top, gridPadding)

                        nutOverlay(
                            width: gridWidth,
                            rowHeight: rowHeight,
                            rowSpacing: rowSpacing,
                            offsetRows: fretsShiftedDown ? 1 : 0
                        )
                        .padding(.horizontal, gridPadding)
                        .padding(.top, gridPadding)

                        LazyVGrid(columns: columns, spacing: rowSpacing) {
                            ForEach(0..<totalCells, id: \.self) { index in
                                Color.clear
                                    .frame(height: rowHeight)
                                    .overlay(highlightOverlay(for: index))
                            }
                        }
                        .padding(gridPadding)
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: toggleFrets) {
                    Label(fretsShiftedDown ? "Lift Frets" : "Drop Frets", systemImage: "arrow.up.and.down")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.black.opacity(0.05), in: Capsule())
                }
                .padding(16)
            }
            .overlay(alignment: .bottomLeading) {
                ampToggleView()
                    .padding(.leading, 16)
                    .padding(.bottom, 32)
            }
        }
        .onAppear(perform: generateNoteOptions)
    }

    private func highlightOverlay(for index: Int) -> some View {
        EmptyView()
    }

    private func jewelIndicator(isOn: Bool) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 0.95, green: 0.2, blue: 0.2),
                        Color(red: 0.55, green: 0, blue: 0)
                    ],
                    center: .center,
                    startRadius: 2,
                    endRadius: 18
                )
            )
            .frame(width: 24, height: 24)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 2)
            .opacity(isOn ? 1 : 0.3)
            .animation(.easeInOut(duration: 0.25), value: isOn)
    }

    private func nutOverlay(
        width: CGFloat,
        rowHeight: CGFloat,
        rowSpacing: CGFloat,
        offsetRows: Int
    ) -> some View {
        let nutHeight = rowHeight * 0.35
        let bevelHeight = nutHeight * 0.25
        let baseRow: CGFloat = 1
        let totalOffset = (baseRow + CGFloat(offsetRows)) * (rowHeight + rowSpacing)
        return ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.94, blue: 0.88),
                            Color(red: 0.90, green: 0.86, blue: 0.78)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
                .frame(width: width, height: nutHeight + bevelHeight)

            Rectangle()
                .fill(Color.white.opacity(0.45))
                .frame(width: width * 0.98, height: bevelHeight)
                .offset(y: nutHeight * 0.15)
                .mask(
                    LinearGradient(gradient: Gradient(colors: [.clear, .white, .clear]), startPoint: .leading, endPoint: .trailing)
                )
        }
        .overlay(
            HStack(spacing: width / 6.5) {
                ForEach(0..<6, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.25))
                        .frame(width: 1, height: nutHeight + bevelHeight * 0.6)
                }
            }
            .padding(.horizontal, width * 0.04)
        )
        .padding(.bottom, rowSpacing)
        .offset(y: totalOffset - rowHeight - rowSpacing * 0.5)
        .allowsHitTesting(false)
    }

    private func headstockOverlay(
        width: CGFloat,
        rowHeight: CGFloat,
        rowSpacing: CGFloat,
        offsetRows: Int
    ) -> some View {
        let headstockWidth = width * 0.92
        let headstockHeight = rowHeight * 4.8
        let baseRow: CGFloat = 1
        let totalOffset = (baseRow + CGFloat(offsetRows)) * (rowHeight + rowSpacing)
        let nutOverlap = rowHeight * 0.35
        let additionalDrop = rowHeight * 2.2
        let verticalOffset = totalOffset - headstockHeight + nutOverlap + additionalDrop

        return HeadstockShape()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.14, green: 0.12, blue: 0.12).opacity(0.75),
                        Color(red: 0.05, green: 0.04, blue: 0.05).opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                HeadstockShape()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .overlay {
                GeometryReader { geo in
                    let h = geo.size.height
                    let w = geo.size.width
                    let positions: [CGFloat] = [0.28, 0.48, 0.68]
                    ZStack {
                        ForEach(positions, id: \.self) { pos in
                            tunerHint()
                                .offset(x: -w * 0.44, y: h * pos)
                            tunerHint()
                                .scaleEffect(x: -1, y: 1, anchor: .center)
                                .offset(x: w * 0.44, y: h * pos)
                        }
                    }
                }
            }
            .frame(width: headstockWidth, height: headstockHeight)
            .opacity(0.2)
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
            .offset(x: (width - headstockWidth) / 2, y: verticalOffset)
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }

    private func tunerHint() -> some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.86, green: 0.86, blue: 0.88),
                        Color(red: 0.52, green: 0.53, blue: 0.56)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 22, height: 7)
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
    }

    private func bindingOverlay(
        width: CGFloat,
        rowHeight: CGFloat,
        rowSpacing: CGFloat,
        offsetRows: Int
    ) -> some View {
        let rowsCovered: CGFloat = 3
        let overlayHeight = rowsCovered * rowHeight + (rowsCovered - 1) * rowSpacing
        let baseRow: CGFloat = 2
        let totalOffset = (baseRow + CGFloat(offsetRows)) * (rowHeight + rowSpacing)
        let stripWidth: CGFloat = max(6, width * 0.02)

        return HStack {
            bindingStrip(width: stripWidth, height: overlayHeight)
            Spacer()
            bindingStrip(width: stripWidth, height: overlayHeight)
        }
        .frame(width: width, height: overlayHeight)
        .offset(y: totalOffset)
        .allowsHitTesting(false)
    }

    private func bindingStrip(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: width / 2)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.96, blue: 0.90),
                        Color(red: 0.92, green: 0.88, blue: 0.80)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                VStack {
                    Color.black.opacity(0.2)
                        .frame(height: 1)
                        .offset(x: width * 0.15)
                    Spacer()
                }
            )
            .frame(width: width, height: height)
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 1, y: 0)
    }

    private func textScreenView(height: CGFloat) -> some View {
        let subtitle = appPhase.subtitle
        let accent = Color(red: 0.36, green: 0.24, blue: 0.12)
        return VStack(alignment: .leading, spacing: 8) {
            Text(appPhase.title.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .kerning(1.2)
                .foregroundColor(accent)

            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(accent.opacity(0.95))
                .lineLimit(3)

            Text(promptDetail())
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(accent.opacity(0.7))
                .lineLimit(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(colors: [
                        Color(red: 0.96, green: 0.90, blue: 0.78),
                        Color(red: 0.90, green: 0.82, blue: 0.68)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(accent.opacity(0.25), lineWidth: 1.5)
        )
    }

    private func promptDetail() -> String {
        switch appPhase {
        case .welcome:
            return "Press the chrome toggle to step through instructions and start practicing."
        case .instructions:
            return "Watch for highlighted notes above the fretboard, then tap the matching knob below."
        case .round(let number, _):
            if number == 1 { return "Focus on open strings and memorize their note names." }
            if number == 2 { return "Shift up to the first fret—notes move one semitone higher." }
            return "Keep climbing: each round drops the fretboard down a row."
        case .chord(let name, _):
            return "Identify each tone in \(name). Use the knobs to choose the correct notes."
        }
    }

    private func ampToggleView() -> some View {
        VStack(spacing: 10) {
            Text("START")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black.opacity(0.7))
            Button(action: toggleAmpSwitch) {
                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(colors: [
                                Color(red: 0.78, green: 0.80, blue: 0.82),
                                Color(red: 0.58, green: 0.60, blue: 0.62)
                            ], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 36, height: 108)
                        .overlay(
                            Capsule()
                                .stroke(Color.black.opacity(0.25), lineWidth: 1)
                        )

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.85, green: 0.86, blue: 0.88))
                        .frame(width: 12, height: 60)
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                        .offset(y: isToggleOn ? 25 : -25)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isToggleOn)
                }
            }
            .buttonStyle(.plain)

            Text("NEXT")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black.opacity(0.7))

            jewelIndicator(isOn: appPhase != .welcome)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.92, green: 0.91, blue: 0.88))
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }

    private func markerOverlay(
        width: CGFloat,
        rowHeight: CGFloat,
        rowSpacing: CGFloat,
        offsetRows: Int
    ) -> some View {
        let baseRow: CGFloat = 2
        let totalOffset = (baseRow + CGFloat(offsetRows)) * (rowHeight + rowSpacing)
        let markerPositions = [2]
        return ZStack {
            ForEach(markerPositions, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.25), lineWidth: 1)
                    )
                    .frame(width: rowHeight * 0.35, height: rowHeight * 0.35)
                    .offset(
                        x: 0,
                        y: totalOffset + CGFloat(index) * (rowHeight + rowSpacing) + rowHeight / 2 - rowHeight * 0.175
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
        }
        .frame(width: width, alignment: .center)
        .allowsHitTesting(false)
    }

    private func notePadOverlay(
        width: CGFloat,
        rowHeight: CGFloat,
        rowSpacing: CGFloat
    ) -> some View {
        let padWidth = width * 0.55
        let padHeight = rowHeight * 2 + rowSpacing
        let baseRow: CGFloat = 5
        let totalOffset = baseRow * (rowHeight + rowSpacing)
        let knobSize = (padWidth - rowSpacing * 3) / 2

        return HStack {
            Spacer()
            VStack(spacing: rowSpacing) {
                VStack(spacing: rowSpacing) {
                    ForEach(0..<2) { row in
                        HStack(spacing: rowSpacing) {
                            ForEach(0..<2) { col in
                                let index = row * 2 + col
                                noteButton(at: index, size: knobSize)
                            }
                        }
                    }
                }
                if let selection = selectedNote {
                    Text(selection == correctNote ? "Correct" : "Try Again")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selection == correctNote ? .green : .red)
                        .transition(.opacity)
                }
            }
            .padding(18)
            .frame(width: padWidth, height: padHeight + rowSpacing + 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(colors: [
                            Color(red: 0.82, green: 0.82, blue: 0.84),
                            Color(red: 0.62, green: 0.63, blue: 0.66),
                            Color(red: 0.78, green: 0.79, blue: 0.82)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(colors: [
                            Color.white.opacity(0.7),
                            Color.black.opacity(0.2)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
            )
            Spacer()
        }
        .frame(width: width)
        .offset(y: totalOffset)
    }

    private func noteButton(at index: Int, size: CGFloat) -> some View {
        let label = noteOptions.indices.contains(index) ? noteOptions[index] : "--"
        let isSelected = selectedNote == label
        let isCorrect = label == correctNote
        return Button {
            handleNoteSelection(label)
        } label: {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(colors: [
                            Color.black,
                            Color(red: 0.08, green: 0.08, blue: 0.08)
                        ], center: .center, startRadius: 4, endRadius: size * 0.6)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 6)

                Circle()
                    .stroke(isSelected ? (isCorrect ? Color.green : Color.red) : Color.white.opacity(0.15), lineWidth: 3)
                    .blur(radius: isSelected ? 0 : 1)

                VStack(spacing: 6) {
                    Text(label)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)

                    Rectangle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 3, height: size * 0.25)
                        .cornerRadius(1.5)
                        .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                }
                .offset(y: -2)
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .disabled(label == "--")
    }

    private func fretWoodOverlay(
        width: CGFloat,
        rowHeight: CGFloat,
        rowSpacing: CGFloat,
        offsetRows: Int
    ) -> some View {
        let rowsCovered: CGFloat = 3
        let overlayHeight = rowsCovered * rowHeight + (rowsCovered - 1) * rowSpacing
        let baseRow: CGFloat = 2 // align with highlighted fret range (cells 9-20)
        let totalOffset = (baseRow + CGFloat(offsetRows)) * (rowHeight + rowSpacing)
        let parameters = WoodShaderParameters(
            ringDensity: 14,
            grainRoughness: 0.55,
            colorVariation: 0.28,
            stretch: 5.5,
            orientation: .pi / 2,
            sheenStrength: 0.08,
            lightColor: Color(red: 0.93, green: 0.80, blue: 0.60),
            darkColor: Color(red: 0.54, green: 0.33, blue: 0.18)
        )

        return RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .frame(width: width, height: overlayHeight)
            .woodShader(parameters)
            .overlay(
                VStack(spacing: rowSpacing) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 2)
                    }
                }
                .padding(.vertical, rowSpacing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .offset(y: totalOffset)
            .allowsHitTesting(false)
    }

    private func fretWireOverlay(
        width: CGFloat,
        rowHeight: CGFloat,
        rowSpacing: CGFloat,
        offsetRows: Int
    ) -> some View {
        let fretCount = 3
        let baseRow: CGFloat = 2
        let totalOffset = (baseRow + CGFloat(offsetRows)) * (rowHeight + rowSpacing)
        return ZStack(alignment: .top) {
            ForEach(1...fretCount, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.85, green: 0.85, blue: 0.88),
                                Color(red: 0.65, green: 0.66, blue: 0.70)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width, height: rowHeight * 0.12)
                    .offset(y: totalOffset + CGFloat(index) * (rowHeight + rowSpacing) - (rowHeight * 0.06))
                    .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 1)
            }
        }
        .allowsHitTesting(false)
    }

    private func toggleFrets() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            fretsShiftedDown.toggle()
        }
        generateNoteOptions()
    }

    private func toggleAmpSwitch() {
        isToggleOn.toggle()
        advancePhase()
    }

    private func advancePhase() {
        switch appPhase {
        case .welcome:
            appPhase = .instructions
        case .instructions:
            currentRound = 1
            appPhase = .round(number: currentRound, description: roundDescription(for: currentRound))
        case .round(let number, _):
            if number < 3 {
                currentRound = number + 1
                appPhase = .round(number: currentRound, description: roundDescription(for: currentRound))
            } else {
                appPhase = .chord(name: "E minor 6", hint: "Choose all the chord tones from the knobs")
            }
            fretsShiftedDown.toggle()
        case .chord:
            appPhase = .welcome
            currentRound = 1
        }
        generateNoteOptions()
    }

    private func roundDescription(for number: Int) -> String {
        switch number {
        case 1: return "Open Strings"
        case 2: return "First Fret"
        case 3: return "Second Fret"
        default: return "Round \(number)"
        }
    }

    private func handleNoteSelection(_ note: String) {
        selectedNote = note
        if note == correctNote {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                generateNoteOptions()
            }
        }
    }

    private func generateNoteOptions() {
        guard !notePool.isEmpty else { return }
        let shuffled = notePool.shuffled()
        let newCorrect = shuffled.first ?? "E"
        var options: Set<String> = [newCorrect]
        while options.count < 4 {
            if let option = notePool.randomElement() {
                options.insert(option)
            }
        }
        correctNote = newCorrect
        noteOptions = Array(options).shuffled()
        selectedNote = nil
    }
}

#Preview {
    ContentView()
}

struct HeadstockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let curveDepth = w * 0.12

        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w * 0.1, y: h * 0.18),
            control1: CGPoint(x: w * 0.35, y: h * 0.05),
            control2: CGPoint(x: w * 0.2, y: h * 0.08)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.38),
            control1: CGPoint(x: w * 0.02, y: h * 0.24),
            control2: CGPoint(x: 0, y: h * 0.32)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.12, y: h * 0.78),
            control1: CGPoint(x: w * 0.04, y: h * 0.48),
            control2: CGPoint(x: w * 0.05, y: h * 0.66)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.2, y: h),
            control1: CGPoint(x: w * 0.1, y: h * 0.92),
            control2: CGPoint(x: w * 0.12, y: h)
        )

        path.addLine(to: CGPoint(x: w * 0.8, y: h))

        path.addCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.78),
            control1: CGPoint(x: w * 0.88, y: h),
            control2: CGPoint(x: w * 0.9, y: h * 0.92)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.38),
            control1: CGPoint(x: w * 0.95, y: h * 0.66),
            control2: CGPoint(x: w * 0.96, y: h * 0.48)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.9, y: h * 0.18),
            control1: CGPoint(x: w, y: h * 0.32),
            control2: CGPoint(x: w * 0.98, y: h * 0.24)
        )

        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w * 0.8, y: h * 0.08),
            control2: CGPoint(x: w * 0.65, y: h * 0.05)
        )

        path.closeSubpath()

        let dipWidth = curveDepth
        let dipHeight = h * 0.12
        let dipRect = CGRect(x: (w - dipWidth) / 2, y: h * 0.04, width: dipWidth, height: dipHeight)
        path.addRect(dipRect)

        return path
    }
}

struct TweedBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let size = max(proxy.size.width, proxy.size.height)
            ZStack {
                Color(red: 0.95, green: 0.90, blue: 0.78)
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.92, blue: 0.82).opacity(0.9),
                        Color(red: 0.90, green: 0.84, blue: 0.70).opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Canvas { context, _ in
                    let stripeColor = Color(red: 0.82, green: 0.72, blue: 0.56).opacity(0.25)
                    let stripeWidth: CGFloat = 6
                    let spacing: CGFloat = 14
                    for index in -2...Int(size / spacing) + 2 {
                        var path = Path()
                        let offset = CGFloat(index) * spacing
                        path.move(to: CGPoint(x: offset, y: -size))
                        path.addLine(to: CGPoint(x: offset + size, y: size * 2))
                        context.stroke(path, with: .color(stripeColor), lineWidth: stripeWidth)
                    }
                }
                .blendMode(.multiply)
            }
        }
    }
}

struct ChickenHeadPointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.25, y: h * 0.1))
        path.addCurve(
            to: CGPoint(x: w * 0.75, y: h * 0.15),
            control1: CGPoint(x: w * 0.42, y: 0),
            control2: CGPoint(x: w * 0.58, y: 0.05)
        )
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.55))
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.95),
            control1: CGPoint(x: w * 0.88, y: h * 0.75),
            control2: CGPoint(x: w * 0.75, y: h * 0.92)
        )
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.95))
        path.addCurve(
            to: CGPoint(x: w * 0.22, y: h * 0.55),
            control1: CGPoint(x: w * 0.25, y: h * 0.92),
            control2: CGPoint(x: w * 0.12, y: h * 0.75)
        )
        path.closeSubpath()
        return path
    }
}
