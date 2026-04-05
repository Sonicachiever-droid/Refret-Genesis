import SwiftUI
import UIKit

enum AppPhase: Equatable {
    case welcome
    case instructions
    case round(number: Int, description: String)
    case chord(name: String, hint: String)

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .instructions: return "How to Play"
        case .round(let number, _): return "Round \(number)"
        case .chord(let name, _): return "Chord Quiz: \(name)"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome: return "Tap START to wake the fretboard"
        case .instructions: return "Match the lit string by tapping the correct note"
        case .round(_, let description): return description
        case .chord(_, let hint): return hint
        }
    }
}

// MARK: - GENESIS ALIGNMENT MATH (exact same as your original Genesis file)
private func baselineNutTargetY(highlightTopGridLineY: CGFloat, gridRowHeight: CGFloat) -> CGFloat {
    highlightTopGridLineY + 2 * gridRowHeight
}

private func resolvedNeckTopY(
    currentFretStart: Int,
    nutTargetY: CGFloat,
    highlightCenterY: CGFloat,
    activeMidpoint: CGFloat
) -> CGFloat {
    if currentFretStart == 0 {
        return nutTargetY
    }
    return highlightCenterY - activeMidpoint
}

private enum FretMath {
    static func fretPositionRatios(totalFrets: Int, scaleLength: Double) -> [CGFloat] {
        guard totalFrets > 0, scaleLength > 0 else { return [] }
        return (0...totalFrets).map { fret in
            let distance = scaleLength - scaleLength / pow(2.0, Double(fret) / 12.0)
            return CGFloat(distance / scaleLength)
        }
    }
}

private struct StringLineOverlay: View {
    let neckWidth: CGFloat
    let horizontalPadding: CGFloat
    private let totalStrings: Int = 6
    private let stratNutWidthInches: CGFloat = 1.650
    private let stratStringSpanInches: CGFloat = 1.362

    var body: some View {
        GeometryReader { geo in
            let nutWidth = neckWidth * 0.99
            let overallWidth = geo.size.width
            let overallPadding = (overallWidth - nutWidth) / 2
            
            let widthPerInch = nutWidth / stratNutWidthInches
            let interStringSpacing = (stratStringSpanInches / CGFloat(totalStrings - 1)) * widthPerInch
            let edgeMargin = ((stratNutWidthInches - stratStringSpanInches) / 2) * widthPerInch
            let grooveCenters = (0..<totalStrings).map { index in
                overallPadding + edgeMargin + CGFloat(index) * interStringSpacing
            }

            ZStack {
                ForEach(0..<totalStrings, id: \.self) { index in
                    let stringX = grooveCenters[index]
                    let isLowString = index <= 2
                    
                    if isLowString {
                        BrassStringView(
                            stringX: stringX,
                            stringHeight: geo.size.height,
                            stringNumber: 6 - index
                        )
                    } else {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.9, green: 0.9, blue: 0.85),
                                        Color(red: 0.7, green: 0.7, blue: 0.65),
                                        Color(red: 0.5, green: 0.5, blue: 0.45)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 1.5, height: geo.size.height)
                            .position(x: stringX, y: geo.size.height / 2)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

private struct BrassStringView: View {
    let stringX: CGFloat
    let stringHeight: CGFloat
    let stringNumber: Int
    
    private var stringThickness: CGFloat {
        switch stringNumber {
        case 6: return 4.0
        case 5: return 3.5
        case 4: return 3.0
        default: return 2.5
        }
    }
    
    private var segmentCount: Int {
        switch stringNumber {
        case 6: return 8
        case 5: return 7
        case 4: return 6
        default: return 5
        }
    }

    var body: some View {
        let segmentHeight: CGFloat = stringHeight / CGFloat(segmentCount)
        
        VStack(spacing: 0) {
            ForEach(0..<segmentCount, id: \.self) { segment in
                BrassStringSegment(
                    width: stringThickness,
                    height: segmentHeight,
                    segmentIndex: segment,
                    totalSegments: segmentCount
                )
            }
        }
        .position(x: stringX, y: stringHeight / 2)
    }
}

private struct BrassStringSegment: View {
    let width: CGFloat
    let height: CGFloat
    let segmentIndex: Int
    let totalSegments: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: width / 2, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.94, blue: 0.88),
                        Color(red: 0.82, green: 0.69, blue: 0.47),
                        Color(red: 0.65, green: 0.50, blue: 0.30),
                        Color(red: 0.85, green: 0.75, blue: 0.60)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: width / 2)
                    .stroke(Color.black.opacity(0.2), lineWidth: 0.3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: width / 2)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.6), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 0.5)
            .frame(width: width, height: max(height, 2))
    }
}

