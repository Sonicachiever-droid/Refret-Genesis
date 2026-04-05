//
//  Numbers_3App.swift
//  Numbers 3
//
//  Created by Thomas Kane on 4/5/26.
//

import SwiftUI
import SwiftData

@main
struct Numbers_3App: App {
    @State private var selectedMenuOption: GameplayMenuOption?
    @AppStorage("numbers3.progress.walletPoints") private var walletPoints: Int = 0
    @AppStorage("numbers3.progress.balancePoints") private var balancePoints: Int = 0
    @AppStorage("numbers3.setup.startingFret") private var startingFret: Int = 0
    @AppStorage("numbers3.setup.repetitions") private var repetitions: Int = 2
    @AppStorage("numbers3.settings.restartOnMistake") private var restartOnMistake: Bool = true
    @AppStorage("numbers3.settings.gentleOpeningEnabled") private var gentleOpeningEnabled: Bool = true
    @AppStorage("numbers3.settings.showReferenceNoteNames") private var showReferenceNoteNames: Bool = false
    @AppStorage("numbers3.settings.showStringNumbers") private var showStringNumbers: Bool = true

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
            ContentView(
                onMenuSelection: { option in
                    selectedMenuOption = option
                },
                walletDollars: $walletPoints,
                balanceDollars: $balancePoints
            )
            .sheet(item: $selectedMenuOption) { option in
                Numbers3MenuSheet(
                    option: option,
                    walletPoints: $walletPoints,
                    balancePoints: $balancePoints,
                    startingFret: $startingFret,
                    repetitions: $repetitions,
                    restartOnMistake: $restartOnMistake,
                    gentleOpeningEnabled: $gentleOpeningEnabled,
                    showReferenceNoteNames: $showReferenceNoteNames,
                    showStringNumbers: $showStringNumbers
                )
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct Numbers3MenuSheet: View {
    let option: GameplayMenuOption
    @Binding var walletPoints: Int
    @Binding var balancePoints: Int
    @Binding var startingFret: Int
    @Binding var repetitions: Int
    @Binding var restartOnMistake: Bool
    @Binding var gentleOpeningEnabled: Bool
    @Binding var showReferenceNoteNames: Bool
    @Binding var showStringNumbers: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                switch option {
                case .home:
                    Section("Progress") {
                        LabeledContent("Wallet", value: "\(walletPoints)")
                        LabeledContent("Balance", value: "\(balancePoints)")
                    }
                case .learn:
                    Section("Lesson Setup") {
                        Stepper("Starting Fret: \(startingFret)", value: $startingFret, in: 0...12)
                        Stepper("Repetitions: \(repetitions)", value: $repetitions, in: 1...8)
                    }
                case .phases:
                    Section("Quick Guide") {
                        Text("Follow prompts, use HINT when needed, and keep runs clean to maximize points.")
                        Text("Use FRETBOARD toggle to focus either on recall or visual reinforcement.")
                    }
                case .account:
                    Section("Lesson Rules") {
                        Toggle("Restart on mistake", isOn: $restartOnMistake)
                        Toggle("Gentle opening", isOn: $gentleOpeningEnabled)
                    }
                    Section("Practice View") {
                        Toggle("Show reference notes", isOn: $showReferenceNoteNames)
                        Toggle("Show string numbers", isOn: $showStringNumbers)
                    }
                case .audio:
                    Section("Audio") {
                        Text("Use the in-game AUDIO page for backing track and instrument mix settings.")
                    }
                }
            }
            .navigationTitle(option.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
