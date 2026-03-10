import SwiftUI

struct WoodShaderParameters {
    var ringDensity: CGFloat = 16
    var grainRoughness: CGFloat = 0.45
    var colorVariation: CGFloat = 0.25
    var stretch: CGFloat = 4.5
    var orientation: CGFloat = .pi / 2
    var sheenStrength: CGFloat = 0.08
    var lightColor: Color = Color(red: 0.93, green: 0.82, blue: 0.64)
    var darkColor: Color = Color(red: 0.55, green: 0.32, blue: 0.16)

    func shader(size: CGSize, time: TimeInterval = 0) -> Shader {
        let function = ShaderFunction(library: ShaderLibrary.default, name: "woodColorEffect")
        return Shader(function: function, arguments: arguments(for: size, time: time))
    }

    private func arguments(for size: CGSize, time: TimeInterval) -> [Shader.Argument] {
        let light = lightColor.simdColor
        let dark = darkColor.simdColor
        return [
            .float2(Float(size.width), Float(size.height)),
            .float(Float(ringDensity)),
            .float(Float(grainRoughness)),
            .float(Float(colorVariation)),
            .float(Float(stretch)),
            .float(Float(orientation)),
            .float(Float(sheenStrength)),
            .float(Float(time)),
            .float4(light.x, light.y, light.z, light.w),
            .float4(dark.x, dark.y, dark.z, dark.w)
        ]
    }
}

struct WoodShaderModifier: ViewModifier {
    var parameters: WoodShaderParameters
    var animated: Bool

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let render = content
                .frame(width: proxy.size.width, height: proxy.size.height)

            if animated {
                TimelineView(.animation) { timeline in
                    let shader = parameters.shader(
                        size: proxy.size,
                        time: timeline.date.timeIntervalSinceReferenceDate
                    )
                    render.layerEffect(shader, maxSampleOffset: .zero)
                }
            } else {
                let shader = parameters.shader(size: proxy.size)
                render.layerEffect(shader, maxSampleOffset: .zero)
            }
        }
    }
}

extension View {
    func woodShader(_ parameters: WoodShaderParameters = WoodShaderParameters(), animated: Bool = false) -> some View {
        modifier(WoodShaderModifier(parameters: parameters, animated: animated))
    }
}

private extension Color {
    var simdColor: SIMD4<Float> {
        #if canImport(UIKit)
        let ui = UIColor(self)
        #else
        let ui = NSColor(self)
        #endif
        let components = ui.cgColor.components ?? [1, 1, 1, 1]
        let r = Float(components.count >= 1 ? components[0] : 1)
        let g = Float(components.count >= 2 ? components[1] : 1)
        let b = Float(components.count >= 3 ? components[2] : 1)
        let a = Float(components.count >= 4 ? components[3] : components.last ?? 1)
        return SIMD4(r, g, b, a)
    }
}

struct WoodShaderPreview: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(Color.black.opacity(0.2), lineWidth: 1)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
                    .woodShader(
                        WoodShaderParameters(
                            ringDensity: 14,
                            grainRoughness: 0.5,
                            colorVariation: 0.3,
                            stretch: 5.5,
                            orientation: .pi / 2,
                            sheenStrength: 0.1,
                            lightColor: Color(red: 0.92, green: 0.78, blue: 0.58),
                            darkColor: Color(red: 0.42, green: 0.24, blue: 0.12)
                        ),
                        animated: false
                    )
            )
            .frame(height: 160)
            .padding()
    }
}

#Preview("Wood Shader") {
    WoodShaderPreview()
}