private struct NutSlotDotsOverlay: View {
    let neckWidth: CGFloat
    let horizontalPadding: CGFloat
    let highlightTopY: CGFloat
    private let totalStrings: Int = 6
    private let dotDiameter: CGFloat = 12
    private let stratNutWidthInches: CGFloat = 1.650
    private let stratStringSpanInches: CGFloat = 1.362

    var body: some View {
        GeometryReader { geo in
            let nutWidth = neckWidth * 0.99
            let overallWidth = geo.size.width
            let overallPadding = (overallWidth - nutWidth) / 2
            
            let widthPerInch = nutWidth / stratNutWidthInches
            let interStringSpacing = (stratStringSpanInches / CGFloat(totalStrings - 1)) * widthPerInch
            let edgeMargin = ((stratNutWidthInches - stratStringSpanInches) / 2) * widthPerInch
            let grooveCenters = (0..<totalStrings).map { index in
                overallPadding + edgeMargin + CGFloat(index) * interStringSpacing
            }
            
            let clampedY = min(max(highlightTopY, 0), geo.size.height)

            ZStack {
                ForEach(0..<totalStrings, id: \.self) { index in
                    let stringX = grooveCenters[index]

                    Circle()
                        .fill(Color.red)
                        .frame(width: dotDiameter, height: dotDiameter)
                        .position(x: stringX, y: clampedY)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

private struct NoteIndicatorLayer: View {
    @ObservedObject var gameManager: GameManager
    let highlightWidth: CGFloat
    let centerY: CGFloat
    let availableSize: CGSize
    let boxHeight: CGFloat
    let neckWidth: CGFloat
    private let totalStrings: Int = 6
    private let stratNutWidthInches: CGFloat = 1.650
    private let stratStringSpanInches: CGFloat = 1.362

    var body: some View {
        let clampedBoxHeight = min(boxHeight, availableSize.height)
        let nutWidth = neckWidth * 0.99
        let overallWidth = availableSize.width
        let overallPadding = (overallWidth - nutWidth) / 2

        let widthPerInch = nutWidth / stratNutWidthInches
        let interStringSpacing = (stratStringSpanInches / CGFloat(totalStrings - 1)) * widthPerInch
        let edgeMargin = ((stratNutWidthInches - stratStringSpanInches) / 2) * widthPerInch
        let grooveCenters = (0..<totalStrings).map { index in
            overallPadding + edgeMargin + CGFloat(index) * interStringSpacing
        }

        let minCenterSpacing = grooveCenters.enumerated().dropFirst().map { idx, center in
            center - grooveCenters[idx - 1]
        }.min() ?? interStringSpacing
        let spacingGap = max(minCenterSpacing * 0.12, 6)
        let maxBoxWidthFromSpacing = max(minCenterSpacing - spacingGap, 0)
        let boxWidth = min(boxHeight * 1.8, maxBoxWidthFromSpacing)

        return ZStack {
            ForEach(0..<totalStrings, id: \.self) { index in
                let xPosition = grooveCenters[index]

                NoteIndicatorBox(
                    isLit: gameManager.litCircleIndex == index,
                    isWrong: gameManager.wrongPressCircle == index,
                    shownNote: gameManager.shownNotes.first(where: { $0.index == index })?.note,
                    isShowingNote: gameManager.showingNote
                )
                .frame(width: boxWidth, height: clampedBoxHeight)
                .position(x: xPosition, y: centerY)
            }
        }
    }
}

private struct NoteIndicatorBox: View {
    let isLit: Bool
    let isWrong: Bool
    let shownNote: String?
    let isShowingNote: Bool

    var body: some View {
        let baseColor: Color = isWrong ? .red : (isLit ? .green : Color.white)

        return ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(baseColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.black, lineWidth: 2)
                )

            if isShowingNote, let note = shownNote {
                Text(note)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

private struct MapleSegmentedBackground: View {
    let fretRatios: [CGFloat]
    let cornerRadius: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let neckHeight = geometry.size.height
            let neckWidth = geometry.size.width
            let segments = segmentBounds(from: fretRatios)
            let bindingInset = max(neckWidth * 0.02, 6)
            let mapleTexture = Image("FretWoodSET2Maple")

            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ForEach(Array(segments.enumerated()), id: \.offset) { index, bounds in
                        let segmentHeight = max((bounds.end - bounds.start) * neckHeight, 1)
                        mapleTexture
                            .resizable()
                            .scaledToFill()
                            .frame(width: neckWidth, height: segmentHeight)
                            .clipped()
                    }
                }
                .padding(.horizontal, bindingInset)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.14),
                                Color.clear,
                                Color.black.opacity(0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.multiply)

                VStack(spacing: 0) {
                    ForEach(Array(segments.enumerated()), id: \.offset) { index, bounds in
                        Spacer()
                            .frame(height: max((bounds.end - bounds.start) * neckHeight, 1))
                            .overlay(
                                Rectangle()
                                    .fill(Color.white.opacity(((index + 1) % 3 == 0) ? 0.065 : 0))
                                    .frame(height: 1.2)
                                    .opacity(bounds.end >= 1 ? 0 : 1)
                            )
                    }
                }
                .padding(.horizontal, bindingInset)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    private func segmentBounds(from ratios: [CGFloat]) -> [(start: CGFloat, end: CGFloat)] {
        guard ratios.count >= 2 else { return [(0, 1)] }
        var pairs: [(CGFloat, CGFloat)] = []
        for index in 0..<(ratios.count - 1) {
            let start = ratios[index]
            let end = ratios[index + 1]
            pairs.append((start, end))
        }
        if let last = ratios.last, last < 1 {
            pairs.append((last, 1))
        }
        return pairs
    }
}

private struct DeveloperButtonStack: View {
    let windowShiftUp: () -> Void
    let windowShiftDown: () -> Void
    let neckShiftUp: () -> Void
    let neckShiftDown: () -> Void
    let canWindowShiftUp: Bool
    let canWindowShiftDown: Bool
    let canNeckShiftUp: Bool
    let canNeckShiftDown: Bool

    var body: some View {
        HStack(spacing: 32) {
            VStack(spacing: 8) {
                devButton(icon: "arrow.up", action: neckShiftUp, isEnabled: canNeckShiftUp)
                devButton(icon: "arrow.down", action: neckShiftDown, isEnabled: canNeckShiftDown)
                Text("NECK")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .bold()
            }
            
            VStack(spacing: 8) {
                devButton(icon: "arrow.up", action: windowShiftUp, isEnabled: canWindowShiftUp)
                devButton(icon: "arrow.down", action: windowShiftDown, isEnabled: canWindowShiftDown)
                Text("WINDOW")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.45))
                .blur(radius: 2)
        )
    }

    private func devButton(icon: String, action: @escaping () -> Void, isEnabled: Bool) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isEnabled ? 0.95 : 0.4),
                                    Color.white.opacity(isEnabled ? 0.65 : 0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 3)
                .opacity(isEnabled ? 1 : 0.35)
        }
        .disabled(!isEnabled)
    }
}

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @State private var currentFretStart: Int = 0
    @State private var currentWindowRow: Int = 2
    @State private var noteOptions: [String] = []
    @State private var selectedNote: String? = nil
    @State private var appPhase: AppPhase = .welcome
    @State private var isToggleOn: Bool = false
    @State private var currentRound: Int = 1
    private let totalFrets: Int = 22
    private let scaleLengthInches: Double = 25.5
    private var maxFretOffset: Int { totalFrets }
    private var minFretOffset: Int { -totalFrets }
    private let topBannerMessages = ["Welcome", "Are you ready to start?", "Three", "Two", "One", "Go!"]

