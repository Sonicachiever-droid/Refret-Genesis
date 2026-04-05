//
//  ContentView.swift
//  REFRET THREE
//
//  Created by Thomas Kane on 3/12/26.
//

import SwiftUI

private enum NeckComponent: Int, CaseIterable {
    case fretboard = 1
    case nut = 2
    case binding = 3
    case fretWires = 4
    case fretMarkers = 5
    case strings = 6
    case openStringLabels = 7
    case debugGrid = 8
    case roundCompletedButton = 9
    case nutFirstFretOverlay = 10
}

struct ContentView: View {
    private let totalStrings: Int = 6
    private let totalFrets: Int = 20
    private let scaleLengthInches: Double = 25.5
    private let markerFrets: [Int] = [3, 5, 7, 9, 12, 15, 17, 19]
    private let openStringNotes: [String] = ["E", "A", "D", "G", "B", "E"]
    private let activeComponents: Set<NeckComponent> = [.fretboard, .nut, .binding, .fretWires, .debugGrid, .nutFirstFretOverlay]
    @State private var currentFretStart: Int = 0
    @State private var showOpenStringCapsules: Bool = true
    @State private var currentWindowRow: Int = 0

    private var maxFretOffset: Int { totalFrets }
    private var minFretOffset: Int { -totalFrets }

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
            let neckTopInset = proxy.size.height * 0.08
            let neckTopOffset = neckTopInset
            let nutLiftFrets: CGFloat = 2.5
            let nutLiftRatio = FretMath.distanceRatio(for: nutLiftFrets, scaleLength: scaleLengthInches)
            let nutVerticalLift = nutLiftRatio * neckHeight
            let nutTopOffset = neckTopOffset - nutVerticalLift
            let nutAdjustedOffset = nutTopOffset + nutVisualHeight * 0.05 + 28.35
            let labelBandHeight = min(gridRowHeight * 3.2, neckHeight * 0.08)
            let markerData = FretMath.markerRatios(
                fretRatios: fretRatios,
                markerFrets: markerFrets
            )
            let unsignedSlide = FretMath.offsetRatio(for: abs(currentFretStart), fretRatios: fretRatios)
            let slideRatio = currentFretStart >= 0 ? unsignedSlide : -unsignedSlide
            let neckSlideOffset = neckTopOffset - slideRatio * neckHeight
            let nutSlideAdjustment = neckSlideOffset - neckTopOffset
            let labelBandOffset = neckSlideOffset - labelBandHeight * 0.65
            let firstFretRatio = fretRatios.indices.contains(1) ? fretRatios[1] : (fretRatios.last ?? 0)
            let firstFretHeight = firstFretRatio * neckHeight
            let nutPaddingHeight = nutVisualHeight * 1.35
            let highlightHeight = max(firstFretHeight + nutPaddingHeight, neckHeight * 0.08)
            let highlightTopGridLineY = CGFloat(currentWindowRow) * gridRowHeight
            let highlightCenterY = highlightTopGridLineY + highlightHeight / 2
            let highlightAvailableWidth = max(proxy.size.width - padding * 2, 0)
            let highlightExtraWidth = max(highlightAvailableWidth - neckWidth, 0)
            let highlightWidth = neckWidth + highlightExtraWidth / 2
            let highlightCornerRadius = min(24, highlightWidth * 0.08)

            let unsignedN = abs(currentFretStart)
            let clampedN = min(unsignedN, fretRatios.count - 2)
            let topRatio = fretRatios[clampedN]
            let bottomRatio = fretRatios[clampedN + 1]
            let midRatio = (topRatio + bottomRatio) / 2.0
            let sign: CGFloat = currentFretStart >= 0 ? 1.0 : -1.0
            let activeMidpoint = midRatio * neckHeight * sign

            let nutTargetY = highlightTopGridLineY + 2 * gridRowHeight
            let neckTopY = nutTargetY - activeMidpoint
            let neckOffsetY = neckTopY - proxy.size.height / 2 + neckHeight / 2

