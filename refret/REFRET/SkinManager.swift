import SwiftUI
import Combine

class SkinManager: ObservableObject {
    @Published var currentSkin: SkinTheme = .blank
    
    enum SkinTheme: String, CaseIterable, Identifiable {
        case blank = "Blank Canvas"
        case empty = "Empty Stage"
        case `default` = "Default"
        case futuristic = "Futuristic"
        case retro50s = "1950s Diner"
        case western = "Western Leather"
        case artNouveau = "Art Nouveau"
        case zen = "Japanese Zen"
        case artDeco = "Art Deco"
        case steampunk = "Steampunk"
        case bauhaus = "Bauhaus"
        case tropical = "Tropical Paradise"
        case gothic = "Gothic Cathedral"
        
        var id: String { rawValue }
    }

    struct ColorScheme {
        let background: Color
        let primary: Color
        let secondary: Color
        let accent: Color
        let details: Color
        let buttonFill: Color
        let buttonBorder: Color
        let stringColor: Color
        let fretColor: Color
        let textColor: Color
        let thermometerBlock: Color
        let thermometerLine: Color
        let circleLit: Color
        let circleUnlit: Color
        let circleWrong: Color
        
        let fontName: String
        let fontWeight: Font.Weight
        let fontSize: CGFloat
        let letterSpacing: CGFloat
        let textShadow: Bool
        let textShadowColor: Color
        let textShadowOffset: CGSize
        let textShadowBlur: CGFloat
        
        let hasTexture: Bool
        let textureType: TextureType
        let roughness: Double
        let shininess: Double
        let transparency: Double
        let hasEmboss: Bool
        let hasInnerShadow: Bool
        let hasGlassEffect: Bool
        
        let hasScrews: Bool
        let hasStitching: Bool
        let screwColor: Color
        let stitchingColor: Color
        
        enum TextureType {
            case none, wood, leather, metal, plastic, glass, paper, stone, fabric
        }
    }

