import UIKit

// MARK: - Contracts

protocol PlayerViewBehavior: AnyObject {
    func set(name: String,
             playlist: [PlaylistItem],
             playItemIndex: Int,
             time: Double,
             preffered quality: VideoQuality)
    func set(quality: VideoQuality)
    func set(playItemIndex: Int)
}

protocol PlayerEventHandler: ViewControllerEventHandler {
    func bind(view: PlayerViewBehavior,
              router: PlayerRoutable,
              series: Series,
              playlist: [PlaylistItem]?)

    func settings(quality: VideoQuality?, for item: PlaylistItem)
    func select(playItemIndex: Int)
    func save(quality: VideoQuality?, number: Int, time: Double)
    func back()
}
