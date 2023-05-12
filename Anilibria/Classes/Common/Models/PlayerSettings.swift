import Foundation

public struct PlayerSettings: Codable {
    var quality: VideoQuality = .fullHd
    var audioTrack: AudioTrack = .rusTrack
    var subtitleTrack: Subtitles = .inscriptions

    init() {}
}
