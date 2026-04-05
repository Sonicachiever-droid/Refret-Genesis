import SwiftUI

struct MaterialShaderView: View {
    @ObservedObject var skinManager: SkinManager
    
    var body: some View {
        DynamicBackgroundView(skinManager: skinManager)
    }
}

struct DynamicBackgroundView: View {
    @ObservedObject var skinManager: SkinManager
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                skinManager.colors.background
                    .ignoresSafeArea()
                
                if !skinManager.currentSkin.disablesTextures, skinManager.colors.hasTexture {
                    materialTexture(size: proxy.size)
                }
                
                themeOverlay(size: proxy.size)
                    .allowsHitTesting(false)
                
                if skinManager.colors.hasInnerShadow {
                    innerShadow(size: proxy.size)
                }
                
                if skinManager.colors.hasGlassEffect {
                    glassBloom(size: proxy.size)
                }
            }
        }
    }
    
    @ViewBuilder
    private func materialTexture(size: CGSize) -> some View {
        switch skinManager.colors.textureType {
        case .wood:
            WoodGrainView(size: size, roughness: skinManager.colors.roughness)
        case .leather:
            LeatherTextureView(size: size, roughness: skinManager.colors.roughness)
        case .metal:
            MetallicView(size: size, shininess: skinManager.colors.shininess)
        case .plastic:
            PlasticView(size: size, shininess: skinManager.colors.shininess)
        case .glass:
            GlassTextureView(size: size, transparency: skinManager.colors.transparency)
        case .paper:
            PaperTextureView(size: size)
        case .stone:
            StoneTextureView(size: size, roughness: skinManager.colors.roughness)
        case .fabric:
            FabricTextureView(size: size)
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func themeOverlay(size: CGSize) -> some View {
        switch skinManager.currentSkin {
        case .blank, .empty:
            EmptyView()
        case .default:
            DefaultOrnamentView(size: size)
        case .futuristic:
            FuturisticOrnamentView(size: size)
        case .retro50s:
            Retro50sOrnamentView(size: size)
        case .western:
            WesternOrnamentView(size: size)
        case .artNouveau:
            ArtNouveauOrnamentView(size: size)
        case .zen:
            ZenOrnamentView(size: size)
        case .artDeco:
            ArtDecoOrnamentView(size: size)
        case .steampunk:
            SteampunkOrnamentView(size: size)
        case .bauhaus:
            BauhausOrnamentView(size: size)
        case .tropical:
            TropicalOrnamentView(size: size)
        case .gothic:
            GothicOrnamentView(size: size)
        }
    }
    
    private func innerShadow(size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 40)
            .stroke(Color.black.opacity(0.25), lineWidth: 20)
            .blur(radius: 30)
            .frame(width: size.width * 0.9, height: size.height * 0.9)
    }
    
    private func glassBloom(size: CGSize) -> some View {
        RadialGradient(
            colors: [Color.white.opacity(0.15), Color.clear],
            center: .topLeading,
            startRadius: 40,
            endRadius: max(size.width, size.height)
        )
    }
}

// MARK: - Texture primitives

struct WoodGrainView: View {
    let size: CGSize
    let roughness: Double
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.66, green: 0.48, blue: 0.29),
                        Color(red: 0.55, green: 0.36, blue: 0.19),
                        Color(red: 0.70, green: 0.50, blue: 0.28)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                Canvas { context, _ in
                    let ringCount = 80
                    for i in 0..<ringCount {
                        let phase = Double(i) * 0.35
                        let offset = sin(phase) * 14
                        let color = Color.black.opacity(0.03 + 0.02 * sin(phase * 0.7))
                        let y = CGFloat(i) * 4
                        var path = Path()
                        path.move(to: CGPoint(x: -20, y: y))
                        path.addCurve(
                            to: CGPoint(x: size.width + 20, y: y + CGFloat(offset)),
                            control1: CGPoint(x: size.width * 0.2, y: y - 8),
                            control2: CGPoint(x: size.width * 0.8, y: y + 8)
                        )
                        context.stroke(path, with: .color(color), lineWidth: roughness < 0.3 ? 0.6 : 1.2)
                    }
                }
            )
    }
}

