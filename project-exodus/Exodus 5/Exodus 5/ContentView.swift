import SwiftUI
import AVFoundation
import Combine

// MARK: - SimpleMIDIEngine (inside the same file for now)

final class SimpleMIDIEngine: ObservableObject {
    
    private let engine = AVAudioEngine()
    private let sequencer: AVAudioSequencer
    
    @Published var isPlaying: Bool = false
    @Published var currentTrackTitle: String = ""
    
    private var currentURL: URL?
    private var isLooping: Bool = true
    
    init() {
        self.sequencer = AVAudioSequencer(audioEngine: engine)
        setupAudioSession()
        setupEngine()
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("[Engine] Audio session error: \(error)")
        }
        #endif
    }
    
    private func setupEngine() {
        do {
            try engine.start()
            print("[Engine] AVAudioEngine started")
        } catch {
            print("[Engine] Failed to start engine: \(error)")
        }
    }
    
    func play(url: URL, title: String = "", loop: Bool = true) {
        stop()
        
        currentURL = url
        currentTrackTitle = title.isEmpty ? url.lastPathComponent : title
        isLooping = loop
        
        do {
            try sequencer.load(from: url)
            sequencer.prepareToPlay()
            try sequencer.start()
            
            DispatchQueue.main.async {
                self.isPlaying = true
            }
            
            print("[Engine] Playing: \(currentTrackTitle) | Looping: \(loop)")
            
        } catch {
            print("[Engine] Failed to play MIDI: \(error)")
        }
    }
    
    func stop() {
        sequencer.stop()
        sequencer.currentPositionInBeats = 0
        
        DispatchQueue.main.async {
            self.isPlaying = false
        }
        print("[Engine] Stopped")
    }
    
    func setTempo(bpm: Double) {
        sequencer.rate = Float(bpm / 120.0)
    }
    
    func setLooping(_ looping: Bool) {
        isLooping = looping
        print("[Engine] Looping set to: \(looping)")
    }
    
    deinit {
        sequencer.stop()
        engine.stop()
    }
}

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var engine = SimpleMIDIEngine()
    
    @State private var availableTracks: [BackingTrack] = []
    @State private var selectedTrack: BackingTrack?
    @State private var tempo: Double = 120.0
    @State private var isLooping: Bool = true
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Exodus 6 - MIDI Player")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                Picker("Select MIDI File", selection: $selectedTrack) {
                    Text("Choose a file...").tag(nil as BackingTrack?)
                    ForEach(availableTracks) { track in
                        Text(track.title).tag(track as BackingTrack?)
                    }
                }
                .pickerStyle(.menu)
                
                if let track = selectedTrack {
                    Text(track.title)
                        .font(.headline)
                    
                    Text(engine.isPlaying ? "▶️ Playing" : "⏸ Stopped")
                        .font(.subheadline)
                        .foregroundColor(engine.isPlaying ? .green : .gray)
                }
            }
            
            HStack(spacing: 40) {
                Button(action: playSelected) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                .disabled(selectedTrack == nil || engine.isPlaying)
                
                Button(action: { engine.stop() }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                }
                .disabled(!engine.isPlaying)
            }
            
            Toggle("Loop Playback", isOn: $isLooping)
                .onChange(of: isLooping) { _ in
                    engine.setLooping(isLooping)
                }
                .padding(.horizontal)
            
            VStack {
                Text("Tempo: \(Int(tempo)) BPM")
                    .font(.headline)
                Slider(value: $tempo, in: 60...180, step: 1)
                    .onChange(of: tempo) { _ in
                        engine.setTempo(bpm: tempo)
                    }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            availableTracks = BackingTrack.discoverBundledTracks()
            if !availableTracks.isEmpty {
                selectedTrack = availableTracks.first
            }
        }
    }
    
    private func playSelected() {
        guard let track = selectedTrack, let url = track.resourceURL() else { return }
        engine.play(url: url, title: track.title, loop: isLooping)
    }
}

#Preview {
    ContentView()
}
