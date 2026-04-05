import SwiftUI

struct PupilLessonView: View {
    let session: PupilLessonSession
    let settings: PupilSettings
    let progress: PupilProgress
    let onBeginLesson: () -> Void
    let onSubmitString: (Int) -> Void
    let onRestartLesson: () -> Void
    let onBackToSetup: () -> Void
    let onReturnHome: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    lessonHeader
                    summaryCards
                    challengePanel
                    if session.stage != .finish {
                        stringGrid
                    }
                    actionRow
                }
                .padding()
            }
            .background(PupilLessonBackground())
            .navigationTitle(session.setup.gameStyle.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Setup", action: onBackToSetup)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Restart", action: onRestartLesson)
                }
            }
        }
    }

    private var lessonHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("REFRET • Pupil")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            Text(session.progressTitle)
                .font(.system(size: 30, weight: .black, design: .rounded))
            Text("Path: \(session.lessonPathText)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(session.statusMessage)
                .font(.headline)
                .foregroundStyle(statusColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            LessonMetricCard(title: "Stage", value: session.stageTitle)
            LessonMetricCard(title: "Points", value: "\(session.lessonPoints)")
            LessonMetricCard(title: "Mistakes", value: "\(session.mistakes)")
            LessonMetricCard(title: "Bank", value: "\(progress.bankPoints)")
        }
    }

    @ViewBuilder
    private var challengePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            switch session.stage {
            case .introReveal:
                Text("Intro Reveal")
                    .font(.title3.weight(.bold))
                Text(session.introMessage)
                    .foregroundStyle(.secondary)
                promptView
                Button("Begin Lesson", action: onBeginLesson)
                    .buttonStyle(.borderedProminent)
            case .activePlay:
                Text("Now Playing")
                    .font(.title3.weight(.bold))
                promptView
            case .finish:
                Text("Lesson Complete")
                    .font(.title3.weight(.bold))
                Text("Nice work. Your run is finished.")
                    .foregroundStyle(.secondary)
                Text(session.completionSummary)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 10) {
                    FinishSummaryRow(label: "Style", value: session.setup.gameStyle.title)
                    FinishSummaryRow(label: "Frets Covered", value: session.lessonPathText)
                    FinishSummaryRow(label: "Repetitions", value: "\(session.setup.repetitions)")
                    FinishSummaryRow(label: "Mistakes", value: "\(session.mistakes)")
                    FinishSummaryRow(label: "Bank Earned", value: "\(session.lessonPoints)")
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bank after reward: \(progress.bankPoints)")
                    Text("Best single lesson: \(progress.bestLessonPoints)")
                    Text(session.mistakes == 0 ? "Clean run bonus" : "Progress still counts. Keep going.")
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @ViewBuilder
    private var promptView: some View {
        switch session.setup.gameStyle {
        case .random:
            VStack(alignment: .leading, spacing: 12) {
                Text("Displayed notes")
                    .font(.headline)
                FlowLayout(items: Array(session.currentRandomNotes.enumerated())) { item in
                    RandomPromptToken(
                        note: item.element,
                        isCurrent: item.offset == session.currentRandomTargetIndex
                    )
                }
                if session.stage == .activePlay {
                    Text("Current target: \(session.currentRandomTarget ?? "Complete")")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
        case .chord:
            VStack(alignment: .leading, spacing: 12) {
                Text(session.currentChordSymbol)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                FlowLayout(items: session.currentChordTones) { tone in
                    ChordToneToken(text: tone)
                }
                Text("Select every string on fret \(session.currentFret) whose note belongs to this chord.")
                    .foregroundStyle(.secondary)
                if session.stage == .activePlay {
                    Text("Remaining correct strings: \(session.currentChordRemainingSelections)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    private var stringGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("String positions")
                .font(.title3.weight(.bold))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(PupilLessonSession.stringOrder, id: \.self) { stringNumber in
                    Button {
                        if session.stage == .activePlay {
                            onSubmitString(stringNumber)
                        }
                    } label: {
                        StringButtonCard(
                            stringNumber: stringNumber,
                            fret: session.currentFret,
                            settings: settings,
                            isEnabled: session.stage == .activePlay,
                            lastSubmissionWasCorrect: session.lastSubmissionWasCorrect,
                            gameStyle: session.setup.gameStyle,
                            chordChallenge: session.chordChallenge
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(session.stage != .activePlay)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var actionRow: some View {
        Group {
            if session.stage == .finish {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button("Play Again", action: onRestartLesson)
                            .buttonStyle(.borderedProminent)
                        Button("Adjust Setup", action: onBackToSetup)
                            .buttonStyle(.bordered)
                    }
                    Button("Return Home", action: onReturnHome)
                        .buttonStyle(.bordered)
                }
            } else {
                HStack(spacing: 12) {
                    Button("Restart Lesson", action: onRestartLesson)
                        .buttonStyle(.bordered)
                    Button("Back to Setup", action: onBackToSetup)
                        .buttonStyle(.bordered)
                }
            }
        }
    }

    private var statusColor: Color {
        switch session.lastSubmissionWasCorrect {
        case true:
            return .green
        case false:
            return .red
        case nil:
            return .primary
        }
    }
}

private struct LessonMetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.bold))
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct FinishSummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct RandomPromptToken: View {
    let note: String
    let isCurrent: Bool

    var body: some View {
        Text(note)
            .font(.headline.weight(.bold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isCurrent ? Color.orange : Color.white.opacity(0.08), in: Capsule())
            .foregroundStyle(isCurrent ? Color.black : Color.white)
    }
}

private struct ChordToneToken: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.green.opacity(0.22), in: Capsule())
    }
}

private struct StringButtonCard: View {
    let stringNumber: Int
    let fret: Int
    let settings: PupilSettings
    let isEnabled: Bool
    let lastSubmissionWasCorrect: Bool?
    let gameStyle: PupilGameStyle
    let chordChallenge: PupilChordChallenge?

    private var referenceNote: String {
        PupilLessonSession.noteName(forString: stringNumber, fret: fret)
    }

    private var title: String {
        settings.showStringNumbers ? "String \(stringNumber)" : "Position \(stringNumber)"
    }

    private var subtitle: String {
        if settings.showReferenceNoteNames {
            return "Fret \(fret) • \(referenceNote)"
        }
        return "Fret \(fret)"
    }

    private var toneIsSelected: Bool {
        chordChallenge?.selectedStrings.contains(stringNumber) ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline.weight(.bold))
                Spacer()
                if toneIsSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if gameStyle == .chord && settings.showReferenceNoteNames {
                Text("Chord tone check")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .padding()
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .opacity(isEnabled ? 1 : 0.72)
    }

    private var backgroundColor: Color {
        if toneIsSelected {
            return Color.green.opacity(0.22)
        }
        return Color.white.opacity(0.06)
    }

    private var borderColor: Color {
        if toneIsSelected {
            return .green
        }
        switch lastSubmissionWasCorrect {
        case true:
            return .orange.opacity(0.45)
        case false:
            return .red.opacity(0.45)
        case nil:
            return .white.opacity(0.14)
        }
    }
}

private struct PupilLessonBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.07, green: 0.06, blue: 0.10), Color.black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View {
    let items: Data
    let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let rows = makeRows(from: Array(items))
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 10) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, item in
                        content(item)
                    }
                }
            }
        }
    }

    private func makeRows(from items: [Data.Element]) -> [[Data.Element]] {
        var rows: [[Data.Element]] = []
        var currentRow: [Data.Element] = []

        for item in items {
            currentRow.append(item)
            if currentRow.count == 4 {
                rows.append(currentRow)
                currentRow = []
            }
        }

        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }
}
