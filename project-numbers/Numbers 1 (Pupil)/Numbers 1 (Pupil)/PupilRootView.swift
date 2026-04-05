import SwiftUI

struct PupilRootView: View {
    @AppStorage("pupil.setup.gameStyle") private var storedGameStyleRawValue: String = PupilGameStyle.random.rawValue
    @AppStorage("pupil.setup.startingFret") private var storedStartingFret: Int = 0
    @AppStorage("pupil.setup.direction") private var storedDirectionRawValue: String = PupilDirection.ascending.rawValue
    @AppStorage("pupil.setup.repetitions") private var storedRepetitions: Int = 2
    @AppStorage("pupil.setup.soundMode") private var storedSoundModeRawValue: String = PupilSoundMode.silent.rawValue
    @AppStorage("pupil.settings.restartOnMistake") private var storedRestartOnMistake: Bool = true
    @AppStorage("pupil.settings.gentleOpeningEnabled") private var storedGentleOpeningEnabled: Bool = true
    @AppStorage("pupil.settings.allowFlexibleStartingFret") private var storedAllowFlexibleStartingFret: Bool = true
    @AppStorage("pupil.settings.showReferenceNoteNames") private var storedShowReferenceNoteNames: Bool = false
    @AppStorage("pupil.settings.showStringNumbers") private var storedShowStringNumbers: Bool = true
    @AppStorage("pupil.settings.showHomeAtStartup") private var storedShowHomeAtStartup: Bool = true
    @AppStorage("pupil.progress.bankPoints") private var storedBankPoints: Int = 0
    @AppStorage("pupil.progress.walletPoints") private var legacyStoredProgressPoints: Int = 0
    @AppStorage("pupil.progress.bestLessonPoints") private var storedBestLessonPoints: Int = 0
    @AppStorage("pupil.progress.completedLessons") private var storedCompletedLessons: Int = 0
    @AppStorage("pupil.progress.lastLessonSummary") private var storedLastLessonSummary: String = "No completed Pupil lesson yet."

    @State private var selectedTab: PupilHubTab = .home
    @State private var setup = PupilLessonSetup()
    @State private var settings = PupilSettings()
    @State private var progress = PupilProgress()
    @State private var activeSession: PupilLessonSession?
    @State private var rewardAppliedForCurrentLesson = false
    @State private var didLoadPersistentState = false

    var body: some View {
        Group {
            if let session = activeSession {
                PupilLessonView(
                    session: session,
                    settings: settings,
                    progress: progress,
                    onBeginLesson: beginLesson,
                    onSubmitString: submitString,
                    onRestartLesson: restartLesson,
                    onBackToSetup: backToSetup,
                    onReturnHome: backToHome
                )
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        PupilHomeView(
                            progress: progress,
                            setup: setup,
                            showHomeAtStartup: Binding(
                                get: { settings.showHomeAtStartup },
                                set: { settings.showHomeAtStartup = $0 }
                            ),
                            onLearn: {
                                selectedTab = .instructions
                            },
                            onPlay: {
                                selectedTab = .play
                            }
                        )
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(PupilHubTab.home)

                    NavigationStack {
                        PupilSetupView(setup: $setup, settings: settings) {
                            startLesson()
                        }
                    }
                    .tabItem {
                        Label("Play", systemImage: "gamecontroller.fill")
                    }
                    .tag(PupilHubTab.play)

                    NavigationStack {
                        PupilInstructionsView(
                            onStartFirstLesson: {
                                selectedTab = .play
                                startLesson()
                            },
                            onBackToHome: {
                                selectedTab = .home
                            }
                        )
                    }
                    .tabItem {
                        Label("Instructions", systemImage: "book.closed.fill")
                    }
                    .tag(PupilHubTab.instructions)

                    NavigationStack {
                        PupilSettingsView(
                            settings: $settings,
                            progress: progress,
                            onResetProgress: resetProgress,
                            onResetAll: resetAllPupilData
                        )
                    }
                    .tabItem {
                        Label("Settings", systemImage: "slider.horizontal.3")
                    }
                    .tag(PupilHubTab.settings)
                }
                .tint(.orange)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: activeSession == nil)
        .onAppear(perform: loadPersistedStateIfNeeded)
        .onChange(of: setup) { _, newValue in
            persist(setup: newValue)
        }
        .onChange(of: settings) { _, newValue in
            persist(settings: newValue)
        }
        .onChange(of: progress) { _, newValue in
            persist(progress: newValue)
        }
    }