struct LeatherTextureView: View {
    let size: CGSize
    let roughness: Double
    
    private func seeded(_ index: Int) -> Double {
        sin(Double(index * 413 + 97))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.32, green: 0.18, blue: 0.08),
                    Color(red: 0.28, green: 0.15, blue: 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Canvas { context, canvasSize in
                let cell = 8.0
                for row in 0..<Int(canvasSize.height / cell) {
                    for col in 0..<Int(canvasSize.width / cell) {
                        let idx = row * 97 + col
                        let alpha = 0.03 + abs(seeded(idx)) * 0.05
                        let rect = CGRect(x: CGFloat(col) * cell, y: CGFloat(row) * cell, width: cell, height: cell)
                        context.fill(Path(ellipseIn: rect.insetBy(dx: 2, dy: 2)), with: .color(Color.black.opacity(alpha)))
                    }
                }
            }
            
            ForEach(0..<20, id: \.self) { index in
                Capsule()
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    .frame(width: CGFloat(40 + abs(seeded(index)) * 60), height: 4)
                    .rotationEffect(.degrees(Double(index) * 7))
                    .offset(x: CGFloat(seeded(index + 1)) * size.width * 0.4,
                            y: CGFloat(seeded(index + 2)) * size.height * 0.4)
            }
        }
    }
}

struct MetallicView: View {
    let size: CGSize
    let shininess: Double
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(shininess * 0.7),
                Color.gray.opacity(0.6),
                Color.black.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Capsule()
                .fill(Color.white.opacity(shininess * 0.4))
                .blur(radius: 60)
                .offset(x: -size.width * 0.2, y: -size.height * 0.2)
        )
    }
}

struct PlasticView: View {
    let size: CGSize
    let shininess: Double
    
    var body: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(shininess * 0.4),
                        Color.black.opacity(0.1)
                    ],
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: min(size.width, size.height)
                )
            )
    }
}

struct GlassTextureView: View {
    let size: CGSize
    let transparency: Double
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(transparency * 0.2),
                        Color.clear,
                        Color.white.opacity(transparency * 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Canvas { context, canvasSize in
                    for row in stride(from: 0, to: canvasSize.height, by: 40) {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: row))
                        for x in stride(from: 0, to: canvasSize.width, by: 10) {
                            let wave = sin(Double(x) * 0.1 + Double(row)) * 4
                            path.addLine(to: CGPoint(x: x, y: row + CGFloat(wave)))
                        }
                        context.stroke(path, with: .color(Color.white.opacity(0.06)), lineWidth: 1)
                    }
                }
            )
    }
}

struct PaperTextureView: View {
    let size: CGSize
    
    private func seeded(_ index: Int) -> Double {
        sin(Double(index * 211 + 5))
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.93, blue: 0.87)
            
            ForEach(0..<40, id: \.self) { index in
                Capsule()
                    .fill(Color.brown.opacity(0.05))
                    .frame(width: CGFloat(2 + abs(seeded(index)) * 3), height: CGFloat(20 + abs(seeded(index + 1)) * 20))
                    .rotationEffect(.degrees(seeded(index + 2) * 40))
                    .offset(
                        x: CGFloat(seeded(index + 3)) * size.width * 0.5,
                        y: CGFloat(seeded(index + 4)) * size.height * 0.5
                    )
            }
            
            ForEach(0..<10, id: \.self) { index in
                Circle()
                    .fill(Color(red: 0.7, green: 0.55, blue: 0.3).opacity(0.08))
                    .frame(width: CGFloat(6 + abs(seeded(index)) * 16))
                    .offset(
                        x: CGFloat(seeded(index + 10)) * size.width * 0.4,
                        y: CGFloat(seeded(index + 11)) * size.height * 0.4
                    )
            }
        }
    }
}

struct StoneTextureView: View {
    let size: CGSize
    let roughness: Double
    
