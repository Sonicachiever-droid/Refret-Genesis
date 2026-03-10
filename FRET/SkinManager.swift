import SwiftUI
import Combine

class SkinManager: ObservableObject {
    @Published var currentSkin: SkinTheme = .default
    
    enum SkinTheme: String, CaseIterable {
        case `default` = "Default"
        case futuristic = "Futuristic"
        case diner1950s = "1950s Diner"
        case western = "Western Leather"
        case artNouveau = "Art Nouveau"
        case zen = "Japanese Zen"
        case artDeco = "Art Deco"
        case steampunk = "Steampunk"
        case bauhaus = "Bauhaus"
        case tropical = "Tropical Paradise"
        case gothic = "Gothic Cathedral"
    }
    
    var colors: SkinColors {
        switch currentSkin {
        case .default:
            return SkinColors(
                background: Color(red: 0.1, green: 0.1, blue: 0.1),
                fretboard: Color(red: 0.8, green: 0.7, blue: 0.6),
                string: Color(red: 0.9, green: 0.9, blue: 0.9),
                fret: Color(red: 0.3, green: 0.3, blue: 0.3),
                thermometerBlock: Color.red,
                thermometerLine: Color(red: 0.8, green: 0.0, blue: 0.0),
                buttonFill: Color(red: 0.7, green: 0.6, blue: 0.5),
                buttonBorder: Color(red: 0.4, green: 0.3, blue: 0.2),
                fontName: "Avenir",
                fontSize: 20.0,
                fontWeight: .medium,
                textColor: Color.black,
                letterSpacing: 0.0,
                textShadow: false,
                textShadowColor: Color.clear,
                textShadowBlur: 0.0,
                hasTexture: true
            )
        case .futuristic:
            return SkinColors(
                background: Color(red: 0.05, green: 0.05, blue: 0.1),
                fretboard: Color(red: 0.2, green: 0.3, blue: 0.4),
                string: Color(red: 0.0, green: 1.0, blue: 1.0),
                fret: Color(red: 1.0, green: 0.0, blue: 1.0),
                thermometerBlock: Color.cyan,
                thermometerLine: Color(red: 0.0, green: 1.0, blue: 1.0),
                buttonFill: Color(red: 0.1, green: 0.2, blue: 0.3),
                buttonBorder: Color.cyan,
                fontName: "SF Pro Display",
                fontSize: 20.0,
                fontWeight: .bold,
                textColor: Color.cyan,
                letterSpacing: 2.0,
                textShadow: true,
                textShadowColor: Color.cyan,
                textShadowBlur: 5.0,
                hasTexture: false
            )
        case .diner1950s:
            return SkinColors(
                background: Color(red: 0.9, green: 0.8, blue: 0.7),
                fretboard: Color(red: 0.8, green: 0.4, blue: 0.2),
                string: Color(red: 0.7, green: 0.7, blue: 0.7),
                fret: Color(red: 0.5, green: 0.3, blue: 0.1),
                thermometerBlock: Color(red: 0.8, green: 0.2, blue: 0.2),
                thermometerLine: Color(red: 1.0, green: 0.0, blue: 0.0),
                buttonFill: Color(red: 0.9, green: 0.7, blue: 0.5),
                buttonBorder: Color(red: 0.6, green: 0.4, blue: 0.2),
                fontName: "American Typewriter",
                fontSize: 22.0,
                fontWeight: .bold,
                textColor: Color(red: 0.3, green: 0.1, blue: 0.0),
                letterSpacing: 1.0,
                textShadow: false,
                textShadowColor: Color.clear,
                textShadowBlur: 0.0,
                hasTexture: true
            )
        default:
            return SkinColors(
                background: Color(red: 0.1, green: 0.1, blue: 0.1),
                fretboard: Color(red: 0.8, green: 0.7, blue: 0.6),
                string: Color(red: 0.9, green: 0.9, blue: 0.9),
                fret: Color(red: 0.3, green: 0.3, blue: 0.3),
                thermometerBlock: Color.red,
                thermometerLine: Color(red: 0.8, green: 0.0, blue: 0.0),
                buttonFill: Color(red: 0.7, green: 0.6, blue: 0.5),
                buttonBorder: Color(red: 0.4, green: 0.3, blue: 0.2),
                fontName: "Avenir",
                fontSize: 20.0,
                fontWeight: .medium,
                textColor: Color.black,
                letterSpacing: 0.0,
                textShadow: false,
                textShadowColor: Color.clear,
                textShadowBlur: 0.0,
                hasTexture: true
            )
        }
    }
    
    func setSkin(_ skin: SkinTheme) {
        currentSkin = skin
    }
}

struct SkinColors {
    let background: Color
    let fretboard: Color
    let string: Color
    let fret: Color
    let thermometerBlock: Color
    let thermometerLine: Color
    let buttonFill: Color
    let buttonBorder: Color
    let fontName: String
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    let textColor: Color
    let letterSpacing: CGFloat
    let textShadow: Bool
    let textShadowColor: Color
    let textShadowBlur: CGFloat
    let hasTexture: Bool
}