    private func startLesson() {
        activeSession = PupilLessonSession(setup: setup, settings: settings)
        rewardAppliedForCurrentLesson = false
    }

    private func beginLesson() {
        guard var session = activeSession else { return }
        session.startActivePlay()
        activeSession = session
    }

    private func submitString(_ stringNumber: Int) {
        guard var session = activeSession else { return }
        session.submit(stringNumber: stringNumber, settings: settings)
        activeSession = session
        applyLessonRewardsIfNeeded()
    }

    private func restartLesson() {
        startLesson()
    }

    private func backToSetup() {
        activeSession = nil
        rewardAppliedForCurrentLesson = false
        selectedTab = .play
    }

    private func backToHome() {
        activeSession = nil
        rewardAppliedForCurrentLesson = false
        selectedTab = .home
    }

    private func resetProgress() {
        progress = PupilProgress()
    }

    private func resetAllPupilData() {
        setup = PupilLessonSetup()
        settings = PupilSettings()
        progress = PupilProgress()
        activeSession = nil
        rewardAppliedForCurrentLesson = false
        selectedTab = .home
    }

    private func applyLessonRewardsIfNeeded() {
        guard let session = activeSession, session.stage == .finish, !rewardAppliedForCurrentLesson else { return }
        rewardAppliedForCurrentLesson = true
        progress.bankPoints += session.lessonPoints
        progress.bestLessonPoints = max(progress.bestLessonPoints, session.lessonPoints)
        progress.completedLessons += 1
        progress.lastLessonSummary = session.completionSummary
    }

    private func loadPersistedStateIfNeeded() {
        guard !didLoadPersistentState else { return }
        didLoadPersistentState = true

        let resolvedBankPoints = storedBankPoints == 0 ? legacyStoredProgressPoints : storedBankPoints

        setup = PupilLessonSetup(
            gameStyle: PupilGameStyle(rawValue: storedGameStyleRawValue) ?? .random,
            startingFret: min(max(storedStartingFret, 0), 12),
            direction: PupilDirection(rawValue: storedDirectionRawValue) ?? .ascending,
            repetitions: min(max(storedRepetitions, 1), 4),
            soundMode: PupilSoundMode(rawValue: storedSoundModeRawValue) ?? .silent
        )

        let loadedSettings = PupilSettings(
            restartOnMistake: storedRestartOnMistake,
            gentleOpeningEnabled: storedGentleOpeningEnabled,
            allowFlexibleStartingFret: storedAllowFlexibleStartingFret,
            showReferenceNoteNames: storedShowReferenceNoteNames,
            showStringNumbers: storedShowStringNumbers,
            showHomeAtStartup: storedShowHomeAtStartup
        )
        settings = loadedSettings

        progress = PupilProgress(
            bankPoints: resolvedBankPoints,
            bestLessonPoints: storedBestLessonPoints,
            completedLessons: storedCompletedLessons,
            lastLessonSummary: storedLastLessonSummary
        )

        selectedTab = loadedSettings.showHomeAtStartup ? .home : .play
    }

    private func persist(setup: PupilLessonSetup) {
        storedGameStyleRawValue = setup.gameStyle.rawValue
        storedStartingFret = setup.startingFret
        storedDirectionRawValue = setup.direction.rawValue
        storedRepetitions = setup.repetitions
        storedSoundModeRawValue = setup.soundMode.rawValue
    }

    private func persist(settings: PupilSettings) {
        storedRestartOnMistake = settings.restartOnMistake
        storedGentleOpeningEnabled = settings.gentleOpeningEnabled
        storedAllowFlexibleStartingFret = settings.allowFlexibleStartingFret
        storedShowReferenceNoteNames = settings.showReferenceNoteNames
        storedShowStringNumbers = settings.showStringNumbers
        storedShowHomeAtStartup = settings.showHomeAtStartup
    }