    private func seeded(_ index: Int) -> Double {
        sin(Double(index * 131 + 17))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.53, blue: 0.5),
                    Color(red: 0.45, green: 0.44, blue: 0.41)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            Canvas { context, canvasSize in
                let blockH: CGFloat = 40
                let blockW: CGFloat = 80
                for row in 0..<Int(canvasSize.height / blockH) + 1 {
                    var horizontal = Path()
                    horizontal.move(to: CGPoint(x: 0, y: CGFloat(row) * blockH))
                    horizontal.addLine(to: CGPoint(x: canvasSize.width, y: CGFloat(row) * blockH))
                    context.stroke(horizontal, with: .color(Color.black.opacity(0.12)), lineWidth: 1)
                    for col in 0..<Int(canvasSize.width / blockW) + 2 {
                        let x = CGFloat(col) * blockW + (row.isMultiple(of: 2) ? 0 : blockW / 2)
                        var vertical = Path()
                        vertical.move(to: CGPoint(x: x, y: CGFloat(row) * blockH))
                        vertical.addLine(to: CGPoint(x: x, y: CGFloat(row + 1) * blockH))
                        context.stroke(vertical, with: .color(Color.black.opacity(0.08)), lineWidth: 1)
                    }
                }
            }
            
            ForEach(0..<25, id: \.self) { index in
                RoundedRectangle(cornerRadius: CGFloat(4 + abs(seeded(index)) * 8))
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    .frame(width: CGFloat(30 + abs(seeded(index)) * 40), height: CGFloat(30 + abs(seeded(index + 1)) * 40))
                    .offset(
                        x: CGFloat(seeded(index + 2)) * size.width * 0.5,
                        y: CGFloat(seeded(index + 3)) * size.height * 0.5
                    )
            }
        }
    }
}

struct FabricTextureView: View {
    let size: CGSize
    
    var body: some View {
        Rectangle()
            .fill(Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.7))
            .overlay(
                Canvas { context, canvasSize in
                    let spacing: CGFloat = 6
                    for row in stride(from: 0, to: canvasSize.height, by: spacing) {
                        var horizontal = Path()
                        horizontal.move(to: CGPoint(x: 0, y: row))
                        horizontal.addLine(to: CGPoint(x: canvasSize.width, y: row))
                        context.stroke(horizontal, with: .color(Color.black.opacity(0.1)), lineWidth: 1)
                    }
                    for col in stride(from: 0, to: canvasSize.width, by: spacing) {
                        var vertical = Path()
                        vertical.move(to: CGPoint(x: col, y: 0))
                        vertical.addLine(to: CGPoint(x: col, y: canvasSize.height))
                        context.stroke(vertical, with: .color(Color.black.opacity(0.1)), lineWidth: 1)
                    }
                }
            )
    }
}

// MARK: - Theme ornaments (simplified but highly detailed)

struct DefaultOrnamentView: View {
    let size: CGSize
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.white.opacity(0.1), Color.black.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Canvas { context, canvasSize in
                let spacing: CGFloat = 16
                for row in stride(from: canvasSize.height * 0.3, to: canvasSize.height * 0.7, by: spacing) {
                    for col in stride(from: 0, to: canvasSize.width, by: spacing) {
                        let dot = Path(ellipseIn: CGRect(x: col, y: row, width: 3, height: 3))
                        context.fill(dot, with: .color(Color.white.opacity(0.22)))
                    }
                }
            }
            RadialGradient(colors: [Color.white.opacity(0.25), Color.clear], center: .center, startRadius: 40, endRadius: min(size.width, size.height))
        }
        .blendMode(.softLight)
    }
}

