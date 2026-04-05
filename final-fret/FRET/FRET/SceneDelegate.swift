import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

struct FRETGameView: View {
    @State private var litCircleIndex: Int? = 2
    @State private var wrongPressCircle: Int? = nil
    @State private var showingNote = false
    @State private var currentLitNote = "E"
    @State private var lastLitCircleIndex: Int? = nil
    @State private var gamePhase = 1
    @State private var displayCorrectAnswers = 3
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("FRET Game")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 50)
            
            Spacer()
            
            // Guitar neck area
            VStack(spacing: 10) {
                // Fretboard background
                Rectangle()
                    .fill(Color.brown)
                    .frame(height: 150)
                    .overlay(
                        // Strings
                        VStack(spacing: 20) {
                            ForEach(0..<6, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(height: 2)
                            }
                        }
                    )
                
                // Fret circles
                HStack(spacing: 30) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(wrongPressCircle == index ? Color.red : litCircleIndex == index ? Color.green : Color.white.opacity(0.5))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .onTapGesture {
                                litCircleIndex = index
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Thermometer blocks
            VStack(spacing: 2) {
                ForEach(0..<displayCorrectAnswers, id: \.self) { index in
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 20)
                }
            }
            .frame(width: 200)
            
            // Thumb buttons
            HStack(spacing: 20) {
                ForEach(0..<6, id: \.self) { index in
                    Button(action: {
                        litCircleIndex = index
                    }) {
                        Circle()
                            .fill(litCircleIndex == index ? Color.green : Color.gray)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                }
            }
            .padding(.bottom, 50)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}