    var body: some View {
        GeometryReader { proxy in
            let padding: CGFloat = 24
            let neckWidth = (proxy.size.width - padding * 2) * 0.8
            let fretRatios = FretMath.fretPositionRatios(totalFrets: totalFrets, scaleLength: scaleLengthInches)
            let visibleFrets = min(totalFrets, 5)
            let visibleFretIndex = min(visibleFrets, fretRatios.count - 1)
            let visibleRatio = max(fretRatios[visibleFretIndex], 0.05)
            let visibleClipHeight = proxy.size.height * 0.96
            let unclippedHeight = visibleClipHeight / visibleRatio
            let minimumNeckHeight = proxy.size.height * 1.35
            let neckHeight = max(unclippedHeight, minimumNeckHeight)
            let nutHeight = max(neckHeight * 0.02, 18)
            let nutVisualHeight = nutHeight * 0.4
            let debugGridColumns = 5
            let debugGridRows = 8
            let gridRowHeight = proxy.size.height / CGFloat(debugGridRows)
            
            let highlightHeight = 3 * gridRowHeight
            let highlightTopGridLineY = CGFloat(currentWindowRow) * gridRowHeight
            let pipingCenterY = highlightTopGridLineY + highlightHeight / 2
            let highlightAvailableWidth = max(proxy.size.width - padding * 2, 0)
            let highlightExtraWidth = max(highlightAvailableWidth - neckWidth, 0)
            let highlightWidth = neckWidth + highlightExtraWidth / 2
            let highlightCornerRadius = min(24, highlightWidth * 0.08)
            let overlayAvailableSize = proxy.size
            let fretTitle = currentFretStart == 0 ? fretLabel(for: gameManager.currentFret) : fretLabel(for: abs(currentFretStart))
            let activeStringIndex = gameManager.litCircleIndex ?? gameManager.lastLitCircleIndex ?? 0
            let clampedStringIndex = min(max(activeStringIndex, 0), 5)
            let displayedStringNumber = 6 - clampedStringIndex
            let stringTitle = "String \(displayedStringNumber)"
            let topBannerMessage = topBannerMessages.first ?? "Welcome"

            let unsignedN = abs(currentFretStart)
            let activeMidpointIndex: Int = {
                if currentFretStart > 0 {
                    return max(currentFretStart - 1, 0)
                }
                return unsignedN
            }()
            let clampedN = min(activeMidpointIndex, fretRatios.count - 2)
            let topRatio = fretRatios[clampedN]
            let bottomRatio = fretRatios[clampedN + 1]
            let midRatio = (topRatio + bottomRatio) / 2.0
            let sign: CGFloat = currentFretStart >= 0 ? 1.0 : -1.0
            let activeMidpoint = midRatio * neckHeight * sign

            let nutTargetY = baselineNutTargetY(highlightTopGridLineY: highlightTopGridLineY, gridRowHeight: gridRowHeight)
            let neckTopY = resolvedNeckTopY(
                currentFretStart: currentFretStart,
                nutTargetY: nutTargetY,
                highlightCenterY: pipingCenterY,
                activeMidpoint: activeMidpoint
            )

            let scale = UIScreen.main.scale
            let neckOffsetY: CGFloat = {
                if currentFretStart == 0 {
                    let raw = neckTopY - proxy.size.height / 2 + neckHeight / 2
                    return (raw * scale).rounded() / scale
                } else {
                    let raw = pipingCenterY - activeMidpoint - proxy.size.height / 2 + neckHeight / 2
                    return (raw * scale).rounded() / scale
                }
            }()

            // <<< THIS IS THE ONLY LINE YOU EVER CHANGE >>>
            // More negative = blue lines move UP
            // Less negative / positive = blue lines move DOWN
            // We are very close now — try 0.55 first
            let manualBlueAdjustment: CGFloat = -gridRowHeight * 0.55

            let finalNeckOffsetY = neckOffsetY + manualBlueAdjustment

            ZStack {
                Image("RosewoodOne")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                HStack {
                    Spacer()
                    ZStack {
                        ZStack(alignment: .top) {
                            ZStack {
                                MapleSegmentedBackground(
                                    fretRatios: fretRatios,
                                    cornerRadius: 10
                                )
                                BindingLayer()
                                FretWireLayer(fretRatios: fretRatios)
                                FretMarkerLayer(fretRatios: fretRatios)
                            }
                            .frame(width: neckWidth, height: neckHeight)
                            .overlay {
                                ProjectLinebackerOverlay(fretRatios: fretRatios, neckHeight: neckHeight)
                            }

                            NutLayer(width: neckWidth * 0.99, height: nutVisualHeight)
                                .frame(width: neckWidth * 0.99, height: nutVisualHeight)
                                .offset(y: -nutVisualHeight * 0.85)
                        }
                        .frame(width: neckWidth, height: neckHeight)
                        .offset(y: finalNeckOffsetY)
                    }
                    .frame(width: neckWidth, height: visibleClipHeight)
                    .clipped()
                    Spacer()
                }
                .padding(.horizontal, padding)

                StringLineOverlay(
                    neckWidth: neckWidth,
                    horizontalPadding: padding
                )

                NutFirstFretHighlight(
                    width: highlightWidth,
                    height: highlightHeight,
                    cornerRadius: highlightCornerRadius
                )
                .frame(width: highlightWidth, height: highlightHeight)
                .position(x: proxy.size.width / 2, y: pipingCenterY)
                .allowsHitTesting(false)
                .ignoresSafeArea()

                NoteIndicatorLayer(
                    gameManager: gameManager,
                    highlightWidth: highlightWidth,
                    centerY: pipingCenterY,
                    availableSize: overlayAvailableSize,
                    boxHeight: gridRowHeight * 0.7,
                    neckWidth: neckWidth
                )
                .allowsHitTesting(false)
                .ignoresSafeArea()

                Rectangle()
                    .fill(Color.green)
                    .frame(width: highlightWidth, height: 2)
                    .position(x: proxy.size.width / 2, y: pipingCenterY)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()

                GeometryReader { matteGeo in
                    DarkMatteOverlay(
                        canvasSize: matteGeo.size,
                        highlightWidth: highlightWidth,
                        highlightHeight: highlightHeight,
                        highlightCenter: CGPoint(x: matteGeo.size.width / 2, y: pipingCenterY),
                        highlightCornerRadius: highlightCornerRadius
                    )
                }
                .allowsHitTesting(false)
                .ignoresSafeArea()

                DeveloperButtonStack(
                    windowShiftUp: { shiftWindow(by: -1) },
                    windowShiftDown: { shiftWindow(by: 1) },
                    neckShiftUp: { shiftFretSpan(by: 1) },
                    neckShiftDown: { shiftFretSpan(by: -1) },
                    canWindowShiftUp: currentWindowRow > 0,
                    canWindowShiftDown: currentWindowRow < debugGridRows - 1,
                    canNeckShiftUp: currentFretStart < maxFretOffset,
                    canNeckShiftDown: currentFretStart > minFretOffset
                )
                .padding(.bottom, proxy.size.height * 0.05)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .overlay(alignment: .top) {
                TopStatusOverlay(
                    topMessage: topBannerMessage,
                    leftLabel: fretTitle,
                    rightLabel: stringTitle,
                    gapHeight: highlightTopGridLineY,
                    horizontalPadding: padding
                )
                .frame(width: proxy.size.width)
            }
            .overlay {
                debugGridOverlay(size: proxy.size, columns: debugGridColumns, rows: debugGridRows)
                    .allowsHitTesting(false)
                    .opacity(0.8)
            }
            .overlay {
                NutSlotDotsOverlay(
                    neckWidth: neckWidth,
                    horizontalPadding: padding,
                    highlightTopY: highlightTopGridLineY
                )
                .allowsHitTesting(false)
            }
        }
        .onAppear(perform: generateNoteOptions)
    }

    private func shiftFretSpan(by delta: Int) {
        guard delta != 0 else { return }
        let proposed = currentFretStart + delta
        let clamped = min(max(proposed, minFretOffset), maxFretOffset)
        guard clamped != currentFretStart else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            currentFretStart = clamped
        }
    }

