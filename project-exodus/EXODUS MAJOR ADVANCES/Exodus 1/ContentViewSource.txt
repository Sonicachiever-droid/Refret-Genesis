import SwiftUI

#if DEBUG
private func logAlignmentDelta(_ delta: CGFloat) {
    if abs(delta) > 0.5 {
        print("[Project Genesis] Blue/green misalignment: \(delta)")
    }
}

// Thumb button glow states
private enum ThumbGlowState: CaseIterable {
    case neutral
    case green
    case red
}

// LED-style thumb button matching the exhibit styling
private struct ThumbButtonView: View {
    let diameter: CGFloat
    let label: String
    let state: ThumbGlowState

    private var glowStops: [Gradient.Stop] {
        switch state {
        case .neutral:
            return [
                .init(color: Color(white: 1.0, opacity: 1.0), location: 0.0),
                .init(color: Color(white: 1.0, opacity: 1.0), location: 0.12),
                .init(color: Color(red: 1.0, green: 0.96, blue: 0.70), location: 0.34),
                .init(color: Color(red: 1.0, green: 0.78, blue: 0.12), location: 0.54),
                .init(color: Color(red: 0.28, green: 0.12, blue: 0.00), location: 1.0)
            ]
        case .green:
            return [
                .init(color: Color(white: 1.0, opacity: 1.0), location: 0.0),
                .init(color: Color(white: 1.0, opacity: 1.0), location: 0.12),
                .init(color: Color(red: 0.66, green: 1.0, blue: 0.72), location: 0.34),
                .init(color: Color(red: 0.12, green: 0.84, blue: 0.22), location: 0.54),
                .init(color: Color(red: 0.0, green: 0.32, blue: 0.08), location: 1.0)
            ]
        case .red:
            return [
                .init(color: Color(white: 1.0, opacity: 1.0), location: 0.0),
                .init(color: Color(white: 1.0, opacity: 1.0), location: 0.12),
                .init(color: Color(red: 1.0, green: 0.58, blue: 0.46), location: 0.34),
                .init(color: Color(red: 0.82, green: 0.14, blue: 0.07), location: 0.54),
                .init(color: Color(red: 0.34, green: 0.01, blue: 0.01), location: 1.0)
            ]
        }
    }

    var body: some View {
        let bezel = diameter
        let ringOuter = diameter * 0.84
        let ringInner = diameter * 0.78
        let plunger = diameter * 0.50
        let screwOrbit = diameter * 0.39
        let screwSize = max(diameter * 0.085, 7)

        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.34, green: 0.28, blue: 0.15),
                                Color(red: 0.73, green: 0.60, blue: 0.34),
                                Color(red: 0.42, green: 0.33, blue: 0.18),
                                Color(red: 0.25, green: 0.20, blue: 0.11)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.45), Color.black.opacity(0.45)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.4
                            )
                    )
                    .shadow(color: .black.opacity(0.45), radius: 8, x: 0, y: 4)
                    .frame(width: bezel, height: bezel)

                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: ringMetalStops),
                            center: .center
                        ),
                        lineWidth: max(diameter * 0.085, 6)
                    )
                    .frame(width: ringOuter, height: ringOuter)

                Circle()
                    .stroke(
                        RadialGradient(
                            gradient: Gradient(stops: glowStops),
                            center: .center,
                            startRadius: ringInner * 0.02,
                            endRadius: ringInner * 0.65
                        )
                        .opacity(1.0),
                        lineWidth: max(diameter * 0.165, 12)
                    )
                    .frame(width: ringInner, height: ringInner)
                    .shadow(color: .white.opacity(0.62), radius: 6)
                    .shadow(color: ringShadowColor.opacity(0.95), radius: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.75), lineWidth: max(diameter * 0.02, 1.6))
                            .frame(width: ringInner * 0.88, height: ringInner * 0.88)
                            .blur(radius: 0.25)
                    )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.79, green: 0.66, blue: 0.40),
                                Color(red: 0.56, green: 0.44, blue: 0.24),
                                Color(red: 0.35, green: 0.27, blue: 0.14)
                            ],
                            center: UnitPoint(x: 0.35, y: 0.3),
                            startRadius: plunger * 0.03,
                            endRadius: plunger * 0.55
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.40), Color.black.opacity(0.35)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.22))
                            .frame(width: plunger * 0.23, height: plunger * 0.16)
                            .offset(x: -plunger * 0.16, y: -plunger * 0.14)
                            .blur(radius: 0.3)
                    )
                    .frame(width: plunger, height: plunger)

                ForEach(0..<4, id: \.self) { index in
                    let angle = Angle.degrees(Double(index) * 90 + 45)
                    ScrewHeadView(size: screwSize)
                        .offset(
                            x: cos(angle.radians) * screwOrbit,
                            y: sin(angle.radians) * screwOrbit
                        )
                }
            }

            Text(label.uppercased())
                .font(.system(size: max(diameter * 0.16, 10), weight: .semibold))
                .fontWidth(.condensed)
                .kerning(0.9)
                .foregroundColor(.white)
        }
    }

    private var ringShadowColor: Color {
        switch state {
        case .neutral: return Color(red: 1.0, green: 0.62, blue: 0.05)
        case .green: return Color(red: 0.2, green: 0.9, blue: 0.3)
        case .red: return Color(red: 1.0, green: 0.2, blue: 0.1)
        }
    }

    private var ringMetalStops: [Color] {
        [
            Color(red: 0.77, green: 0.64, blue: 0.36),
            Color(red: 0.52, green: 0.40, blue: 0.22),
            Color(red: 0.84, green: 0.73, blue: 0.48),
            Color(red: 0.46, green: 0.36, blue: 0.20),
            Color(red: 0.77, green: 0.64, blue: 0.36)
        ]
    }
}

