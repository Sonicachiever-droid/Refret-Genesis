# Legacy Menu Page Reconstruction

## Context
- The original `Home`, `Learn`, `Phases`, and `Account` page bodies are not present in the accessible Project Exodus/Genesis repos.
- We have the `GameplayMenuOption` enum and menu shell, plus one screenshot of `Account & Options`.
- This reconstruction uses those artifacts to infer likely content and structure.

## Recovered Menu Architecture
From `ContentView.swift` across Exodus 1/2/3:
```swift
enum GameplayMenuOption {
    case home
    case learn
    case phases
    case account
    case audio
}
```

## Reconstructed Page Outlines

### Home Page
**Likely purpose**: Main dashboard or entry point before gameplay.
**Inferred content**:
- Welcome message or branding.
- Summary of player progress/bank.
- Quick-start options (possibly “Learn Game?” and “Play Game!” as remembered).
- Maybe a “do not show this again” toggle for returning users.

### Learn Page
**Likely purpose**: Instructions or tutorial content.
**Inferred content**:
- Walkthrough of game mechanics.
- Explanation of note/fretboard concepts.
- Possibly structured sections (e.g., “How to Play,” “Scoring,” “Tips”).

### Phases Page
**Likely purpose**: Difficulty or progression stages.
**Inferred content**:
- List of available phases/levels.
- Unlock criteria or prerequisites.
- Progress indicators for each phase.

### Account & Options Page (based on screenshot)
**Confirmed visible elements**:
- Header: “Account & Options”
- Sections likely include:
  - Bank/balance display.
  - Settings or preferences.
  - Reset or data management options.
  - Possibly audio settings (mirroring the `audio` menu option).

## Notes
- These are inferred outlines; actual copy and detailed layout remain speculative.
- If original sources are found in an external archive, replace these reconstructions.
- For now, these can serve as placeholders for restoring the menu flow.
