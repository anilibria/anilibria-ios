import Foundation

public struct MPVPlayerContext: Codable {
    var id: Int?
    var time: Double = 0
    var audioTrack: AudioTrack?
    var subtitleTrack: Subtitles?
    
    init(id: Int, time: Double, audioTrack: AudioTrack?, subtitleTrack: Subtitles?) {
        self.audioTrack = audioTrack
        self.subtitleTrack = subtitleTrack
        self.time = time
        self.id = id
    }
}

public struct PlayerContext: Codable {
    var quality: VideoQuality?
    var id: Int?
    var time: Double = 0
    
    // legacy
    var number: Int = 0

    init(id: Int, time: Double, quality: VideoQuality?) {
        self.quality = quality
        self.time = time
        self.id = id
    }
}