private struct ScrewHeadView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.72, green: 0.63, blue: 0.44),
                            Color(red: 0.38, green: 0.31, blue: 0.18)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: size * 0.05,
                        endRadius: size * 0.7
                    )
                )
            Circle()
                .stroke(Color.black.opacity(0.35), lineWidth: 0.6)
            Rectangle()
                .fill(Color.black.opacity(0.45))
                .frame(width: size * 0.55, height: 0.8)
                .rotationEffect(.degrees(-12))
        }
        .frame(width: size, height: size)
    }
}

private func logNutBaselineDelta(_ delta: CGFloat) {
    if abs(delta) > 0.5 {
        print("[Project Genesis] Nut baseline delta: \(delta)")
    }
}

private func logAlignmentDiagnostics(
    neckTopY: CGFloat,
    activeMidpoint: CGFloat,
    highlightCenterY: CGFloat,
    highlightTopGridLineY: CGFloat,
    gridRowHeight: CGFloat
) {
    let blueMidpointY = neckTopY + activeMidpoint
    let greenBisectorY = highlightCenterY
    let nutBottomRowY = highlightTopGridLineY + 2 * gridRowHeight
    logAlignmentDelta(blueMidpointY - greenBisectorY)
    logNutBaselineDelta(neckTopY - nutBottomRowY)
}
#endif

private struct MarshallElephantOverlay: View {
    let canvasSize: CGSize
    let highlightWidth: CGFloat
    let highlightHeight: CGFloat
    let highlightCenter: CGPoint
    let highlightCornerRadius: CGFloat

    var body: some View {
        let bleed: CGFloat = 36

        Image("MARSHALL ELEPHANT")
            .resizable()
            .scaledToFill()
            .frame(width: canvasSize.width + (bleed * 2), height: canvasSize.height + (bleed * 2))
            .scaleEffect(1.2, anchor: .center)
            .brightness(0.12)
            .saturation(1.05)
            .overlay(Color.black.opacity(0.2))
            .offset(x: -bleed, y: -bleed)
        .frame(width: canvasSize.width, height: canvasSize.height)
        .clipped()
        .mask(maskShape)
        .frame(width: canvasSize.width, height: canvasSize.height)
    }

    private var maskShape: some View {
        Rectangle()
            .frame(width: canvasSize.width, height: canvasSize.height)
            .overlay {
                HighlightWindowShape(cornerRadius: highlightCornerRadius)
                    .frame(width: highlightWidth, height: highlightHeight)
                    .position(x: highlightCenter.x, y: highlightCenter.y)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
    }
}

// NEW: This view locks the hole in the elephant tolex and the gold border together forever
private struct GreenBisectorLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.green)
            .frame(height: 2)
    }
}

private struct ElephantWindowView: View {
    let canvasSize: CGSize
    let highlightWidth: CGFloat
    let highlightHeight: CGFloat
    let highlightCenter: CGPoint
    let highlightCornerRadius: CGFloat

    var body: some View {
        ZStack {
            // Elephant with the hole cut out
            MarshallElephantOverlay(
                canvasSize: canvasSize,
                highlightWidth: highlightWidth,
                highlightHeight: highlightHeight,
                highlightCenter: highlightCenter,
                highlightCornerRadius: highlightCornerRadius
            )
            
            // Gold border drawn in the exact same position as the hole
            HighlightWindowGoldBorder(
                width: highlightWidth,
                height: highlightHeight,
                cornerRadius: highlightCornerRadius
            )
            .position(x: highlightCenter.x, y: highlightCenter.y)
        }
    }
}

private struct GoldPipingBorder: View {
    let bottomInset: CGFloat

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .inset(by: 1.75)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.82, blue: 0.47),
                            Color(red: 0.78, green: 0.6, blue: 0.22),
                            Color(red: 0.97, green: 0.85, blue: 0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3.5
                )
                .shadow(color: Color.black.opacity(0.45), radius: 12, x: 0, y: 8)

            ContainerRelativeShape()
                .inset(by: 3.5)
                .stroke(Color.black.opacity(0.6), lineWidth: 1.5)
        }
        .padding(.bottom, bottomInset)
        .ignoresSafeArea()
    }
}

private struct DeveloperCodeRunnerView: View {
    @State private var startDate: Date = .now

    private struct RenderState {
        let renderedLines: [String]
        let lineHeight: CGFloat
        let offsetY: CGFloat
    }

    private static let sourceText: String = {
        if let text = try? String(contentsOfFile: #filePath, encoding: .utf8), !text.isEmpty {
            return text
        }
        return "import SwiftUI\nstruct ContentView: View {\n    var body: some View {\n        Text(\"Loading Source\")\n    }\n}"
    }()