    private func shiftWindow(by delta: Int) {
        let proposed = currentWindowRow + delta
        let clamped = min(max(proposed, 0), 7)
        guard clamped != currentWindowRow else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            currentWindowRow = clamped
        }
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
                let nextRound = number + 1
                appPhase = .round(number: nextRound, description: roundDescription(for: nextRound))
            } else {
                appPhase = .chord(name: "E minor 6", hint: "Choose all the chord tones from the knobs")
            }
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
        generateNoteOptions()
    }

    private func generateNoteOptions() {
        let notes = ["E", "F", "F♯", "G", "G♯", "A", "A♯", "B", "C", "C♯", "D", "D♯"]
        var options: Set<String> = []
        while options.count < 4 {
            if let option = notes.randomElement() {
                options.insert(option)
            }
        }
        noteOptions = Array(options).shuffled()
        selectedNote = nil
    }

    private func fretLabel(for fret: Int) -> String {
        return fret <= 0 ? "Open Strings" : "Fret \(fret)"
    }
}

// (All remaining structs are unchanged and exactly as in your last working file)

private struct TopStatusOverlay: View {
    let topMessage: String
    let leftLabel: String
    let rightLabel: String
    let gapHeight: CGFloat
    let horizontalPadding: CGFloat

    var body: some View {
        let safeHeight = max(gapHeight, 0)
        let bannerFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
        let measuredWidth = max(
            textWidth(for: leftLabel, font: bannerFont),
            textWidth(for: rightLabel, font: bannerFont),
            textWidth(for: "Open Strings", font: bannerFont)
        )
        let bannerWidth = measuredWidth + 32
        let bannerHeight = max(min(safeHeight * 0.32, 52), 44)
        return ZStack(alignment: .top) {
            WideStatusBanner(text: topMessage)
                .frame(height: safeHeight * 0.5)
                .offset(y: -(safeHeight * 0.2) - 12)

            VStack {
                Spacer(minLength: 0)
                HStack(spacing: 16) {
                    MiniTVFrame(text: leftLabel, width: bannerWidth, height: bannerHeight)
                    MiniTVFrame(text: rightLabel, width: bannerWidth, height: bannerHeight)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: safeHeight, alignment: .bottom)
        .allowsHitTesting(false)
    }

    private func textWidth(for text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: attributes)
        return ceil(size.width)
    }
}

private struct MiniTVFrame: View {
    let text: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        let bezelWidth = width + 24
        let bezelHeight = height + 18

