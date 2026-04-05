import SwiftUI

struct SkinSelectorView: View {
    let skinManager: SkinManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(SkinManager.SkinTheme.allCases, id: \.self) { skin in
                Button(action: {
                    skinManager.setSkin(skin)
                    isPresented = false
                }) {
                    HStack {
                        Text(skin.rawValue)
                        Spacer()
                        if skinManager.currentSkin == skin {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Theme")
            .navigationBarItems(trailing: Button("Done") { isPresented = false })
        }
    }
}