    private let lines: [String] = {
        let split = sourceText.components(separatedBy: .newlines)
        return split.isEmpty ? ["// source unavailable"] : split
    }()

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 0.03)) { context in
                let elapsed = context.date.timeIntervalSince(startDate)
                let state = makeRenderState(elapsed: elapsed, viewportHeight: geo.size.height)

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(state.renderedLines.enumerated()), id: \.offset) { index, line in
                        Text(line)
                            .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                            .foregroundStyle(color(for: index))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, minHeight: state.lineHeight, maxHeight: state.lineHeight, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(y: state.offsetY)
                .clipped()
            }
        }
    }

    private func makeRenderState(elapsed: TimeInterval, viewportHeight: CGFloat) -> RenderState {
        let charsPerSecond: Double = 42
        let postLineHold: Double = 0.12
        let lineHeight: CGFloat = 14

        let lineDurations = lines.map { max(Double($0.count) / charsPerSecond, 0.02) + postLineHold }
        let typingDuration = lineDurations.reduce(0, +)
        let loopPause: Double = 0.9
        let cycleDuration = max(typingDuration + loopPause, 0.1)
        let cycleElapsed = elapsed.truncatingRemainder(dividingBy: cycleDuration)

        let cumulativeDurations: [Double] = lineDurations.reduce(into: []) { partial, duration in
            partial.append((partial.last ?? 0) + duration)
        }

        let activeLine: Int = {
            if cycleElapsed >= typingDuration {
                return max(lines.count - 1, 0)
            }
            return cumulativeDurations.firstIndex(where: { cycleElapsed <= $0 }) ?? max(lines.count - 1, 0)
        }()

        let elapsedIntoLine: Double = {
            if cycleElapsed >= typingDuration {
                return lineDurations.last ?? 0
            }
            let previousTotal = activeLine > 0 ? cumulativeDurations[activeLine - 1] : 0
            return max(cycleElapsed - previousTotal, 0)
        }()

        let currentLineDuration = lineDurations.isEmpty ? 1 : lineDurations[activeLine]
        let typingWindow = max(currentLineDuration - postLineHold, 0.02)
        let typedChars = min(
            Int(max(elapsedIntoLine, 0) * charsPerSecond),
            lines[activeLine].count
        )

        var renderedLines: [String] = []
        if activeLine > 0 {
            renderedLines.append(contentsOf: lines.prefix(activeLine))
        }
        let activeText = String(lines[activeLine].prefix(max(typedChars, 0)))
        let showCursor = cycleElapsed < typingDuration && elapsedIntoLine <= typingWindow
        renderedLines.append(activeText + (showCursor ? "▋" : ""))

        let typedProgress = min(max((elapsedIntoLine / currentLineDuration), 0), 1)
        let contentOffset = (CGFloat(activeLine) + CGFloat(typedProgress)) * lineHeight
        let baselineY = viewportHeight - lineHeight

        return RenderState(
            renderedLines: renderedLines,
            lineHeight: lineHeight,
            offsetY: baselineY - contentOffset
        )
    }

    private func color(for index: Int) -> Color {
        let palette: [Color] = [.orange, .cyan, .mint, .pink, .yellow, .green]
        return palette[index % palette.count].opacity(0.95)
    }
}

private struct DeveloperConsoleFrame: View {
    let width: CGFloat
    let height: CGFloat
    let isScreensaverMode: Bool
    let roundTitle: String
    let fretTitle: String
    let stringTitle: String
    let bankText: String

    var body: some View {
        ZStack {
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

            VStack(spacing: 0) {
                HStack(spacing: 7) {
                    Circle().fill(Color(red: 1.0, green: 0.37, blue: 0.33)).frame(width: 8, height: 8)
                    Circle().fill(Color(red: 1.0, green: 0.75, blue: 0.21)).frame(width: 8, height: 8)
                    Circle().fill(Color(red: 0.16, green: 0.82, blue: 0.31)).frame(width: 8, height: 8)
                    Spacer()
                    Text("ContentView.swift")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.55))
                    Spacer()
                }
                .padding(.horizontal, 10)
                .frame(height: 16)
                .background(Color.white.opacity(0.035))

                Spacer(minLength: 0)
            }

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.65), lineWidth: 3)
                .padding(3)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.82, blue: 0.47),
                            Color(red: 0.78, green: 0.6, blue: 0.22),
                            Color(red: 0.97, green: 0.85, blue: 0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .padding(1.5)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.96), Color(red: 0.07, green: 0.07, blue: 0.08), Color.black.opacity(0.96)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(8)
                .overlay {
                    Group {
                        if isScreensaverMode {
                            DeveloperCodeRunnerView()
                                .padding(.horizontal, 10)
                                .padding(.top, 24)
                                .padding(.bottom, 8)
                        } else {
                            VStack(alignment: .center, spacing: 4) {
                                Text(roundTitle)
                                    .font(.system(size: 15, weight: .black, design: .monospaced))
                                    .foregroundStyle(Color.cyan.opacity(0.95))
                                Text(fretTitle)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color.orange.opacity(0.95))
                                Text(stringTitle)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color.yellow.opacity(0.95))
                                Text("BANK \(bankText)")
                                    .font(.system(size: 16, weight: .black, design: .monospaced))
                                    .foregroundStyle(Color.green.opacity(0.95))
                            }
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 14)
                            .padding(.top, 22)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                    }
                }
        }
        .frame(width: width, height: height)
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct HighlightWindowGoldBorder: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        HighlightWindowShape(cornerRadius: cornerRadius)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.82, blue: 0.47),
                        Color(red: 0.78, green: 0.6, blue: 0.22),
                        Color(red: 0.97, green: 0.85, blue: 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 4
            )
            .frame(width: width, height: height)
    }
}

private struct HighlightWindowShape: InsettableShape {
    let cornerRadius: CGFloat
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let radius = max(cornerRadius - insetAmount, 0)
        return RoundedRectangle(cornerRadius: radius, style: .continuous).path(in: insetRect)
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
}

private struct WhiteNoteBoxOverlay: View {
    let centerY: CGFloat
    let availableSize: CGSize
    let boxHeight: CGFloat
    let neckWidth: CGFloat
    let activeStringNumber: Int?
    let answerFeedback: ThumbGlowState?
    let currentQuestionIsAccidental: Bool

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
        let boxWidth = min(clampedBoxHeight * 1.8, maxBoxWidthFromSpacing)