        return ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.08, blue: 0.1), Color(red: 0.18, green: 0.18, blue: 0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.6), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.65), lineWidth: 3)
                .padding(3)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.8))
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .padding(12)
                .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)

            Text(text)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
        }
        .frame(width: bezelWidth, height: bezelHeight)
    }
}

private struct WideStatusBanner: View {
    let text: String

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.88, green: 0.18, blue: 0.3), Color(red: 0.98, green: 0.54, blue: 0.26)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 8)
            .overlay(
                Text(text)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
            )
            .allowsHitTesting(false)
    }
}

private extension ContentView {
    func debugGridOverlay(size: CGSize, columns: Int, rows: Int) -> some View {
        let cellWidth = size.width / CGFloat(columns)
        let cellHeight = size.height / CGFloat(rows)

        return ZStack {
            Path { path in
                for column in 0...columns {
                    let x = CGFloat(column) * cellWidth
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }

                for row in 0...rows {
                    let y = CGFloat(row) * cellHeight
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
            }
            .stroke(Color.red.opacity(0.9), lineWidth: 1)

            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<columns, id: \.self) { column in
                    let index = row * columns + column + 1
                    Text("\(index)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.red.opacity(1.0))
                        .position(
                            x: CGFloat(column) * cellWidth + cellWidth / 2,
                            y: CGFloat(row) * cellHeight + cellHeight / 2
                        )
                }
            }
        }
    }
}

