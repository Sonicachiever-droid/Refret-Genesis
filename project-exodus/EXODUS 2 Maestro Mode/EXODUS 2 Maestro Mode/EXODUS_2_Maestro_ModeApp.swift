//
//  EXODUS_2_Maestro_ModeApp.swift
//  EXODUS 2 Maestro Mode
//
//  Created by Thomas Kane on 3/20/26.
//

import SwiftUI
import SwiftData

@main
struct EXODUS_2_Maestro_ModeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