        return ZStack {
            ForEach(0..<totalStrings, id: \.self) { index in
                let stringNumber = totalStrings - index
                let isActive = stringNumber == activeStringNumber
                let fillColor: Color = {
                    guard isActive else { return .clear }
                    switch answerFeedback {
                    case .green: return Color(red: 0.64, green: 0.98, blue: 0.70).opacity(0.95)
                    case .red: return Color(red: 1.0, green: 0.62, blue: 0.58).opacity(0.95)
                    default: return currentQuestionIsAccidental ? Color.black.opacity(0.95) : Color.white.opacity(0.92)
                    }
                }()
                let strokeColor: Color = {
                    guard isActive else { return .clear }
                    switch answerFeedback {
                    case .green: return Color(red: 0.04, green: 0.42, blue: 0.12).opacity(0.9)
                    case .red: return Color(red: 0.48, green: 0.06, blue: 0.06).opacity(0.9)
                    default: return currentQuestionIsAccidental ? Color.white.opacity(0.86) : Color.black.opacity(0.72)
                    }
                }()
                let auraColor: Color = {
                    guard isActive else { return .clear }
                    switch answerFeedback {
                    case .green: return Color(red: 0.38, green: 0.92, blue: 0.45).opacity(0.35)
                    case .red: return Color(red: 0.92, green: 0.28, blue: 0.20).opacity(0.35)
                    default: return currentQuestionIsAccidental ? Color.black.opacity(0.22) : Color.white.opacity(0.38)
                    }
                }()
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(strokeColor, lineWidth: 2)
                    )
                    .shadow(color: auraColor, radius: 4)
                    .shadow(color: auraColor.opacity(0.55), radius: 8)
                    .frame(width: boxWidth, height: clampedBoxHeight)
                    .position(x: grooveCenters[index], y: centerY)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: activeStringNumber)
        .animation(.easeInOut(duration: 0.18), value: answerFeedback)
    }
}

private struct MiniTVFrame: View {
    let text: String
    let width: CGFloat
    let height: CGFloat
    let fontScale: CGFloat
    let isDarkScreen: Bool

    init(text: String, width: CGFloat, height: CGFloat, fontScale: CGFloat, isDarkScreen: Bool = false) {
        self.text = text
        self.width = width
        self.height = height
        self.fontScale = fontScale
        self.isDarkScreen = isDarkScreen
    }

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

            Group {
                if isDarkScreen {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.95),
                                    Color(red: 0.07, green: 0.07, blue: 0.08),
                                    Color.black.opacity(0.95)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .padding(8)
                        .shadow(color: Color.black.opacity(0.55), radius: 12)
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(white: 1.0, opacity: 0.85), location: 0.0),
                                    .init(color: Color(red: 1.0, green: 0.96, blue: 0.70), location: 0.08),
                                    .init(color: Color(red: 1.0, green: 0.78, blue: 0.12), location: 0.28),
                                    .init(color: Color(red: 1.0, green: 0.56, blue: 0.00), location: 0.40),
                                    .init(color: Color(red: 0.28, green: 0.12, blue: 0.00), location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 2,
                                endRadius: 130
                            )
                        )
                        .padding(8)
                        .overlay(EmptyView())
                        .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.0).opacity(0.35), radius: 14)
                        .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.0).opacity(0.20), radius: 28)
                }
            }

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.clear)
                .padding(12)
                .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)

            Text(text.uppercased())
                .font(.system(size: max(height * 0.78 * fontScale, 14), weight: .black, design: .default))
                .fontWidth(.condensed)
                .kerning(0.9)
                .allowsTightening(true)
                .foregroundColor(.black)
                .minimumScaleFactor(0.45)
                .padding(.horizontal, 12)
        }
        .frame(width: bezelWidth, height: bezelHeight)
        .allowsHitTesting(false)
    }
}

private struct RowOneIdentifierOverlay: View {
    let leftLabel: String
    let rightLabel: String
    let size: CGSize
    let rowHeight: CGFloat

    var body: some View {
        let bannerFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        let measuredWidth = max(
            textWidth(for: leftLabel, font: bannerFont),
            textWidth(for: rightLabel, font: bannerFont),
            textWidth(for: "Open Strings", font: bannerFont)
        )
        let bannerWidth = measuredWidth + 32
        let bannerHeight = max(min(rowHeight * 0.66, 50), 40)

        return HStack(spacing: 16) {
            MiniTVFrame(text: leftLabel, width: bannerWidth, height: bannerHeight, fontScale: 0.82)
            MiniTVFrame(text: rightLabel, width: bannerWidth, height: bannerHeight, fontScale: 0.82)
        }
        .frame(width: size.width, height: rowHeight)
        .position(x: size.width / 2, y: rowHeight / 2)
        .allowsHitTesting(false)
    }

    private func textWidth(for text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return ceil(text.size(withAttributes: attributes).width)
    }
}

private struct StringLineOverlay: View {
    let neckWidth: CGFloat
    let horizontalPadding: CGFloat
    let stringTopY: CGFloat
    private let totalStrings: Int = 6
    private let stratNutWidthInches: CGFloat = 1.650
    private let stratStringSpanInches: CGFloat = 1.362