private struct NutFirstFretHighlight: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(Color.red.opacity(0.9), lineWidth: max(width * 0.004, 2))
            .shadow(color: Color.red.opacity(0.25), radius: 8, x: 0, y: 4)
            .frame(width: width, height: height)
            .allowsHitTesting(false)
    }
}

private struct BindingLayer: View {
    var body: some View {
        GeometryReader { geo in
            let stripWidth = max(geo.size.width * 0.02, 6)

            ZStack(alignment: .top) {
                HStack {
                    bindingStrip(width: stripWidth, height: geo.size.height)
                    Spacer()
                    bindingStrip(width: stripWidth, height: geo.size.height)
                }
                
                Rectangle()
                    .fill(Color(red: 0.65, green: 0.62, blue: 0.58))
                    .frame(width: geo.size.width - stripWidth * 2, height: 1)
                    .position(x: geo.size.width / 2, y: 0.5)
            }
        }
        .allowsHitTesting(false)
    }

    private func bindingStrip(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: width / 2)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.97, green: 0.95, blue: 0.88),
                        Color(red: 0.91, green: 0.87, blue: 0.78)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                VStack {
                    Color.white.opacity(0.35)
                        .frame(height: 1)
                    Spacer()
                }
            )
            .frame(width: width, height: height)
            .shadow(color: Color.black.opacity(0.25), radius: 4, x: 1, y: 0)
    }
}

