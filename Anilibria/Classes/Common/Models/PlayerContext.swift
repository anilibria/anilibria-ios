import Foundation

public struct PlayerContext: Codable {
    var quality: VideoQuality?
    var audioTrack: AudioTrack?
    var subtitleTrack: Subtitles?
    var number: Int = 0
    var time: Double = 0

    init(quality: VideoQuality?, audioTrack: AudioTrack?, subtitleTrack: Subtitles?, number: Int, time: Double) {
        self.quality = quality
        self.audioTrack = audioTrack
        self.subtitleTrack = subtitleTrack
        self.number = number
        self.time = time
    }
}