    private func persist(progress: PupilProgress) {
        storedBankPoints = progress.bankPoints
        legacyStoredProgressPoints = progress.bankPoints
        storedBestLessonPoints = progress.bestLessonPoints
        storedCompletedLessons = progress.completedLessons
        storedLastLessonSummary = progress.lastLessonSummary
    }
}

private struct PupilHomeView: View {
    let progress: PupilProgress
    let setup: PupilLessonSetup
    @Binding var showHomeAtStartup: Bool
    let onLearn: () -> Void
    let onPlay: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pupil")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                    Text("Learn the fretboard like a game.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Choose Learn for a quick walkthrough, or Play to jump straight into a lesson.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                PupilStatStrip(progress: progress)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Ready to Practice")
                        .font(.title3.weight(.bold))
                    PupilInfoRow(label: "Style", value: setup.gameStyle.title)
                    PupilInfoRow(label: "Starting Fret", value: "\(setup.startingFret)")
                    PupilInfoRow(label: "Repetitions", value: "\(setup.repetitions)")
                    PupilInfoRow(label: "Bank", value: "\(progress.bankPoints)")
                    HStack(spacing: 12) {
                        Button("Learn Game", action: onLearn)
                            .buttonStyle(.borderedProminent)
                        Button("Play Game", action: onPlay)
                            .buttonStyle(.bordered)
                    }
                    Toggle("Show Home at startup", isOn: $showHomeAtStartup)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Last result")
                        .font(.title3.weight(.bold))
                    Text(progress.lastLessonSummary)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding()
        }
        .navigationTitle("Home")
        .background(PupilScreenBackground())
    }
}

