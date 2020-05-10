import Foundation

public struct PlayerContext: Codable {
    var quality: VideoQuality = .fullHd
    var number: Int = 0
    var time: Double = 0

    init(quality: VideoQuality, number: Int, time: Double) {
        self.quality = quality
        self.number = number
        self.time = time
    }
}