            ZStack {
                Color.black
                    .ignoresSafeArea()

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
                        .offset(y: neckOffsetY)
                    }
                    .frame(width: neckWidth, height: visibleClipHeight)
                    .clipped()
                    Spacer()
                }
                .padding(.horizontal, padding)

                GeometryReader { matteGeo in
                    TweedMatteOverlay(
                        canvasSize: matteGeo.size,
                        highlightWidth: highlightWidth,
                        highlightHeight: highlightHeight,
                        highlightCenter: CGPoint(x: matteGeo.size.width / 2, y: highlightCenterY),
                        highlightCornerRadius: highlightCornerRadius
                    )
                }
                .allowsHitTesting(false)
                .ignoresSafeArea()

                GeometryReader { overlayGeo in
                    NutFirstFretHighlight(
                        width: highlightWidth,
                        height: highlightHeight,
                        cornerRadius: highlightCornerRadius
                    )
                    .overlay {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: highlightWidth, height: 3)
                    }
                    .position(
                        x: overlayGeo.size.width / 2,
                        y: highlightCenterY
                    )
                }
                .padding(.horizontal, padding)
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
            .overlay {
                debugGridOverlay(size: proxy.size, columns: debugGridColumns, rows: debugGridRows)
                    .allowsHitTesting(false)
                    .opacity(0.8)
            }
        }
    }

    private func advanceFretSpan() {
        withAnimation(.easeInOut(duration: 0.6)) {
            currentFretStart = min(currentFretStart + 1, totalFrets)
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
        let clamped = min(max(proposed, 0), 7) // 8 rows total, 0 to 7
        guard clamped != currentWindowRow else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            currentWindowRow = clamped
        }
    }

    private func isActive(_ component: NeckComponent) -> Bool {
        activeComponents.contains(component)
    }
}

// MARK: - Debug Controls

private struct RoundCompletedButtonLayer: View {
    let size: CGSize
    let columns: Int
    let rows: Int
    let action: () -> Void

    private let targetCell: Int = 36

    var body: some View {
        let cellWidth = size.width / CGFloat(columns)
        let cellHeight = size.height / CGFloat(rows)
        let maxCellIndex = max(targetCell - 1, 0)
        let rowIndex = maxCellIndex / columns
        let columnIndex = maxCellIndex % columns
        let buttonWidth = cellWidth * 0.9
        let buttonHeight = cellHeight * 0.65

        return Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "arrow.up")
                    .font(.system(size: buttonHeight * 0.35, weight: .bold))
                Text("Round Completed")
                    .font(.system(size: buttonHeight * 0.28, weight: .semibold))
                    .minimumScaleFactor(0.6)
            }
            .foregroundColor(Color.white)
            .padding(.vertical, 6)
            .frame(width: buttonWidth, height: buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: buttonHeight * 0.35, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.35, green: 0.35, blue: 0.4),
                                Color(red: 0.15, green: 0.15, blue: 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: buttonHeight * 0.35, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
            )
        }
        .position(
            x: CGFloat(columnIndex) * cellWidth + cellWidth / 2,
            y: CGFloat(rowIndex) * cellHeight + cellHeight / 2
        )
    }
}

// MARK: - Label Layer

private struct OpenStringLabelLayer: View {
    let notes: [String]
    let totalStrings: Int

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let marginX = max(width * 0.05, 12)
            let usableWidth = max(width - marginX * 2, 1)
            let spacing = usableWidth / CGFloat(max(totalStrings - 1, 1))
            let labelHeight = min(max(height * 0.45, 32), height * 0.6)
            let labelWidth = max(spacing * 0.26, 22)
            let cornerRadius = labelWidth * 0.4
            let targetRows: ClosedRange<CGFloat> = 1...5
            let rowHeight = height / 8
            let minY = rowHeight * targetRows.lowerBound
            let maxY = rowHeight * targetRows.upperBound
            let centerY = (minY + maxY) / 2

