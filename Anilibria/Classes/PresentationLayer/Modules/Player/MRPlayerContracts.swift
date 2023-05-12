import UIKit

// MARK: - Contracts

protocol PlayerViewBehavior: AnyObject {
    func set(name: String,
             playlist: [PlaylistItem],
             playItemIndex: Int,
             time: Double,
             preffered: PrefferedSettings)
    func set(audio: AudioTrack)
    func set(subtitle: Subtitles)
    func set(quality: VideoQuality)
    func set(playItemIndex: Int)
}

protocol PlayerEventHandler: ViewControllerEventHandler {
    func bind(view: PlayerViewBehavior,
              router: PlayerRoutable,
              series: Series,
              playlist: [PlaylistItem]?)

    func settings(quality: VideoQuality?, for item: PlaylistItem)
    func set(currentAudio: AudioTrack?, availableAudioTracks: [AudioTrack])
    func set(currentSubtitle: Subtitles?, availableSubtitles: [Subtitles])
    func select(playItemIndex: Int)
    func save(quality: VideoQuality?, number: Int, time: Double)
    func back()
}

struct PrefferedSettings {
    var quality: VideoQuality
    var audioTrack: AudioTrack
    var subtitleTrack: Subtitles
}