struct FuturisticOrnamentView: View {
    let size: CGSize
    var body: some View {
        ZStack {
            Canvas { context, canvasSize in
                let hexSize: CGFloat = 30
                let hexHeight = hexSize * sqrt(3)
                for row in 0..<Int(canvasSize.height / hexHeight) + 2 {
                    for col in 0..<Int(canvasSize.width / (hexSize * 1.5)) + 2 {
                        let offset = col % 2 == 0 ? 0 : hexHeight / 2
                        let center = CGPoint(x: CGFloat(col) * hexSize * 1.5, y: CGFloat(row) * hexHeight + offset)
                        var hex = Path()
                        for i in 0..<6 {
                            let angle = Double(i) * (.pi / 3)
                            let point = CGPoint(
                                x: center.x + hexSize * CGFloat(cos(angle)),
                                y: center.y + hexSize * CGFloat(sin(angle))
                            )
                            if i == 0 { hex.move(to: point) } else { hex.addLine(to: point) }
                        }
                        hex.closeSubpath()
                        context.stroke(hex, with: .color(Color.cyan.opacity(0.28)), lineWidth: 1.2)
                    }
                }
            }
            LinearGradient(colors: [Color.cyan.opacity(0.5), Color.blue.opacity(0.2), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                .blur(radius: 40)
            RadialGradient(colors: [Color.cyan.opacity(0.4), Color.clear], center: .center, startRadius: 0, endRadius: max(size.width, size.height) * 0.6)
        }
        .blendMode(.screen)
    }
}

struct Retro50sOrnamentView: View {
    let size: CGSize
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .stroke(Color.gray.opacity(0.75), lineWidth: 8)
                .frame(height: 20)
                .padding(.horizontal, 40)
            Spacer()
            HStack(spacing: 0) {
                ForEach(0..<12, id: \.self) { index in
                    Rectangle()
                        .fill(index % 2 == 0 ? Color.black.opacity(0.25) : Color.white.opacity(0.1))
                        .frame(width: size.width / 12)
                }
            }
            .frame(height: 40)
        }
        .padding(.vertical, 24)
    }
}

struct WesternOrnamentView: View {
    let size: CGSize
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color(red: 0.9, green: 0.75, blue: 0.45).opacity(0.7), lineWidth: 5)
                .padding(20)
            
            Canvas { context, canvasSize in
                let margin: CGFloat = 40
                var path = Path()
                path.move(to: CGPoint(x: margin, y: margin))
                for x in stride(from: margin, to: canvasSize.width - margin, by: 30) {
                    path.addCurve(
                        to: CGPoint(x: x + 15, y: margin + 12 * sin(Double(x) * 0.04)),
                        control1: CGPoint(x: x + 5, y: margin - 16),
                        control2: CGPoint(x: x + 10, y: margin + 16)
                    )
                }
                context.stroke(path, with: .color(Color(red: 0.9, green: 0.75, blue: 0.45).opacity(0.65)), lineWidth: 1.6)
            }
        }
    }
}

struct ArtNouveauOrnamentView: View {
    let size: CGSize
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                let offset = CGFloat(index) * 30
                Path { path in
                    path.move(to: CGPoint(x: 20, y: 20 + offset))
                    path.addCurve(
                        to: CGPoint(x: size.width - 20, y: size.height - 20 - offset),
                        control1: CGPoint(x: size.width * 0.35, y: offset),
                        control2: CGPoint(x: size.width * 0.65, y: size.height - offset)
                    )
                }
                .stroke(Color(red: 0.8, green: 0.7, blue: 0.4).opacity(0.35), lineWidth: 1.5)
            }
        }
    }
}

struct ZenOrnamentView: View {
    let size: CGSize
    var body: some View {
        ZStack {
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width * 0.7, y: canvasSize.height * 0.3)
                for radius in stride(from: 20, to: 150, by: 12) {
                    let rect = CGRect(x: center.x - CGFloat(radius), y: center.y - CGFloat(radius), width: CGFloat(radius * 2), height: CGFloat(radius * 2))
                    context.stroke(Path(ellipseIn: rect), with: .color(Color.black.opacity(0.18)), lineWidth: 1.2)
                }
            }
            LinearGradient(colors: [Color.black.opacity(0.16), Color.clear], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct ArtDecoOrnamentView: View {
    let size: CGSize
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { step in
                RoundedRectangle(cornerRadius: CGFloat(4 - step))
                    .stroke(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.35 + Double(step) * 0.08), lineWidth: CGFloat(3 - step))
                    .padding(CGFloat(step) * 8 + 10)
            }
            
            VStack {
                Rectangle()
                    .fill(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.25))
                    .frame(height: 4)
                Spacer()
                Rectangle()
                    .fill(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.25))
                    .frame(height: 4)
            }
        }
    }
}

