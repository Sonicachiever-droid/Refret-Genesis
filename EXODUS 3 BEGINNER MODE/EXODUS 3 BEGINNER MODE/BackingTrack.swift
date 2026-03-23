import Foundation

struct BackingTrack: Identifiable, Equatable, Hashable {
    let title: String
    let resourceName: String
    let fileExtension: String

    var id: String {
        "\(resourceName).\(fileExtension)"
    }

    func resourceURL(in bundle: Bundle = .main) -> URL? {
        bundle.url(forResource: resourceName, withExtension: fileExtension)
    }

    static func discoverBundledTracks(in bundle: Bundle = .main) -> [BackingTrack] {
        let midiExtensions = ["mid", "midi"]
        let urls = midiExtensions.flatMap { bundle.urls(forResourcesWithExtension: $0, subdirectory: nil) ?? [] }
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
