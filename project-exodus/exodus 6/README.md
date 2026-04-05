# Exodus 6 - MIDI Player

A SwiftUI-based MIDI player app using **proven BackingTrackEngine** from Exodus 4/5 projects.

## Features

- **MIDI File Selection**: Dropdown menu with automatic track discovery
- **Arrangement Presets**: EP+Drums+Pad, Keys+Drums+Strings, EP+Drums Only, Pad+Drums Only
- **Real-Time Transposition**: -12 to +12 semitones with live playback
- **Multi-Sampler Architecture**: Separate samplers for keys, bass, and drums
- **Looping Playback**: 16-beat automatic looping
- **Dual Playback Modes**: AVAudioSequencer (with transpose) + AVMIDIPlayer fallback

## Architecture

### BackingTrackEngine (Proven Implementation from Exodus 4/5)
- **Three-Sampler Design**: Dedicated `AVAudioUnitSampler` for keys, bass, and drums
- **System DLS Soundbank**: Uses `/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls`
- **Track Routing**: Automatically routes MIDI tracks to appropriate samplers (track 2→bass, track 3→drums, others→keys)
- **Real-Time Transpose**: Uses `globalTuning` property for live pitch shifting
- **Arrangement Mix**: Configurable volume levels per sampler (keys: 0.88, bass: 0.78, drums: 0.86)
- **Looping**: 16-beat loop range with infinite repeats
- **Fallback Strategy**: AVMIDIPlayer with soundbank if sequencer fails

### BackingTrack Model
- Automatic MIDI file discovery from bundle
- Development fallback for direct file access
- Title formatting and sorting

### ContentView
- Track selection picker
- Arrangement preset picker
- Transpose stepper (-12 to +12 semitones)
- Play/Pause toggle and Stop buttons
- Real-time playback status display

## Included MIDI Files

- Beginner_loop_01.mid
- Beginner_loop_02.mid
- Beginner_loop_03.mid
- All Night Long.mid

## Sound Bank

Uses **macOS system DLS soundbank** at:
```
/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls
```

This is the **proven working solution** from Exodus 4 and 5 projects.

## Build Status

✅ **BUILD SUCCEEDED** - iOS Simulator (iPhone 17)

```bash
xcodebuild -project "exodus 6.xcodeproj" -scheme "exodus 6" -destination 'platform=iOS Simulator,id=201A3573-2CCB-4541-BC87-00AE35AD5182' build
```

## Usage

1. Launch the app
2. Select a MIDI file from the dropdown
3. Choose an arrangement preset (EP+Drums+Pad, etc.)
4. Adjust transpose if desired (-12 to +12 semitones)
5. Press Play/Pause to toggle playback
6. Press Stop to stop and reset

## Technical Implementation Details

### Why This Works (vs. Previous Attempts)

1. **System DLS Instead of SF2**: Uses native macOS soundbank, not bundled SF2
2. **Multi-Sampler Architecture**: Separate samplers for keys/bass/drums with proper routing
3. **Track Routing Before Start**: `routeTracksToSamplers()` called before `sequencer.start()`
4. **Proper Initialization Order**: 
   - Load soundbank instruments
   - Route tracks to samplers
   - Configure looping
   - Apply arrangement mix
   - Start engine
   - Prepare to play
   - Start sequencer
5. **AVMIDIPlayer Fallback**: If sequencer fails, falls back to AVMIDIPlayer with soundbank URL
6. **Audio Session Configuration**: `.playback` category with `.mixWithOthers` option

### Key Differences from Failed Approaches

- ❌ **Don't** use single sampler for all tracks
- ❌ **Don't** use `.smfChannelsToTracks` option (deprecated/unreliable)
- ❌ **Don't** rely on bundled SF2 files
- ✅ **Do** use system DLS soundbank
- ✅ **Do** route tracks before starting sequencer
- ✅ **Do** use separate samplers per instrument group
- ✅ **Do** configure looping and mix before playback

## Source Projects

This implementation is based on proven working code from:
- `/Users/thomaskane/CascadeProjects/Project Exodus/EXODUS 4 BEGINNER MODE/EXODUS 4 BEGINNER MODE/BackingTrackEngine.swift`
- `/Users/thomaskane/CascadeProjects/Project Exodus/Exodus 5/Exodus 5/BackingTrackEngine.swift`
