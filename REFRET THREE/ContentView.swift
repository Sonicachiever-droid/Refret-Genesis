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
}

struct ContentView: View {
    private let totalStrings: Int = 6
    private let totalFrets: Int = 20
    private let scaleLengthInches: Double = 25.5
    private let markerFrets: [Int] = [3, 5, 7, 9, 12, 15, 17, 19]
    private let openStringNotes: [String] = ["E", "A", "D", "G", "B", "E"]
    private let activeComponents: Set<NeckComponent> = [.fretboard, .nut, .binding, .fretWires, .debugGrid]
    @State private var currentFretStart: Int = 0
    @State private var showOpenStringCapsules: Bool = true
    
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
            let visibleClipHeight = proxy.size.height * 0.78
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
            let showFretboard = isActive(.fretboard)
            let showNut = isActive(.nut)
            let showBinding = isActive(.binding)
            let showFretWires = isActive(.fretWires)
            let showMarkers = isActive(.fretMarkers)
            let showStrings = isActive(.strings)
            let showOpenLabels = isActive(.openStringLabels) && showOpenStringCapsules
            let showPrimaryStack = showFretboard || showNut || showBinding || showFretWires || showMarkers || showStrings || showOpenLabels

            ZStack {
                Color(red: 0.15, green: 0.15, blue: 0.18)
                    .ignoresSafeArea()

                HStack {
                    Spacer()
                    ZStack {
                        if showFretboard {
                            Image("FretWoodSET 2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: neckWidth, height: neckHeight)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        }

                        if showBinding {
                            BindingLayer()
                                .frame(width: neckWidth, height: neckHeight)
                        }

                        if showMarkers {
                            FretMarkerLayer(markerData: markerData)
                                .frame(width: neckWidth, height: neckHeight)
                        }

                        if showFretWires {
                            FretWireLayer(fretRatios: fretRatios)
                                .frame(width: neckWidth, height: neckHeight)
                        }

                        if showOpenLabels {
                            OpenStringLabelLayer(notes: openStringNotes, totalStrings: totalStrings)
                                .frame(width: neckWidth, height: labelBandHeight)
                        }
                    }
                    .frame(width: neckWidth, height: neckHeight)
                    .offset(y: neckSlideOffset)
                    .clipped()
                    .frame(width: neckWidth, height: visibleClipHeight, alignment: .top)
                    Spacer()
                }
                .padding(.horizontal, padding)
                
                if showNut {
                    HStack {
                        Spacer()
                        NutLayer(width: neckWidth * 0.99, height: nutVisualHeight)
                            .frame(width: neckWidth * 0.99, height: nutVisualHeight)
                            .offset(y: nutAdjustedOffset + nutSlideAdjustment)
                        Spacer()
                    }
                    .padding(.horizontal, padding)
                }
                
                DeveloperButtonStack(
                    shiftUp: { shiftFret(by: 1) },
                    shiftDown: { shiftFret(by: -1) },
                    canShiftUp: currentFretStart < maxFretOffset,
                    canShiftDown: currentFretStart > minFretOffset
                )
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
            .overlay {
                Group {
                    if isActive(.debugGrid) {
                        debugGridOverlay(size: proxy.size, columns: debugGridColumns, rows: debugGridRows)
                            .allowsHitTesting(false)
                            .opacity(0.3)
                    }
                }
            }
            .overlay(alignment: .topLeading) {
                Group {
                    if isActive(.roundCompletedButton) {
                        RoundCompletedButtonLayer(
                            size: proxy.size,
                            columns: debugGridColumns,
                            rows: debugGridRows,
                            action: advanceFret
                        )
                        .allowsHitTesting(false)
                    }
                }
            }
        }
    }

    private func advanceFret() {
        withAnimation(.easeInOut(duration: 0.6)) {
            currentFretStart = min(currentFretStart + 1, totalFrets)
        }
    }
    
    private func shiftFret(by delta: Int) {
        guard delta != 0 else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            currentFretStart = min(max(currentFretStart + delta, minFretOffset), maxFretOffset)
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

// MARK: - Fret Geometry

private enum FretMath {
    static func fretPositionRatios(totalFrets: Int, scaleLength: Double) -> [CGFloat] {
        guard totalFrets > 0, scaleLength > 0 else { return [] }
        return (0...totalFrets).map { fret in
            let distance = scaleLength - scaleLength / pow(2.0, Double(fret) / 12.0)
            return CGFloat(distance / scaleLength)
        }
    }

    static func markerRatios(
        fretRatios: [CGFloat],
        markerFrets: [Int]
    ) -> [FretMarkerData] {
        var results: [FretMarkerData] = []
        for fret in markerFrets {
            let currentIndex = min(max(fret, 0), fretRatios.count - 1)
            let previousIndex = max(currentIndex - 1, 0)
            let previousRatio = fretRatios[previousIndex]
            let currentRatio = fretRatios[currentIndex]
            let ratio = (previousRatio + currentRatio) / 2
            results.append(FretMarkerData(fretNumber: fret, ratio: ratio))
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

// MARK: - Developer Controls

private struct DeveloperButtonStack: View {
    let shiftUp: () -> Void
    let shiftDown: () -> Void
    let canShiftUp: Bool
    let canShiftDown: Bool

    var body: some View {
        HStack(spacing: 24) {
            devButton(icon: "arrow.down", action: shiftDown, isEnabled: canShiftDown)
            devButton(icon: "arrow.up", action: shiftUp, isEnabled: canShiftUp)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.35))
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