    var colors: ColorScheme {
        switch currentSkin {
        case .blank:
            return ColorScheme(
                background: Color.black,
                primary: Color.white,
                secondary: Color.gray,
                accent: Color.white,
                details: Color.clear,
                buttonFill: Color.white.opacity(0.12),
                buttonBorder: Color.white.opacity(0.2),
                stringColor: Color.white.opacity(0.4),
                fretColor: Color.white.opacity(0.1),
                textColor: Color.white,
                thermometerBlock: Color.white.opacity(0.4),
                thermometerLine: Color.white.opacity(0.3),
                circleLit: Color.white.opacity(0.5),
                circleUnlit: Color.white.opacity(0.15),
                circleWrong: Color.red.opacity(0.7),
                fontName: "HelveticaNeue",
                fontWeight: .regular,
                fontSize: 18,
                letterSpacing: 0,
                textShadow: false,
                textShadowColor: .clear,
                textShadowOffset: .zero,
                textShadowBlur: 0,
                hasTexture: false,
                textureType: .none,
                roughness: 0,
                shininess: 0,
                transparency: 0,
                hasEmboss: false,
                hasInnerShadow: false,
                hasGlassEffect: false,
                hasScrews: false,
                hasStitching: false,
                screwColor: .clear,
                stitchingColor: .clear
            )
        case .empty:
            return ColorScheme(
                background: Color.black,
                primary: Color.clear,
                secondary: Color.clear,
                accent: Color.clear,
                details: Color.clear,
                buttonFill: Color.clear,
                buttonBorder: Color.clear,
                stringColor: Color.clear,
                fretColor: Color.clear,
                textColor: Color.clear,
                thermometerBlock: Color.clear,
                thermometerLine: Color.clear,
                circleLit: Color.clear,
                circleUnlit: Color.clear,
                circleWrong: Color.clear,
                fontName: "HelveticaNeue",
                fontWeight: .regular,
                fontSize: 18,
                letterSpacing: 0,
                textShadow: false,
                textShadowColor: .clear,
                textShadowOffset: .zero,
                textShadowBlur: 0,
                hasTexture: false,
                textureType: .none,
                roughness: 0,
                shininess: 0,
                transparency: 0,
                hasEmboss: false,
                hasInnerShadow: false,
                hasGlassEffect: false,
                hasScrews: false,
                hasStitching: false,
                screwColor: .clear,
                stitchingColor: .clear
            )
        case .default:
            return ColorScheme(
                background: Color.black,
                primary: Color.white,
                secondary: Color.gray,
                accent: Color.orange,
                details: Color.white.opacity(0.8),
                buttonFill: Color.orange.opacity(0.8),
                buttonBorder: Color.white,
                stringColor: Color.white.opacity(0.8),
                fretColor: Color.gray.opacity(0.7),
                textColor: Color.white,
                thermometerBlock: Color.orange,
                thermometerLine: Color.white,
                circleLit: Color.green,
                circleUnlit: Color.white.opacity(0.3),
                circleWrong: Color.red,
                fontName: "DINAlternate-Bold",
                fontWeight: .bold,
                fontSize: 18,
                letterSpacing: 2,
                textShadow: true,
                textShadowColor: Color.black.opacity(0.6),
                textShadowOffset: CGSize(width: 0, height: 1),
                textShadowBlur: 3,
                hasTexture: true,
                textureType: .metal,
                roughness: 0.4,
                shininess: 0.9,
                transparency: 0.0,
                hasEmboss: false,
                hasInnerShadow: true,
                hasGlassEffect: false,
                hasScrews: true,
                hasStitching: false,
                screwColor: Color.gray,
                stitchingColor: Color.clear
            )
        case .futuristic:
            return ColorScheme(
                background: Color(red: 0.02, green: 0.02, blue: 0.08),
                primary: Color.cyan,
                secondary: Color.blue.opacity(0.7),
                accent: Color.cyan,
                details: Color.white.opacity(0.6),
                buttonFill: Color(red: 0.0, green: 1.0, blue: 1.0).opacity(0.4),
                buttonBorder: Color.cyan,
                stringColor: Color.cyan,
                fretColor: Color.white.opacity(0.2),
                textColor: Color.cyan,
                thermometerBlock: Color.cyan,
                thermometerLine: Color.white,
                circleLit: Color.cyan,
                circleUnlit: Color.white.opacity(0.2),
                circleWrong: Color.red,
                fontName: "EurostileLTStd-Bold",
                fontWeight: .bold,
                fontSize: 16,
                letterSpacing: 1.5,
                textShadow: true,
                textShadowColor: Color.cyan.opacity(0.6),
                textShadowOffset: CGSize(width: 0, height: 0),
                textShadowBlur: 6,
                hasTexture: true,
                textureType: .glass,
                roughness: 0.2,
                shininess: 1.0,
                transparency: 0.3,
                hasEmboss: false,
                hasInnerShadow: false,
                hasGlassEffect: true,
                hasScrews: false,
                hasStitching: false,
                screwColor: Color.clear,
                stitchingColor: Color.clear
            )
        case .retro50s:
            return ColorScheme(
                background: Color(red: 0.94, green: 0.95, blue: 0.9),
                primary: Color(red: 0.9, green: 0.33, blue: 0.42),
                secondary: Color(red: 0.4, green: 0.6, blue: 0.7),
                accent: Color(red: 0.98, green: 0.81, blue: 0.56),
                details: Color(red: 0.7, green: 0.7, blue: 0.7),
                buttonFill: Color(red: 1.0, green: 0.65, blue: 0.75),
                buttonBorder: Color.gray,
                stringColor: Color(red: 0.6, green: 0.6, blue: 0.6),
                fretColor: Color(red: 0.8, green: 0.8, blue: 0.8),
                textColor: Color.black,
                thermometerBlock: Color(red: 0.98, green: 0.5, blue: 0.55),
                thermometerLine: Color.gray,
                circleLit: Color.green,
                circleUnlit: Color.black.opacity(0.1),
                circleWrong: Color.red,
                fontName: "Futura-Bold",
                fontWeight: .bold,
                fontSize: 18,
                letterSpacing: 1,
                textShadow: false,
                textShadowColor: .clear,
                textShadowOffset: .zero,
                textShadowBlur: 0,
                hasTexture: true,
                textureType: .plastic,
                roughness: 0.2,
                shininess: 0.8,
                transparency: 0.0,
                hasEmboss: true,
                hasInnerShadow: false,
                hasGlassEffect: false,
                hasScrews: false,
                hasStitching: false,
                screwColor: .clear,
                stitchingColor: .clear
            )
        case .western:
            return ColorScheme(
                background: Color(red: 0.32, green: 0.18, blue: 0.08),
                primary: Color(red: 0.8, green: 0.65, blue: 0.4),
                secondary: Color(red: 0.5, green: 0.3, blue: 0.15),
                accent: Color(red: 0.63, green: 0.32, blue: 0.18),
                details: Color(red: 0.82, green: 0.71, blue: 0.55),
                buttonFill: Color(red: 0.6, green: 0.3, blue: 0.15),
                buttonBorder: Color(red: 0.72, green: 0.45, blue: 0.2),
                stringColor: Color(red: 0.9, green: 0.8, blue: 0.6),
                fretColor: Color(red: 0.45, green: 0.25, blue: 0.12),
                textColor: Color(red: 0.97, green: 0.9, blue: 0.78),
                thermometerBlock: Color(red: 0.8, green: 0.55, blue: 0.3),
                thermometerLine: Color(red: 0.9, green: 0.8, blue: 0.6),
                circleLit: Color.green,
                circleUnlit: Color.black.opacity(0.2),
                circleWrong: Color.red,
                fontName: "Rockwell-Bold",
                fontWeight: .heavy,
                fontSize: 20,
                letterSpacing: 3,
                textShadow: true,
                textShadowColor: Color.black.opacity(0.5),
                textShadowOffset: CGSize(width: 0, height: 2),
                textShadowBlur: 4,
                hasTexture: true,
                textureType: .leather,
                roughness: 0.8,
                shininess: 0.1,
                transparency: 0.0,
                hasEmboss: true,
                hasInnerShadow: true,
                hasGlassEffect: false,
                hasScrews: true,
                hasStitching: true,
                screwColor: Color(red: 0.6, green: 0.6, blue: 0.6),
                stitchingColor: Color(red: 0.97, green: 0.9, blue: 0.78)
            )
        case .artNouveau:
            return ColorScheme(
                background: Color(red: 0.99, green: 0.97, blue: 0.92),
                primary: Color(red: 0.53, green: 0.66, blue: 0.42),
                secondary: Color(red: 0.65, green: 0.49, blue: 0.37),
                accent: Color(red: 0.8, green: 0.7, blue: 0.3),
                details: Color(red: 0.4, green: 0.3, blue: 0.2),
                buttonFill: Color(red: 0.53, green: 0.66, blue: 0.42),
                buttonBorder: Color(red: 0.8, green: 0.7, blue: 0.3),
                stringColor: Color(red: 0.4, green: 0.3, blue: 0.2),
                fretColor: Color(red: 0.8, green: 0.7, blue: 0.3),
                textColor: Color(red: 0.33, green: 0.26, blue: 0.21),
                thermometerBlock: Color(red: 0.8, green: 0.6, blue: 0.3),
                thermometerLine: Color(red: 0.4, green: 0.3, blue: 0.2),
                circleLit: Color.green,
                circleUnlit: Color.black.opacity(0.2),
                circleWrong: Color.red,
                fontName: "BradleyHandITCTT-Bold",
                fontWeight: .bold,
                fontSize: 20,
                letterSpacing: 1.5,
                textShadow: false,
                textShadowColor: .clear,
                textShadowOffset: .zero,
                textShadowBlur: 0,
                hasTexture: true,
                textureType: .fabric,
                roughness: 0.3,
                shininess: 0.1,
                transparency: 0.0,
                hasEmboss: true,
                hasInnerShadow: false,
                hasGlassEffect: false,
                hasScrews: false,
                hasStitching: true,
                screwColor: .clear,
                stitchingColor: Color(red: 0.4, green: 0.3, blue: 0.2)
            )
        case .zen:
            return ColorScheme(
                background: Color(red: 0.95, green: 0.95, blue: 0.92),
                primary: Color(red: 0.56, green: 0.74, blue: 0.56),
                secondary: Color(red: 0.73, green: 0.66, blue: 0.56),
                accent: Color(red: 0.18, green: 0.31, blue: 0.31),
                details: Color(red: 0.35, green: 0.45, blue: 0.35),
                buttonFill: Color(red: 0.56, green: 0.74, blue: 0.56),
                buttonBorder: Color(red: 0.18, green: 0.31, blue: 0.31),
                stringColor: Color(red: 0.35, green: 0.35, blue: 0.35),
                fretColor: Color(red: 0.75, green: 0.7, blue: 0.6),
                textColor: Color(red: 0.2, green: 0.2, blue: 0.2),
                thermometerBlock: Color(red: 0.3, green: 0.5, blue: 0.4),
                thermometerLine: Color(red: 0.2, green: 0.2, blue: 0.2),
                circleLit: Color.green,
                circleUnlit: Color.black.opacity(0.2),
                circleWrong: Color.red,
                fontName: "Avenir-Heavy",
                fontWeight: .heavy,
                fontSize: 18,
                letterSpacing: 1,
                textShadow: false,
                textShadowColor: .clear,
                textShadowOffset: .zero,
                textShadowBlur: 0,
                hasTexture: true,
                textureType: .stone,
                roughness: 0.5,
                shininess: 0.05,
                transparency: 0.0,
                hasEmboss: false,
                hasInnerShadow: true,
                hasGlassEffect: false,
                hasScrews: false,
                hasStitching: false,
                screwColor: .clear,
                stitchingColor: .clear
            )
        case .artDeco:
            return ColorScheme(
                background: Color(red: 0.05, green: 0.05, blue: 0.2),
                primary: Color(red: 1.0, green: 0.84, blue: 0.0),
                secondary: Color(red: 0.4, green: 0.4, blue: 0.4),
                accent: Color(red: 0.9, green: 0.7, blue: 0.2),
                details: Color(red: 0.8, green: 0.6, blue: 0.4),
                buttonFill: Color(red: 0.1, green: 0.1, blue: 0.44),
                buttonBorder: Color(red: 1.0, green: 0.84, blue: 0.0),
                stringColor: Color(red: 0.8, green: 0.6, blue: 0.4),
                fretColor: Color(red: 0.5, green: 0.5, blue: 0.5),
                textColor: Color(red: 1.0, green: 0.84, blue: 0.0),
                thermometerBlock: Color(red: 0.9, green: 0.7, blue: 0.2),
                thermometerLine: Color(red: 0.5, green: 0.5, blue: 0.5),
                circleLit: Color.green,
                circleUnlit: Color.black.opacity(0.2),
                circleWrong: Color.red,
                fontName: "Didot-Bold",
                fontWeight: .bold,
                fontSize: 22,
                letterSpacing: 2,
                textShadow: true,
                textShadowColor: Color.black.opacity(0.7),
                textShadowOffset: CGSize(width: 0, height: 3),
                textShadowBlur: 5,
                hasTexture: true,
                textureType: .metal,
                roughness: 0.2,
                shininess: 0.9,
                transparency: 0.0,
                hasEmboss: true,
                hasInnerShadow: true,
                hasGlassEffect: false,
                hasScrews: true,
                hasStitching: false,
                screwColor: Color(red: 1.0, green: 0.84, blue: 0.0),
                stitchingColor: .clear
            )
        case .steampunk:
            return ColorScheme(
                background: Color(red: 0.2, green: 0.12, blue: 0.08),
                primary: Color(red: 0.72, green: 0.45, blue: 0.2),
                secondary: Color(red: 0.42, green: 0.32, blue: 0.28),
                accent: Color(red: 0.82, green: 0.71, blue: 0.55),
                details: Color(red: 0.3, green: 0.3, blue: 0.3),
                buttonFill: Color(red: 0.72, green: 0.45, blue: 0.2),
                buttonBorder: Color(red: 0.3, green: 0.3, blue: 0.3),
                stringColor: Color(red: 0.82, green: 0.71, blue: 0.55),
                fretColor: Color(red: 0.26, green: 0.2, blue: 0.15),
                textColor: Color(red: 0.9, green: 0.8, blue: 0.6),
                thermometerBlock: Color(red: 0.7, green: 0.4, blue: 0.2),
                thermometerLine: Color(red: 0.5, green: 0.3, blue: 0.2),
                circleLit: Color.green,
                circleUnlit: Color.black.opacity(0.2),
                circleWrong: Color.red,
                fontName: "Copperplate",
                fontWeight: .bold,
                fontSize: 19,
                letterSpacing: 2,
                textShadow: true,
                textShadowColor: Color.black.opacity(0.6),
                textShadowOffset: CGSize(width: 0, height: 2),
                textShadowBlur: 4,
                hasTexture: true,
                textureType: .metal,
                roughness: 0.5,
                shininess: 0.4,
                transparency: 0.0,
                hasEmboss: true,
                hasInnerShadow: true,
                hasGlassEffect: false,
                hasScrews: true,
                hasStitching: false,
                screwColor: Color(red: 0.72, green: 0.45, blue: 0.2),
                stitchingColor: .clear
            )
        case .bauhaus:
            return ColorScheme(
                background: Color.white,
                primary: Color.black,
                secondary: Color.gray,
                accent: Color.red,
                details: Color.blue,
                buttonFill: Color.red,
                buttonBorder: Color.black,
                stringColor: Color.black,
                fretColor: Color.gray,
                textColor: Color.black,
                thermometerBlock: Color.red,
                thermometerLine: Color.black,
                circleLit: Color.green,
                circleUnlit: Color.black.opacity(0.2),
                circleWrong: Color.red,
                fontName: "HelveticaNeue-CondensedBold",
                fontWeight: .black,
                fontSize: 18,
                letterSpacing: 1,
                textShadow: false,
                textShadowColor: .clear,
                textShadowOffset: .zero,
                textShadowBlur: 0,
                hasTexture: true,
                textureType: .paper,
                roughness: 0.1,
                shininess: 0.0,
                transparency: 0.0,
                hasEmboss: false,
                hasInnerShadow: false,
                hasGlassEffect: false,
                hasScrews: false,
                hasStitching: false,
                screwColor: .clear,
                stitchingColor: .clear
            )
        case .tropical:
            return ColorScheme(
                background: Color(red: 0.92, green: 0.84, blue: 0.7),
                primary: Color(red: 0.13, green: 0.55, blue: 0.13),
                secondary: Color(red: 1.0, green: 0.41, blue: 0.71),
                accent: Color(red: 0.99, green: 0.76, blue: 0.34),
                details: Color(red: 0.65, green: 0.4, blue: 0.2),
                buttonFill: Color(red: 1.0, green: 0.41, blue: 0.71),
                buttonBorder: Color(red: 0.13, green: 0.55, blue: 0.13),
                stringColor: Color(red: 0.35, green: 0.2, blue: 0.1),
                fretColor: Color(red: 0.8, green: 0.6, blue: 0.4),
                textColor: Color(red: 0.2, green: 0.2, blue: 0.2),
                thermometerBlock: Color(red: 0.99, green: 0.57, blue: 0.35),
                thermometerLine: Color(red: 0.35, green: 0.2, blue: 0.1),
                circleLit: Color.green,
                circleUnlit: Color.black.opacity(0.2),
                circleWrong: Color.red,
                fontName: "MarkerFelt-Wide",
                fontWeight: .bold,
                fontSize: 20,
                letterSpacing: 1,
                textShadow: true,
                textShadowColor: Color.black.opacity(0.3),
                textShadowOffset: CGSize(width: 0, height: 2),
                textShadowBlur: 3,
                hasTexture: true,
                textureType: .wood,
                roughness: 0.4,
                shininess: 0.2,
                transparency: 0.0,
                hasEmboss: true,
                hasInnerShadow: false,
                hasGlassEffect: false,
                hasScrews: false,
                hasStitching: true,
                screwColor: .clear,
                stitchingColor: Color(red: 0.99, green: 0.76, blue: 0.34)
            )
        case .gothic:
            return ColorScheme(
                background: Color(red: 0.16, green: 0.16, blue: 0.18),
                primary: Color(red: 0.8, green: 0.7, blue: 0.4),
                secondary: Color(red: 0.4, green: 0.4, blue: 0.4),
                accent: Color(red: 0.3, green: 0.36, blue: 0.5),
                details: Color(red: 0.6, green: 0.5, blue: 0.3),
                buttonFill: Color(red: 0.1, green: 0.1, blue: 0.3),
                buttonBorder: Color(red: 1.0, green: 0.84, blue: 0.0),
                stringColor: Color(red: 0.8, green: 0.7, blue: 0.4),
                fretColor: Color(red: 0.4, green: 0.4, blue: 0.4),
                textColor: Color(red: 0.9, green: 0.85, blue: 0.6),
                thermometerBlock: Color(red: 0.9, green: 0.75, blue: 0.4),
                thermometerLine: Color(red: 0.5, green: 0.5, blue: 0.5),
                circleLit: Color.green,
                circleUnlit: Color.black.opacity(0.2),
                circleWrong: Color.red,
                fontName: "TrajanPro-Bold",
                fontWeight: .bold,
                fontSize: 22,
                letterSpacing: 2,
                textShadow: true,
                textShadowColor: Color.black.opacity(0.8),
                textShadowOffset: CGSize(width: 0, height: 3),
                textShadowBlur: 5,
                hasTexture: true,
                textureType: .stone,
                roughness: 0.7,
                shininess: 0.1,
                transparency: 0.0,
                hasEmboss: true,
                hasInnerShadow: true,
                hasGlassEffect: false,
                hasScrews: true,
                hasStitching: false,
                screwColor: Color(red: 1.0, green: 0.84, blue: 0.0),
                stitchingColor: .clear
            )
        }
    }
}

extension SkinManager.SkinTheme {
    var disablesTextures: Bool { self == .blank || self == .empty }
    var hidesInterface: Bool { self == .empty }
}
