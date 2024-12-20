import UIKit

// MARK: - Contracts

protocol SeriesViewBehavior: WaitingBehavior {
    func set(series: Series)
    func set(favorite: Bool?, count: Int)
    func can(favorite: Bool)
    func can(watch: Bool)
    func set(series: [Series], current: Series)
}

protocol SeriesEventHandler: ViewControllerEventHandler {
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

    func favorite()
    func donate()
    func share()
}
