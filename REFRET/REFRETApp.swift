//
//  REFRETApp.swift
//  REFRET
//
//  Created by Thomas Kane on 3/10/26.
//

import SwiftUI

@main
struct REFRETApp: App {
    @StateObject private var skinManager = SkinManager()
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(gameManager: gameManager)
                .environmentObject(skinManager)
        }
    }
}
