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
}

struct WoodShaderModifier: ViewModifier {
    var parameters: WoodShaderParameters
    var animated: Bool

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                woodFill(size: size)

                content
                    .frame(width: size.width, height: size.height)
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        }
    }

    private func woodFill(size: CGSize) -> some View {
        let stripeCount = max(Int(parameters.ringDensity.rounded()), 8)
        let stripeHeight = max(size.height / CGFloat(max(stripeCount, 1)), 1)
        let rotation = Angle(radians: Double(parameters.orientation))
        let lightOpacity = min(max(0.08 + parameters.colorVariation * 0.22 + parameters.sheenStrength * 0.18, 0.08), 0.4)
        let darkOpacity = min(max(0.06 + parameters.grainRoughness * 0.20, 0.06), 0.3)

        return ZStack {
            LinearGradient(
                colors: [
                    parameters.darkColor,
                    parameters.lightColor,
                    parameters.darkColor.opacity(0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                ForEach(0..<stripeCount, id: \.self) { index in
                    Rectangle()
                        .fill(
                            index.isMultiple(of: 2)
                                ? parameters.lightColor.opacity(lightOpacity)
                                : parameters.darkColor.opacity(darkOpacity)
                        )
                        .frame(height: stripeHeight)
                }
            }
            .frame(width: size.width, height: size.height)
            .rotationEffect(rotation)
            .scaleEffect(x: max(parameters.stretch, 1), y: 1, anchor: .center)
            .blur(radius: max(parameters.grainRoughness * 2.4, 0.2))

            LinearGradient(
                colors: [
                    Color.white.opacity(parameters.sheenStrength * 0.9),
                    .clear,
                    Color.black.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension View {
    func woodShader(_ parameters: WoodShaderParameters = WoodShaderParameters(), animated: Bool = false) -> some View {
        modifier(WoodShaderModifier(parameters: parameters, animated: animated))
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
