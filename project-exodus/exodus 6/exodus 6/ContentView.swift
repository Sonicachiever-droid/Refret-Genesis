import SwiftUI

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
                .onChange(of: isLooping) { _ in          // Fixed: modern syntax
                    engine.setLooping(isLooping)
                }
                .padding(.horizontal)
            
            VStack {
                Text("Tempo: \(Int(tempo)) BPM")
                    .font(.headline)
                Slider(value: $tempo, in: 60...180, step: 1)
                    .onChange(of: tempo) { _ in              // Fixed: modern syntax
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
