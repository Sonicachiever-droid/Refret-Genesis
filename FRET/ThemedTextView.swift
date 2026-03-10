import SwiftUI

struct ThemedTextView: View {
    let text: String
    let skinManager: SkinManager
    let size: CGFloat?
    
    init(_ text: String, skinManager: SkinManager, size: CGFloat? = nil) {
        self.text = text
        self.skinManager = skinManager
        self.size = size ?? skinManager.colors.fontSize
    }
    
    var body: some View {
        Text(text)
            .font(.custom(skinManager.colors.fontName, size: size ?? skinManager.colors.fontSize))
            .fontWeight(skinManager.colors.fontWeight)
            .tracking(skinManager.colors.letterSpacing)
            .foregroundColor(skinManager.colors.textColor)
            .if(skinManager.colors.textShadow) { view in
                view.shadow(
                    color: skinManager.colors.textShadowColor,
                    radius: skinManager.colors.textShadowBlur
                )
            }
    }
}

extension View {
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        return Group {
            if condition {
                transform(self)
            } else {
                self
            }
        }
    }
}