struct SteampunkOrnamentView: View {
    let size: CGSize
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * (.pi / 4)
                GearOutline(radius: CGFloat(40 + index * 8))
                    .stroke(Color(red: 0.72, green: 0.45, blue: 0.2).opacity(0.22), lineWidth: 1.3)
                    .rotationEffect(.radians(angle))
            }
        }
    }
}

struct GearOutline: Shape {
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let teeth = 12
        let inner = radius * 0.8
        for tooth in 0..<teeth {
            let angle = Double(tooth) * (2 * .pi / Double(teeth))
            let p1 = CGPoint(x: center.x + inner * CGFloat(cos(angle)), y: center.y + inner * CGFloat(sin(angle)))
            let p2 = CGPoint(x: center.x + radius * CGFloat(cos(angle + 0.1)), y: center.y + radius * CGFloat(sin(angle + 0.1)))
            if tooth == 0 { path.move(to: p1) } else { path.addLine(to: p1) }
            path.addLine(to: p2)
        }
        path.closeSubpath()
        return path
    }
}

struct BauhausOrnamentView: View {
    let size: CGSize
    var body: some View {
        Canvas { context, canvasSize in
            let cols = [canvasSize.width * 0.25, canvasSize.width * 0.55]
            let rows = [canvasSize.height * 0.2, canvasSize.height * 0.45, canvasSize.height * 0.7]
            for x in cols {
                var line = Path()
                line.move(to: CGPoint(x: x, y: 0))
                line.addLine(to: CGPoint(x: x, y: canvasSize.height))
                context.stroke(line, with: .color(Color.black.opacity(0.35)), lineWidth: 2)
            }
            for y in rows {
                var line = Path()
                line.move(to: CGPoint(x: 0, y: y))
                line.addLine(to: CGPoint(x: canvasSize.width, y: y))
                context.stroke(line, with: .color(Color.black.opacity(0.35)), lineWidth: 2)
            }
            let rect = CGRect(x: canvasSize.width * 0.55, y: canvasSize.height * 0.45, width: canvasSize.width * 0.2, height: canvasSize.height * 0.25)
            context.fill(Path(rect), with: .color(Color.red.opacity(0.25)))
        }
    }
}

struct TropicalOrnamentView: View {
    let size: CGSize
    var body: some View {
        ZStack(alignment: .topTrailing) {
            PalmFrondShape()
                .stroke(Color.green.opacity(0.25), lineWidth: 4)
                .scaleEffect(1.2)
                .offset(x: -size.width * 0.2, y: -size.height * 0.2)
            Circle()
                .stroke(Color.pink.opacity(0.35), lineWidth: 3)
                .frame(width: 60, height: 60)
                .offset(x: -40, y: 40)
        }
    }
}

struct PalmFrondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.midY - 80))
        for i in 0..<10 {
            let t = CGFloat(i) / 10
            let start = CGPoint(x: rect.minX + (rect.width * t), y: rect.midY - t * 40)
            let end = CGPoint(x: start.x + 60, y: start.y - 40)
            path.move(to: start)
            path.addQuadCurve(to: end, control: CGPoint(x: start.x + 25, y: start.y - 50))
        }
        return path
    }
}

struct GothicOrnamentView: View {
    let size: CGSize
    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                PointedArch()
                    .stroke(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.3), lineWidth: 2.4)
                    .scaleEffect(CGFloat(1 + index) * 0.2)
            }
            Circle()
                .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(0.35), lineWidth: 3)
                .frame(width: 120, height: 120)
        }
    }
}

struct PointedArch: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = min(rect.width, rect.height)
        let base = CGRect(x: rect.midX - width / 2, y: rect.midY, width: width, height: width / 2)
        path.move(to: CGPoint(x: base.minX, y: base.maxY))
        path.addQuadCurve(to: CGPoint(x: base.midX, y: base.minY - width / 4), control: CGPoint(x: base.minX, y: base.minY))
        path.addQuadCurve(to: CGPoint(x: base.maxX, y: base.maxY), control: CGPoint(x: base.maxX, y: base.minY))
        return path
    }
}
