import SwiftUI

struct HardwareDetailsView: View {
    let skinManager: SkinManager
    let size: CGSize
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: size.width, height: size.height)
    }
}
