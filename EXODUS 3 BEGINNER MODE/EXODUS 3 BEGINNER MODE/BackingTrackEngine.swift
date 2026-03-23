import AVFoundation

final class BackingTrackEngine {
    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()
    private lazy var sequencer = AVAudioSequencer(audioEngine: engine)
    private(set) var currentTrack: BackingTrack?
    private(set) var isPlaying: Bool = false

    init() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        engine.mainMixerNode.outputVolume = 0.62
        configureAudioSession()
        loadDefaultSoundBankIfAvailable()
        startEngineIfNeeded()
    }

    func togglePlayback(for track: BackingTrack) {
        if currentTrack == track, isPlaying {
            stop()
        } else {
            play(track: track)
        }
    }

    func play(track: BackingTrack) {
        guard let trackURL = track.resourceURL() else { return }
        do {
            stop()
            sequencer = AVAudioSequencer(audioEngine: engine)
            try sequencer.load(from: trackURL, options: [])
            sequencer.prepareToPlay()
            try startSequencer()
            currentTrack = track
            isPlaying = true
        } catch {
            currentTrack = nil
            isPlaying = false
        }
    }

    func stop() {
        if sequencer.isPlaying {
            sequencer.stop()
        }
        sequencer.currentPositionInBeats = 0
        currentTrack = nil
        isPlaying = false
    }

    private func startSequencer() throws {
        startEngineIfNeeded()
        if !sequencer.isPlaying {
            try sequencer.start()
        }
    }

    private func loadDefaultSoundBankIfAvailable() {
        let candidates: [URL?] = [
            Bundle.main.url(forResource: "gs_instruments", withExtension: "dls"),
            URL(string: "file:///System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls")
        ]
        for candidate in candidates {
            guard let bankURL = candidate else { continue }
            do {
                try sampler.loadSoundBankInstrument(
                    at: bankURL,
                    program: 0,
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: 0
                )
                return
            } catch {
            }
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
        }
    }

    private func startEngineIfNeeded() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
        }
    }
}
