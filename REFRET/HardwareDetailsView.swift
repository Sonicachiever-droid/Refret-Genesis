import SwiftUI

struct HardwareDetailsView: View {
    @ObservedObject var skinManager: SkinManager
    let size: CGSize
    
    var body: some View {
        ZStack {
            if skinManager.colors.hasScrews {
                ScrewPatternView(color: skinManager.colors.screwColor, size: size)
            }
            if skinManager.colors.hasStitching {
                StitchingPatternView(size: size, stitchingColor: skinManager.colors.stitchingColor)
            }
        }
    }
}

struct ScrewPatternView: View {
    let color: Color
    let size: CGSize
    
    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                ScrewView(color: color, rotation: Double(index) * 90)
                    .position(position(for: index))
            }
        }
    }
    
    private func position(for index: Int) -> CGPoint {
        let inset: CGFloat = 40
        switch index {
        case 0: return CGPoint(x: inset, y: inset)
        case 1: return CGPoint(x: size.width - inset, y: inset)
        case 2: return CGPoint(x: inset, y: size.height - inset)
        default: return CGPoint(x: size.width - inset, y: size.height - inset)
        }
    }
}

struct ScrewView: View {
    let color: Color
    var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.25))
                .frame(width: 34, height: 34)
                .blur(radius: 4)
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: color.opacity(0.9), location: 0.0),
                            .init(color: color.opacity(0.6), location: 0.4),
                            .init(color: Color.black.opacity(0.3), location: 1.0)
                        ]),
                        center: .init(x: 0.4, y: 0.3),
                        startRadius: 0,
                        endRadius: 18
                    )
                )
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
            
            ScrewCrossShape()
                .stroke(Color.black.opacity(0.5), lineWidth: 1.5)
                .frame(width: 18, height: 18)
                .rotationEffect(.degrees(rotation))
                .overlay(
                    ScrewCrossShape()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        .offset(x: -0.5, y: -0.5)
                        .rotationEffect(.degrees(rotation))
                )
            
            Circle()
                .fill(Color.white.opacity(0.25))
                .frame(width: 6, height: 6)
                .offset(x: -3, y: -3)
        }
    }
}

struct ScrewCrossShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let thickness = rect.width * 0.18
        path.addRoundedRect(in: CGRect(x: rect.midX - thickness / 2, y: rect.minY, width: thickness, height: rect.height), cornerSize: CGSize(width: thickness / 2, height: thickness / 2))
        path.addRoundedRect(in: CGRect(x: rect.minX, y: rect.midY - thickness / 2, width: rect.width, height: thickness), cornerSize: CGSize(width: thickness / 2, height: thickness / 2))
        return path
    }
}

struct StitchingPatternView: View {
    let size: CGSize
    let stitchingColor: Color
    
    var body: some View {
        ZStack {
            StitchingEdge(shape: .top, size: size, color: stitchingColor)
            StitchingEdge(shape: .bottom, size: size, color: stitchingColor)
            StitchingEdge(shape: .left, size: size, color: stitchingColor)
            StitchingEdge(shape: .right, size: size, color: stitchingColor)
        }
    }
}

struct StitchingEdge: View {
    enum EdgeShape { case top, bottom, left, right }
    let shape: EdgeShape
    let size: CGSize
    let color: Color
    
    var body: some View {
        Canvas { context, canvasSize in
            let spacing: CGFloat = 16
            let offset: CGFloat = 10
            for point in stride(from: spacing, to: max(canvasDimension, spacing), by: spacing) {
                var stitch = Path()
                switch shape {
                case .top:
                    stitch.move(to: CGPoint(x: point, y: offset))
                    stitch.addLine(to: CGPoint(x: point + spacing / 2, y: offset + 6))
                case .bottom:
                    let y = canvasSize.height - offset
                    stitch.move(to: CGPoint(x: point, y: y))
                    stitch.addLine(to: CGPoint(x: point + spacing / 2, y: y - 6))
                case .left:
                    stitch.move(to: CGPoint(x: offset, y: point))
                    stitch.addLine(to: CGPoint(x: offset + 6, y: point + spacing / 2))
                case .right:
                    let x = canvasSize.width - offset
                    stitch.move(to: CGPoint(x: x, y: point))
                    stitch.addLine(to: CGPoint(x: x - 6, y: point + spacing / 2))
                }
                context.stroke(stitch, with: .color(color.opacity(0.6)), lineWidth: 2)
            }
        }
        .frame(width: size.width, height: size.height)
    }
    
    private var canvasDimension: CGFloat {
        switch shape {
        case .top, .bottom:
            return size.width
        case .left, .right:
            return size.height
        }
    }
}