    var body: some View {
        GeometryReader { geo in
            let clippedTopY = min(max(stringTopY, 0), geo.size.height)
            let clippedHeight = max(geo.size.height - clippedTopY, 0)
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
                            stringHeight: clippedHeight,
                            stringTopY: clippedTopY,
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
                            .frame(width: 1.5, height: clippedHeight)
                            .position(x: stringX, y: clippedTopY + clippedHeight / 2)
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
    let stringTopY: CGFloat
    let stringNumber: Int
    
    private var stringThickness: CGFloat {
        switch stringNumber {
        case 6: return 4.0
        case 5: return 3.5
        case 4: return 3.0
        default: return 2.5
        }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: stringThickness / 2, style: .continuous)
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
                RoundedRectangle(cornerRadius: stringThickness / 2)
                    .stroke(Color.black.opacity(0.2), lineWidth: 0.3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: stringThickness / 2)
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
            .frame(width: stringThickness, height: max(stringHeight, 2))
            .position(x: stringX, y: stringTopY + stringHeight / 2)
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

private enum FretMath {
    static func fretPositionRatios(totalFrets: Int, scaleLength: Double) -> [CGFloat] {
        guard totalFrets > 0, scaleLength > 0 else { return [] }
        return (0...totalFrets).map { fret in
            let distance = scaleLength - scaleLength / pow(2.0, Double(fret) / 12.0)
            return CGFloat(distance / scaleLength)
        }
    }

    static func offsetRatio(for fretStart: Int, fretRatios: [CGFloat]) -> CGFloat {
        guard !fretRatios.isEmpty else { return 0 }
        let clampedIndex = min(max(fretStart, 0), fretRatios.count - 1)
        return fretRatios[clampedIndex]
    }

    static func distanceRatio(for fretPosition: CGFloat, scaleLength: Double) -> CGFloat {
        guard scaleLength > 0 else { return 0 }
        let semitoneRatio = pow(2.0, Double(fretPosition) / 12.0)
        let distance = scaleLength - scaleLength / semitoneRatio
        return CGFloat(distance / scaleLength)
    }
}

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

private enum AnswerSide {
    case left
    case right
}

struct ContentView: View {
    @Environment(\.displayScale) private var displayScale
    private let totalFrets: Int = 20
    private var maxFretOffset: Int { totalFrets }
    private var minFretOffset: Int { -totalFrets }
    private let gameStringOrder: [Int] = [1, 2, 3, 4, 5, 6]
    private let chromaticSharps: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let chromaticFlats: [String] = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
    private let openNoteByString: [Int: String] = [
        6: "E",
        5: "A",
        4: "D",
        3: "G",
        2: "B",
        1: "E"
    ]
    private let codenameNemoEnabled: Bool = false
    private let scaleLengthInches: Double = 25.5
    private let debugGridRows: Int = 8
    private var maxWindowRow: Int { (debugGridRows - 1) * 2 } // half-step increments across rows
    @State private var currentFretStart: Int = 0
    @State private var currentWindowRow: Int = 2
    @State private var leftThumbState: ThumbGlowState = .neutral
    @State private var rightThumbState: ThumbGlowState = .neutral
    @State private var currentRound: Int = 0
    @State private var roundStringIndex: Int = 0
    @State private var isDescendingPhase: Bool = false
    @State private var leftChoiceNote: String = ""
    @State private var rightChoiceNote: String = ""
    @State private var correctAnswerSide: AnswerSide = .left
    @State private var isResolvingAnswer: Bool = false
    @State private var activePickedStringNumber: Int? = nil
    @State private var activeAnswerFeedback: ThumbGlowState? = nil
    @State private var currentQuestionIsAccidental: Bool = false
    @State private var introWindowBlack: Bool = true
    @State private var introDidRun: Bool = false
    @State private var isCodeScreensaverMode: Bool = true
    @State private var bankDollars: Int = 0
    @State private var displayedBankDollars: Int = 0
    @State private var roundAnnouncement: String = "1"
    @State private var assetToNutBottomDelta: CGFloat? = nil

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
            let developerBoxWidth = proxy.size.width / CGFloat(debugGridColumns)
            let gridRowHeight = proxy.size.height / CGFloat(debugGridRows)
            let globalContentShiftY = gridRowHeight * 0.25
            let rowOneBottomLineY = gridRowHeight
            let highlightHeight = 2 * gridRowHeight
            let lockedWindowTopRowIndex: CGFloat = 1.0
            let highlightTopGridLineY = lockedWindowTopRowIndex * gridRowHeight
            
            let scale = displayScale
            
            let highlightCenterYSnapped: CGFloat = {
                let raw = highlightTopGridLineY + highlightHeight / 2
                return (raw * scale).rounded() / scale
            }()
            let viewingWindowShiftY: CGFloat = gridRowHeight * 0.5
            let viewingWindowCenterY = highlightCenterYSnapped + viewingWindowShiftY

            let pipingCenterY = viewingWindowCenterY
            let orangeGreenUnitCenterY = pipingCenterY - (gridRowHeight * 0.5)
            let holeCenterY = highlightCenterYSnapped
            let highlightAvailableWidth = max(proxy.size.width - padding * 2, 0)
            let highlightExtraWidth = max(highlightAvailableWidth - neckWidth, 0)
            let highlightWidth = neckWidth + highlightExtraWidth / 2
            let highlightCornerRadius = min(24, highlightWidth * 0.08)
            let currentTargetString = gameStringOrder[min(max(roundStringIndex, 0), gameStringOrder.count - 1)]
            let fretStatusLabel = currentRound == 0 ? "OPEN" : "FRET \(currentRound)"
            let stringStatusLabel = "STRING \(currentTargetString)"
            let roundStatusLabel = "ROUND \(currentRound + 1)"
            let screenBannerFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
            let screenMeasuredWidth = max(
                textWidth(for: fretStatusLabel, font: screenBannerFont),
                textWidth(for: stringStatusLabel, font: screenBannerFont),
                textWidth(for: "STRING 6", font: screenBannerFont)
            )
            let screenBannerWidth = screenMeasuredWidth + 32
            let screenBannerHeight = max(min(gridRowHeight * 0.72, 52), 44)
            let lowerScreenWidth = screenBannerWidth * 0.5
            let lowerScreenHeight = screenBannerHeight
            let thumbDiameter = min(proxy.size.width, proxy.size.height) * 0.336
            let virtualRows: CGFloat = 40
            let vRowH: CGFloat = proxy.size.height / virtualRows
            let buttonCenterY: CGFloat = (28 - 0.5) * vRowH
            let screenPairSpacing: CGFloat = 16
            let buttonPairSpacing: CGFloat = 28
            let windowBottomY = holeCenterY + highlightHeight / 2
            let topScreenY = windowBottomY + screenBannerHeight * 0.72
            let leftScreenCenterX = (proxy.size.width / 2) - (screenBannerWidth / 2) - (screenPairSpacing / 2)
            let rightScreenCenterX = (proxy.size.width / 2) + (screenBannerWidth / 2) + (screenPairSpacing / 2)
            let halfButtonCenterGap = (thumbDiameter + buttonPairSpacing) / 2
            let leftButtonCenterX = (proxy.size.width / 2) - halfButtonCenterGap
            let rightButtonCenterX = (proxy.size.width / 2) + halfButtonCenterGap
            let leftAnswerCenterX = (leftScreenCenterX + leftButtonCenterX) / 2
            let rightAnswerCenterX = (rightScreenCenterX + rightButtonCenterX) / 2
            let buttonTopY = buttonCenterY - (thumbDiameter / 2)
            let noteChoiceY = min(
                topScreenY + ((buttonCenterY - topScreenY) * 0.58),
                buttonTopY - (lowerScreenHeight * 0.65)
            ) - (gridRowHeight * 0.5)
            let developerOverlaysEnabled: Bool = false
            let windowTopY = holeCenterY - highlightHeight / 2
            let topStatusOuterWidth = highlightWidth
            let topStatusOuterHeight = max(min(gridRowHeight * 1.35, 120), 74)
            let topStatusBottomGap = max(gridRowHeight * 0.18, 10)
            let topStatusCenterY = (windowTopY - topStatusBottomGap) - (topStatusOuterHeight / 2)

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
            
            let neckOffsetY: CGFloat = {
                if currentFretStart == 0 {
                    let raw = neckTopY - proxy.size.height / 2 + neckHeight / 2
                    return (raw * scale).rounded() / scale
                } else {
                    let raw = pipingCenterY - activeMidpoint - proxy.size.height / 2 + neckHeight / 2
                    return (raw * scale).rounded() / scale
                }
            }()
            
            let manualBlueAdjustment: CGFloat = -gridRowHeight * 0.5
            let finalNeckOffsetY = neckOffsetY + manualBlueAdjustment
            let neckVisualOffsetAdjustment = finalNeckOffsetY - neckOffsetY
            let nutBottomY = neckTopY + neckVisualOffsetAdjustment + (nutVisualHeight * 0.15)
            let stringStopInset = max(1.0, 2.0 / max(scale, 1.0))
            let stringTopY = nutBottomY + stringStopInset
            let calibratedAssetToNutDelta = assetToNutBottomDelta ?? 0
            let linkedAssetYOffset = (nutBottomY + calibratedAssetToNutDelta) - rowOneBottomLineY

#if DEBUG
            let _ = { () -> Void in
                logAlignmentDiagnostics(
                    neckTopY: neckTopY,
                    activeMidpoint: activeMidpoint,
                    highlightCenterY: pipingCenterY,
                    highlightTopGridLineY: highlightTopGridLineY,
                    gridRowHeight: gridRowHeight
                )
            }()
#endif

            ZStack {
                Color.black
                    .ignoresSafeArea()

                Image("ABETWOSET")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(x: 12.7775, y: 10.3194, anchor: .bottom)
                    .frame(width: proxy.size.width, height: rowOneBottomLineY, alignment: .bottom)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                    .offset(x: developerBoxWidth * 0.15, y: linkedAssetYOffset)
                    .allowsHitTesting(false)

                HStack {
                    Spacer()
                    ZStack {
                        ZStack(alignment: .top) {
                            ZStack {
                                RosewoodSegmentedBackground(
                                    fretRatios: fretRatios,
                                    cornerRadius: 18
                                )
                                BindingLayer()
                                FretWireLayer(fretRatios: fretRatios)
                                FretMarkerLayer(fretRatios: fretRatios)
                            }
                            .frame(width: neckWidth, height: neckHeight)
                            .overlay {
                                ProjectLinebackerOverlay(fretRatios: fretRatios, neckHeight: neckHeight)
                                    .opacity(1)
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
                    horizontalPadding: padding,
                    stringTopY: stringTopY
                )

                RoundedRectangle(cornerRadius: highlightCornerRadius, style: .continuous)
                    .fill(Color.black)
                    .frame(width: highlightWidth, height: highlightHeight)
                    .position(x: proxy.size.width / 2, y: pipingCenterY)
                    .allowsHitTesting(false)
                    .opacity(introWindowBlack ? 1 : 0)

                HighlightWindowGoldBorder(
                    width: highlightWidth,
                    height: highlightHeight,
                    cornerRadius: highlightCornerRadius
                )
                .position(x: proxy.size.width / 2, y: orangeGreenUnitCenterY)
                .allowsHitTesting(false)

                WhiteNoteBoxOverlay(
                    centerY: orangeGreenUnitCenterY,
                    availableSize: proxy.size,
                    boxHeight: gridRowHeight * 0.9,
                    neckWidth: neckWidth,
                    activeStringNumber: activePickedStringNumber,
                    answerFeedback: activeAnswerFeedback,
                    currentQuestionIsAccidental: currentQuestionIsAccidental
                )
                .allowsHitTesting(false)
                .opacity(codenameNemoEnabled ? 0 : 1)

                GreenBisectorLine()
                    .frame(width: highlightWidth)
                    .position(x: proxy.size.width / 2, y: orangeGreenUnitCenterY)
                    .allowsHitTesting(false)
                    .opacity(1)

#if DEBUG
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(x: proxy.size.width / 2, y: holeCenterY)
                    .allowsHitTesting(false)
                    .opacity(0)
#endif

                DeveloperConsoleFrame(
                    width: topStatusOuterWidth,
                    height: topStatusOuterHeight,
                    isScreensaverMode: isCodeScreensaverMode,
                    roundTitle: roundStatusLabel,
                    fretTitle: fretStatusLabel,
                    stringTitle: stringStatusLabel,
                    bankText: "$\(displayedBankDollars)"
                )
                .position(x: proxy.size.width / 2, y: topStatusCenterY)
                .allowsHitTesting(false)
                .opacity(codenameNemoEnabled ? 0 : 1)

                HStack(spacing: screenPairSpacing) {
                    MiniTVFrame(text: fretStatusLabel, width: screenBannerWidth, height: screenBannerHeight, fontScale: 0.82)
                    MiniTVFrame(text: stringStatusLabel, width: screenBannerWidth, height: screenBannerHeight, fontScale: 0.82)
                }
                .frame(width: proxy.size.width, height: screenBannerHeight)
                .position(x: proxy.size.width / 2, y: topScreenY)
                .allowsHitTesting(false)
                .opacity(codenameNemoEnabled ? 0 : 1)

                MiniTVFrame(text: leftChoiceNote, width: lowerScreenWidth, height: lowerScreenHeight, fontScale: 1.0)
                    .position(x: leftAnswerCenterX, y: noteChoiceY)
                    .allowsHitTesting(false)
                    .opacity(codenameNemoEnabled ? 0 : 1)

                MiniTVFrame(text: rightChoiceNote, width: lowerScreenWidth, height: lowerScreenHeight, fontScale: 1.0)
                    .position(x: rightAnswerCenterX, y: noteChoiceY)
                .allowsHitTesting(false)
                .opacity(codenameNemoEnabled ? 0 : 1)

            }
            .overlay {
                debugGridOverlay(size: proxy.size, columns: debugGridColumns, rows: debugGridRows)
                    .allowsHitTesting(false)
                    .opacity(developerOverlaysEnabled ? 0.8 : 0)
            }
            .overlay(alignment: .bottomTrailing) {
                DeveloperButtonStack(
                    windowShiftUp: {},
                    windowShiftDown: {},
                    neckShiftUp: { shiftFretSpan(by: 1) },
                    neckShiftDown: { shiftFretSpan(by: -1) },
                    canWindowShiftUp: false,
                    canWindowShiftDown: false,
                    canNeckShiftUp: currentFretStart < maxFretOffset,
                    canNeckShiftDown: currentFretStart > minFretOffset
                )
                .padding(.trailing, 24)
                .padding(.bottom, max(proxy.size.height * 0.05, 16))
                .opacity(1)
                .allowsHitTesting(true)
                .zIndex(999)
            }
            .overlay(alignment: .topLeading) {
                HStack(spacing: 28) {
                    Button(action: { submitAnswer(.left) }) {
                        ThumbButtonView(
                            diameter: thumbDiameter,
                            label: "",
                            state: leftThumbState
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isResolvingAnswer)

                    Button(action: { submitAnswer(.right) }) {
                        ThumbButtonView(
                            diameter: thumbDiameter,
                            label: "",
                            state: rightThumbState
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isResolvingAnswer)
                }
                .frame(maxWidth: .infinity)
                .position(x: proxy.size.width / 2, y: buttonCenterY)
                .opacity(codenameNemoEnabled ? 0 : 1)
            }
            .onAppear {
                if assetToNutBottomDelta == nil {
                    assetToNutBottomDelta = 0
                }
                guard !introDidRun else { return }
                introDidRun = true
                introWindowBlack = true
                currentFretStart = minFretOffset

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 2.2)) {
                        currentFretStart = 0
                        introWindowBlack = false
                    }
                }
            }
            .offset(y: globalContentShiftY)
        }
    }

    private func shiftFretSpan(by delta: Int) {
        guard delta != 0 else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            currentFretStart = min(max(currentFretStart + delta, minFretOffset), maxFretOffset)
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

    private func nextThumbState(after state: ThumbGlowState) -> ThumbGlowState {
        switch state {
        case .neutral: return .green
        case .green: return .red
        case .red: return .neutral
        }
    }

    private func startGameFromBeginning() {
        currentRound = 0
        roundStringIndex = 0
        isDescendingPhase = false
        bankDollars = 0
        displayedBankDollars = 0
        roundAnnouncement = "1"
        leftThumbState = .neutral
        rightThumbState = .neutral
        activeAnswerFeedback = nil
        isResolvingAnswer = false
        prepareCurrentQuestion()
    }

    private func submitAnswer(_ side: AnswerSide) {
        if isCodeScreensaverMode {
            isCodeScreensaverMode = false
            startGameFromBeginning()
            return
        }

        guard !isResolvingAnswer else { return }
        isResolvingAnswer = true

        let isCorrect = side == correctAnswerSide
        if isCorrect {
            leftThumbState = .green
            rightThumbState = .green
            activeAnswerFeedback = .green
        } else {
            leftThumbState = .red
            rightThumbState = .red
            activeAnswerFeedback = .red
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            leftThumbState = .neutral
            rightThumbState = .neutral
            if isCorrect {
                advanceGame(afterCorrectAnswer: true)
                isResolvingAnswer = false
            } else {
                advanceGame(afterCorrectAnswer: false)
            }
        }
    }

    private func advanceGame(afterCorrectAnswer isCorrect: Bool) {
        if !isCorrect {
            animateBankResetToZero {
                startGameFromBeginning()
                isResolvingAnswer = false
            }
            return
        }

        let payout = payoutForRound(currentRound)
        bankDollars += payout
        displayedBankDollars = bankDollars

        if roundStringIndex < gameStringOrder.count - 1 {
            roundStringIndex += 1
        } else {
            roundStringIndex = 0
            if !isDescendingPhase {
                if currentRound < 12 {
                    currentRound += 1
                } else {
                    isDescendingPhase = true
                    currentRound = 11
                }
            } else {
                if currentRound > 1 {
                    currentRound -= 1
                } else {
                    startGameFromBeginning()
                    return
                }
            }
        }

        prepareCurrentQuestion()
    }

    private func prepareCurrentQuestion() {
        let targetString = gameStringOrder[min(max(roundStringIndex, 0), gameStringOrder.count - 1)]
        let fret = max(currentRound, 0)
        let useFlats = isDescendingPhase
        let correctNote = noteName(forString: targetString, fret: fret, useFlats: useFlats)
        let incorrectNote = randomIncorrectNote(excluding: correctNote, useFlats: useFlats)
        let correctOnLeft = Bool.random()

        if correctOnLeft {
            leftChoiceNote = correctNote
            rightChoiceNote = incorrectNote
            correctAnswerSide = .left
        } else {
            leftChoiceNote = incorrectNote
            rightChoiceNote = correctNote
            correctAnswerSide = .right
        }

        activePickedStringNumber = targetString
        currentQuestionIsAccidental = correctNote.contains("#") || correctNote.contains("b")
        activeAnswerFeedback = nil
        currentFretStart = fret
        roundAnnouncement = "\(max(fret, 1))"
    }

    private func payoutForRound(_ round: Int) -> Int {
        let clamped = min(max(round, 0), 20)
        return Int(pow(2.0, Double(clamped)))
    }

    private func animateBankResetToZero(completion: @escaping () -> Void) {
        let startValue = displayedBankDollars
        guard startValue > 0 else {
            bankDollars = 0
            displayedBankDollars = 0
            completion()
            return
        }

        let steps = 24
        let interval: Double = 0.018
        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(step) * interval)) {
                let remainingRatio = max(0, 1.0 - (Double(step) / Double(steps)))
                displayedBankDollars = Int((Double(startValue) * remainingRatio).rounded())
                if step == steps {
                    bankDollars = 0
                    displayedBankDollars = 0
                    completion()
                }
            }
        }
    }

    private func noteName(forString string: Int, fret: Int, useFlats: Bool) -> String {
        guard let openNote = openNoteByString[string],
              let openIndex = chromaticSharps.firstIndex(of: openNote) else {
            return "?"
        }

        let noteIndex = (openIndex + fret) % chromaticSharps.count
        let scale = useFlats ? chromaticFlats : chromaticSharps
        return scale[noteIndex]
    }

    private func randomIncorrectNote(excluding correct: String, useFlats: Bool) -> String {
        let source = useFlats ? chromaticFlats : chromaticSharps
        let pool = source.filter { $0 != correct }
        return pool.randomElement() ?? "C"
    }

    private func textWidth(for text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return ceil(text.size(withAttributes: attributes).width)
    }
}

private struct PurpleGuidelineLayer: View {
    let size: CGSize
    let positions: [CGFloat]

