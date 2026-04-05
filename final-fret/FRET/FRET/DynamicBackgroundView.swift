import SwiftUI

struct DynamicBackgroundView: View {
    let skinManager: SkinManager
    
    var body: some View {
        Rectangle()
            .fill(skinManager.colors.background)
            .ignoresSafeArea()
    }
}