            ZStack(alignment: .topLeading) {
                ForEach(0..<totalStrings, id: \.self) { index in
                    let x = marginX + CGFloat(index) * spacing

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.55),
                                    Color.white.opacity(0.35)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(Color.white.opacity(0.35), lineWidth: 0.6)
                        )
                        .frame(width: labelWidth, height: labelHeight)
                        .position(x: x, y: centerY)
                        .overlay(alignment: .center) {
                            RoundedRectangle(cornerRadius: cornerRadius * 0.7, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.4)
                        }
                }
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Fret Geometry (ratios reference fretwire boundaries)

private enum FretMath {
    static func fretPositionRatios(totalFrets: Int, scaleLength: Double) -> [CGFloat] {
        guard totalFrets > 0, scaleLength > 0 else { return [] }
        return (0...totalFrets).map { fretwireIndex in
            let distance = scaleLength - scaleLength / pow(2.0, Double(fretwireIndex) / 12.0)
            return CGFloat(distance / scaleLength)
        }
    }

    static func markerRatios(
        fretRatios: [CGFloat],
        markerFrets: [Int]
    ) -> [FretMarkerData] {
        var results: [FretMarkerData] = []
        for fretSpan in markerFrets {
            let currentIndex = min(max(fretSpan, 0), fretRatios.count - 1)
            let previousIndex = max(currentIndex - 1, 0)
            let previousRatio = fretRatios[previousIndex]
            let currentRatio = fretRatios[currentIndex]
            let ratio = (previousRatio + currentRatio) / 2
            results.append(FretMarkerData(fretNumber: fretSpan, ratio: ratio))
        }
        return results
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

private struct FretMarkerData: Identifiable {
    let fretNumber: Int
    let ratio: CGFloat
    var id: Int { fretNumber }
}

// MARK: - Layers

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
    let markerData: [FretMarkerData]

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let dotDiameter = max(min(width, height) * 0.035, 10)
            let doubleSpacing = dotDiameter * 0.7

            ZStack {
                ForEach(markerData) { data in
                    let yPosition = data.ratio * height
                    if data.fretNumber == 12 {
                        HStack(spacing: doubleSpacing) {
                            markerDot(size: dotDiameter)
                            markerDot(size: dotDiameter)
                        }
                        .frame(width: width)
                        .position(x: width / 2, y: yPosition)
                    } else {
                        markerDot(size: dotDiameter)
                            .position(x: width / 2, y: yPosition)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func markerDot(size: CGFloat) -> some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.98, blue: 0.96),
                        Color(red: 0.91, green: 0.91, blue: 0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Circle().stroke(Color.black.opacity(0.15), lineWidth: 0.5)
            )
            .frame(width: size, height: size)
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

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.35),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width - stripWidth * 2.4, height: max(geo.size.height * 0.002, 1.2))
                    .position(x: geo.size.width / 2, y: stripWidth * 0.35)
                    .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 0.5)
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

// MARK: - Overlays

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

private struct TweedMatteOverlay: View {
    let canvasSize: CGSize
    let highlightWidth: CGFloat
    let highlightHeight: CGFloat
    let highlightCenter: CGPoint
    let highlightCornerRadius: CGFloat

    var body: some View {
        ZStack {
            Image("TweedSample")
                .resizable()
                .scaledToFill()
                .scaleEffect(x: 1.15, y: 1.6, anchor: .center)
                .frame(width: canvasSize.width, height: canvasSize.height)
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

// MARK: - Developer Controls

private struct MapleSegmentedBackground: View {
    let fretRatios: [CGFloat]
    let cornerRadius: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let neckHeight = geometry.size.height
            let neckWidth = geometry.size.width
            let segments = segmentBounds(from: fretRatios)
            let bindingInset = max(neckWidth * 0.02, 6)

            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ForEach(Array(segments.enumerated()), id: \.offset) { index, bounds in
                        let segmentHeight = max((bounds.end - bounds.start) * neckHeight, 1)
                        Image("FretWoodSET2Maple")
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
