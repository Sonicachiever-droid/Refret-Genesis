import Foundation

struct BackingTrack: Identifiable, Equatable, Hashable {
    let title: String
    let resourceName: String
    let fileExtension: String

    var id: String {
        "\(resourceName).\(fileExtension)"
    }

    func resourceURL(in bundle: Bundle = .main) -> URL? {
        if let url = bundle.url(forResource: resourceName, withExtension: fileExtension) {
            return url
        }
        #if DEBUG
        let devPath = "/Users/thomaskane/CascadeProjects/Project Exodus/exodus 6/exodus 6/\(resourceName).\(fileExtension)"
        let devURL = URL(fileURLWithPath: devPath)
        if FileManager.default.fileExists(atPath: devURL.path) {
            return devURL
        }
        #endif
        return nil
    }

    static func discoverBundledTracks(in bundle: Bundle = .main) -> [BackingTrack] {
        let midiExtensions = ["mid", "midi"]
        var urls = midiExtensions.flatMap { bundle.urls(forResourcesWithExtension: $0, subdirectory: nil) ?? [] }
        #if DEBUG
        if urls.isEmpty {
            let devDir = URL(fileURLWithPath: "/Users/thomaskane/CascadeProjects/Project Exodus/exodus 6/exodus 6")
            if let contents = try? FileManager.default.contentsOfDirectory(at: devDir, includingPropertiesForKeys: nil) {
                let devURLs = contents.filter { midiExtensions.contains($0.pathExtension.lowercased()) }
                urls.append(contentsOf: devURLs)
            }
        }
        #endif
        let tracks = urls.map { url in
            BackingTrack(
                title: url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "_", with: " ").uppercased(),
                resourceName: url.deletingPathExtension().lastPathComponent,
                fileExtension: url.pathExtension
            )
        }
        return Array(Set(tracks)).sorted { $0.title < $1.title }
    }
}