    var body: some View {
        ZStack {
            ForEach(Array(positions.enumerated()), id: \.offset) { _, y in
                Rectangle()
                    .fill(Color.purple.opacity(0.9))
                    .frame(width: size.width, height: 2)
                    .position(x: size.width / 2, y: y)
            }
        }
        .frame(width: size.width, height: size.height)
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
            .stroke(Color.red.opacity(0.45), lineWidth: 1)

            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<columns, id: \.self) { column in
                    let index = row * columns + column + 1
                    Text("\(index)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.red.opacity(0.85))
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
            .strokeBorder(Color.red.opacity(0.9), lineWidth: max(width * 0.004, 2))
            .shadow(color: Color.red.opacity(0.25), radius: 8, x: 0, y: 4)
            .frame(width: width, height: height)
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
            Color.black.opacity(0.82)
                .frame(width: canvasSize.width, height: canvasSize.height)

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

private struct RosewoodSegmentedBackground: View {
    let fretRatios: [CGFloat]
    let cornerRadius: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let neckHeight = geometry.size.height
            let neckWidth = geometry.size.width
            let segments = segmentBounds(from: fretRatios)
            let bindingInset = max(neckWidth * 0.02, 6)
            let rosewoodTexture = Image("RosewoodOne")

            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    let groupSize = 3
                    ForEach(Array(stride(from: 0, to: segments.count, by: groupSize)), id: \.self) { start in
                        let end = min(start + groupSize, segments.count)
                        let groupHeight = (start..<end).reduce(CGFloat(0)) { acc, idx in
                            acc + max((segments[idx].end - segments[idx].start) * neckHeight, 1)
                        }
                        rosewoodTexture
                            .resizable()
                            .scaledToFill()
                            .frame(width: neckWidth, height: groupHeight)
                            .clipped()
                    }
                }
                .padding(.horizontal, bindingInset)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)

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
                                    .fill(Color.white.opacity(((index + 1) % 3 == 0) ? 0.08 : 0))
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
    }
}

#Preview {
    ContentView()
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