private struct FretWireLayer: View {
    let fretRatios: [CGFloat]

    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let width = geo.size.width * 1.04
            let wireThickness = max(geo.size.height * 0.0018, 2)
            ZStack(alignment: .topLeading) {
                ForEach(1..<fretRatios.count, id: \.self) { index in
                    let ratio = fretRatios[index]
                    RoundedRectangle(cornerRadius: wireThickness / 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.96, green: 0.96, blue: 0.94),
                                    Color(red: 0.7, green: 0.72, blue: 0.75),
                                    Color(red: 0.45, green: 0.47, blue: 0.5),
                                    Color(red: 0.98, green: 0.98, blue: 0.99)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: wireThickness / 2)
                                .stroke(Color.black.opacity(0.3), lineWidth: 0.35)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: wireThickness / 2)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.8), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 0.7
                                )
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
                        .frame(width: width, height: wireThickness)
                        .offset(
                            x: -(width - geo.size.width) / 2,
                            y: ratio * height - wireThickness / 2
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct FretMarkerLayer: View {
    let fretRatios: [CGFloat]

    private let markedFrets: [Int] = [3, 5, 7, 9]

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let markerDiameter = max(min(width, height) * 0.135, 36)

            ZStack {
                ForEach(markedFrets, id: \.self) { fret in
                    if fretRatios.indices.contains(fret), fretRatios.indices.contains(fret - 1) {
                        let start = fretRatios[fret - 1]
                        let end = fretRatios[fret]
                        let yPosition = ((start + end) / 2) * height

                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.98),
                                        Color(red: 0.93, green: 0.93, blue: 0.9),
                                        Color(red: 0.72, green: 0.72, blue: 0.7)
                                    ],
                                    center: .center,
                                    startRadius: markerDiameter * 0.05,
                                    endRadius: markerDiameter * 0.6
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.18), lineWidth: 1)
                            )
                            .frame(width: markerDiameter, height: markerDiameter)
                            .position(x: width / 2, y: yPosition)
                            .shadow(color: Color.black.opacity(0.18), radius: 2, x: 0, y: 1)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct NutLayer: View {
    let width: CGFloat
    let height: CGFloat

    private let stratNutWidthInches: CGFloat = 1.650
    private let stratStringSpanInches: CGFloat = 1.362
    private let totalStrings: Int = 6

    var body: some View {
        GeometryReader { geo in
            let nutHeight = geo.size.height
            let bevelHeight = nutHeight * 0.25
            let widthPerInch = geo.size.width / stratNutWidthInches
            let interStringSpacing = (stratStringSpanInches / CGFloat(totalStrings - 1)) * widthPerInch
            let edgeMargin = ((stratNutWidthInches - stratStringSpanInches) / 2) * widthPerInch
            let grooveCenters = (0..<totalStrings).map { index in
                edgeMargin + CGFloat(index) * interStringSpacing
            }

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.98, green: 0.97, blue: 0.95),
                                Color(red: 0.92, green: 0.91, blue: 0.88)
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
                    .frame(height: nutHeight + bevelHeight)

                Rectangle()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: geo.size.width * 0.98, height: bevelHeight)
                    .offset(y: nutHeight * 0.15)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.4)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                let grooveWidth = max(1, geo.size.width * 0.01)
                let grooveHeight = bevelHeight * 1.4
                ForEach(0..<totalStrings, id: \.self) { index in
                    Rectangle()
                        .fill(Color.black.opacity(0.35))
                        .frame(width: grooveWidth, height: grooveHeight)
                        .cornerRadius(grooveWidth / 2)
                        .offset(
                            x: grooveCenters[index] - geo.size.width / 2,
                            y: nutHeight * 0.1
                        )
                }

                Rectangle()
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 1, height: nutHeight + bevelHeight * 0.6)
                    .offset(y: nutHeight * 0.2)
            }
        }
        .frame(width: width, height: height)
        .padding(.bottom, height * 0.05)
        .allowsHitTesting(false)
    }
}

