import UIKit

// MARK: - Contracts

protocol SeriesViewBehavior: WaitingBehavior, RefreshBehavior {
    func set(series: Series)
    func set(favorite: Bool)
    func set(collection: UserCollectionType?)
    func can(watch: Bool)
    func set(series: [Series], current: Series)
    
    func showUpdatesActivity() -> ActivityDisposable?
}

protocol SeriesEventHandler: ViewControllerEventHandler, RefreshEventHandler {
    func bind(view: SeriesViewBehavior,
              router: SeriesRoutable,
              series: Series)

    func select(genre: String)
    func select(series: Series)
    func select(url: URL)
    func schedule()
    func back()
    func play()
    func download(torrent: Torrent)

    func favorite(_ activity: (any ActivityDisposable)?)
    func selectCollection(_ activity: (any ActivityDisposable)?)
    func donate()
    func share()
}