private struct PupilSetupView: View {
    @Binding var setup: PupilLessonSetup
    let settings: PupilSettings
    let onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Play")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                    Text("Build your setup, check the path, and launch when it feels right.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                PupilSurfacePanel {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Ready to Start")
                            .font(.title3.weight(.bold))
                        PupilInfoRow(label: "Style", value: setup.gameStyle.title)
                        PupilInfoRow(label: "Starting Fret", value: "\(setup.startingFret)")
                        PupilInfoRow(label: "Direction", value: setup.direction.rawValue)
                        PupilInfoRow(label: "Repetitions", value: "\(setup.repetitions)")
                        PupilInfoRow(label: "Sound", value: setup.soundMode.rawValue)
                        PupilInfoRow(label: "Penalty", value: settings.restartOnMistake ? "Restart on mistake" : "Repeat current challenge")
                    }
                }

                PupilSurfacePanel {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Lesson Setup")
                            .font(.title3.weight(.bold))
                        Text("Choose your style, set your starting fret, and start when you're ready.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Style")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Picker("Style", selection: $setup.gameStyle) {
                                ForEach(PupilGameStyle.allCases) { style in
                                    Text(style.title).tag(style)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        PupilSelectionRow(title: "Starting Fret") {
                            Picker("Starting Fret", selection: $setup.startingFret) {
                                ForEach(0...12, id: \.self) { fret in
                                    Text("\(fret)").tag(fret)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .disabled(!settings.allowFlexibleStartingFret)
                        }

                        PupilSelectionRow(title: "Direction") {
                            Picker("Direction", selection: $setup.direction) {
                                ForEach(PupilDirection.allCases) { direction in
                                    Text(direction.rawValue).tag(direction)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }

                        PupilSelectionRow(title: "Repetitions") {
                            Picker("Repetitions", selection: $setup.repetitions) {
                                ForEach(1...4, id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }

                        PupilSelectionRow(title: "Sound") {
                            Picker("Sound Mode", selection: $setup.soundMode) {
                                ForEach(PupilSoundMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                    }
                }

                PupilSurfacePanel {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Style")
                            .font(.title3.weight(.bold))
                        Text(setup.gameStyle.shortDescription)
                        Text(settings.restartOnMistake ? "Default penalty is restart on mistake." : "Default penalty repeats only the current challenge.")
                            .foregroundStyle(.secondary)
                    }
                }

                Button(action: onStart) {
                    HStack {
                        Spacer()
                        Text("Start Lesson")
                            .font(.headline.weight(.bold))
                        Spacer()
                    }
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Play")
        .background(PupilScreenBackground())
    }
}

private struct PupilInstructionsView: View {
    let onStartFirstLesson: () -> Void
    let onBackToHome: () -> Void

    var body: some View {
        List {
            Section {
                Text("Pupil teaches fretboard note recognition through short, playable drills. You do not need to memorize everything before you begin.")
            }

            Section("What You Do") {
                Text("Follow the target, choose the correct string locations, and complete the sequence one step at a time.")
            }

            Section("How a Lesson Works") {
                Text("Choose your setup, start the lesson, respond to each prompt, and finish the run to earn progress.")
            }

            Section("Random") {
                Text("Random trains note recognition on a single fret.")
                Text("If the same note appears twice, you may use either valid location first, but you cannot use the same location twice for that pass.")
            }

            Section("Chord") {
                Text("Chord trains recognition of grouped note targets.")
                Text("Select the strings that match the chord tones available on the current fret.")
            }

            Section("Mistakes and Restarts") {
                Text("Pupil can be forgiving while you learn. Penalty and restart behavior can be adjusted in Settings.")
            }

            Section("Points and Rewards") {
                Text("Complete lessons to earn Bank and track your progress.")
            }

            Section("Getting Started") {
                Button("Start First Lesson", action: onStartFirstLesson)
                    .buttonStyle(.borderedProminent)
                Button("Back to Home", action: onBackToHome)
            }
        }
        .navigationTitle("How to Play")
    }
}

private struct PupilSettingsView: View {
    @Binding var settings: PupilSettings
    let progress: PupilProgress
    let onResetProgress: () -> Void
    let onResetAll: () -> Void

    var body: some View {
        Form {
            Section("Bank") {
                LabeledContent("Current Bank", value: "\(progress.bankPoints)")
                LabeledContent("Lessons Completed", value: "\(progress.completedLessons)")
                LabeledContent("Best Lesson", value: "\(progress.bestLessonPoints)")
            }

            Section("Startup") {
                Toggle("Show Home at startup", isOn: $settings.showHomeAtStartup)
            }

            Section("Lesson Defaults") {
                Toggle("Restart lesson on mistake", isOn: $settings.restartOnMistake)
                Toggle("Protected early mistakes", isOn: $settings.gentleOpeningEnabled)
                Toggle("Allow flexible starting fret", isOn: $settings.allowFlexibleStartingFret)
            }

            Section("Practice") {
                Toggle("Show reference note names on buttons", isOn: $settings.showReferenceNoteNames)
                Toggle("Show string numbers", isOn: $settings.showStringNumbers)
            }

            Section("Progress") {
                Text(progress.lastLessonSummary)
                    .foregroundStyle(.secondary)
            }

            Section("Reset") {
                Button("Reset Progress", role: .destructive, action: onResetProgress)
                Button("Reset All Pupil Data", role: .destructive, action: onResetAll)
            }
        }
        .navigationTitle("Settings")
    }
}

private struct PupilStatStrip: View {
    let progress: PupilProgress

    var body: some View {
        HStack(spacing: 12) {
            PupilStatCard(title: "Bank", value: "\(progress.bankPoints)")
            PupilStatCard(title: "Best Lesson", value: "\(progress.bestLessonPoints)")
            PupilStatCard(title: "Lessons", value: "\(progress.completedLessons)")
        }
    }
}

private struct PupilStatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.black))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct PupilSurfacePanel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct PupilSelectionRow<Content: View>: View {
    let title: String
    @ViewBuilder let control: Content

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            control
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct PupilBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .padding(.top, 6)
                .foregroundStyle(.orange)
            Text(text)
        }
    }
}

private struct PupilInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

private struct PupilScreenBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.black, Color(red: 0.16, green: 0.09, blue: 0.03)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