private struct DarkMatteOverlay: View {
    let canvasSize: CGSize
    let highlightWidth: CGFloat
    let highlightHeight: CGFloat
    let highlightCenter: CGPoint
    let highlightCornerRadius: CGFloat

    var body: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Image("TweedSample")
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(x: 1.15, y: 1.25, anchor: .center)
                        .frame(width: canvasSize.width, height: canvasSize.height * 1.1)
                    Image("TweedSample")
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(x: 1.15, y: 1.25, anchor: .center)
                        .frame(width: canvasSize.width, height: canvasSize.height * 1.1)
                    Image("TweedSample")
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(x: 1.15, y: 1.25, anchor: .center)
                        .frame(width: canvasSize.width, height: canvasSize.height * 1.1)
                }
                .frame(width: canvasSize.width, height: canvasSize.height * 3.3, alignment: .bottom)
            }
            .frame(width: canvasSize.width, height: canvasSize.height, alignment: .bottom)
            .clipped()
            .overlay(
                Color.black.opacity(0.12)
                    .blendMode(.multiply)
            )
            .overlay(
                LinearGradient(
                    colors: [Color.white.opacity(0.08), Color.clear, Color.black.opacity(0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            RoundedRectangle(cornerRadius: highlightCornerRadius, style: .continuous)
                .fill(Color.black)
                .frame(width: highlightWidth, height: highlightHeight)
                .position(x: highlightCenter.x, y: highlightCenter.y)
                .blendMode(.destinationOut)
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .compositingGroup()
        .allowsHitTesting(false)
    }
}

private struct ProjectLinebackerOverlay: View {
    let fretRatios: [CGFloat]
    let neckHeight: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let neckWidth = geometry.size.width
            let bindingInset = max(neckWidth * 0.02, 6)
            let lineWidth = neckWidth - (bindingInset * 2)
            
            ForEach(1..<fretRatios.count, id: \.self) { index in
                let currentRatio = fretRatios[index]
                let previousRatio = fretRatios[index - 1]
                let midpointRatio = (currentRatio + previousRatio) / 2.0
                let yPosition = midpointRatio * neckHeight
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: lineWidth, height: 3)
                    .position(x: neckWidth / 2, y: yPosition)
                    .allowsHitTesting(false)
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ContentView()
}

