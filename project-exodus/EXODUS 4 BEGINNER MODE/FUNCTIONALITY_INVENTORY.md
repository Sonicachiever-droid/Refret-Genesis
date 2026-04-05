EXODUS 4 BEGINNER MODE - FUNCTIONALITY INVENTORY

CORE GAMEPLAY (User Requested)
1. Beginner Mode Course - 2-phase learning: Round 1 (ascending frets 0-12), Round 2 (descending frets 12-0)
2. Note Identification Quiz - Left/right answer buttons, correct/incorrect feedback
3. Streak Meter - 20-column visual progress, failure animation on wrong answer
4. Bank/Wallet Dollars - $5 per correct answer, bank reset to zero on failure, high score tracking
5. Thumb Button Feedback - Color states: neutral (gray), orange (hint), green (correct), red (wrong)
6. Guitar Note Audio - Plays note when answered + delayed strum effect
7. Fretboard Visual - Rosewood texture, fret wires, fret markers (3-5-7-9), nut with string grooves
8. Startup Sequence - Hold-to-start with shrinking tile animation
9. Transport Controls - Stop/Start buttons for backing track playback
10. Fretboard Guide Toggle - Shows note reference overlay on strings

AUDIO SYSTEM
1. SimpleMIDIEngine - MIDI sequencer playback with 3 samplers (keys/bass/drums), track-level looping
2. Guitar Note Engine - AVAudioUnitSampler with 3 tone presets (acoustic, electric clean, electric dirty), reverb/delay effects
3. Audio Settings - Tone preset selector, effect level controls, backing track selection, tempo increase options
4. Backing Track Discovery - Automatic MIDI file discovery from bundle
5. SoundFont Support - GeneralUser GS v1.472.sf2 bundled for instrument sounds

LEGACY AUDIO ENGINES (Unused but Present)
1. AccompanimentEngine - Drum timer loops + chord progression (separate from SimpleMIDIEngine)
2. AudioEngine - Alternative accompaniment engine with chord/chordSampler
3. SimpleAudioEngine - Alternative audio engine (commented out in places)

DEVELOPER/DEBUG FEATURES (Likely AI-Added)
1. Developer Console Frame - Shows round status, fret/string labels, bank/high score, prompt text
2. Developer Prompt Overlay - Shows status text ("Transport: START", "Fretboard guide ON")
3. Developer TV Streak Meter - Visual 20-column progress indicator with failure animation
4. Transport Status Detail - Internal tracking (IDLE, AUTO_PLAY_OK, MANUAL_STOP, etc.)
5. Playback Path Used - Tracking which engine path is active (SEQUENCER, NONE)
6. Debug Grid Lines - Green bisector line, numbered grid reference
7. Screensaver Mode - isCodeScreensaverMode flag for demo/display mode

ALTERNATE GAMEPLAY MODES (Legacy/Experimental)
1. Freestyle Mode - Open practice without scoring
2. Beat Mode - Timer-based questions with BPM deadline
3. Chord Mode - Chord-based questions (requires chord partner logic)
4. Mixed Mode - Combination gameplay
5. One-Hand / Two-Hand Modes - Hand-specific gameplay variants
6. Maestro Layout Mode - Alternative layout for advanced users

HINT/ASSIST SYSTEM
1. Question Box Assist - Orange thumb indicates correct side (costs $1 from bank)
2. Hint Button - Text hints with interval references ("What note is a fourth below A?")
3. Fretboard Guide Toggle - Shows/hides note reference overlay

CELEBRATION PHASES
1. Round 1 Celebration - Flashing animation before arming Round 2
2. Round 2 Arming - Transition phase before descending round
3. Round 2 Celebration - Completion celebration, loops back to start

CHORD SYSTEM (Unused in Beginner Mode)
1. ChordType Enum - 20+ chord definitions with note patterns
2. FretNoteCalculator - Note calculation per string/fret
3. ChordGenerator - Compatibility scoring, weighted random selection

MENU SYSTEM
1. Audio Page - Settings for guitar tone, effects, backing track, tempo
2. Gameplay Menu - Home, Learn, Phases, Account, Audio navigation

RECENT CHANGES (MIDI Engine Replacement)
1. Replaced BackingTrackEngine with SimpleMIDIEngine from Exodus 6
2. Removed arrangement presets (now uses fixed keys/bass/drums mix)
3. Removed transposition per round (fixed piano sound)
4. MIDI routing: Track 1→keys, Track 2→bass, Track 3→drums
