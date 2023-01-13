import UIKit

final class PlayerAssembly {
    class func createModule(series: Series, playlist: [PlaylistItem]? = nil, parent: Router? = nil) -> PlayerViewController {
        let module = PlayerViewController()
        let router = PlayerRouter(view: module, parent: parent)
        if playlist == nil {
            module.playerView = PlayerView()
        } else {
            module.playerView = MPVPlayerView()
        }
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, series: series, playlist: playlist)
        return module
    }
}

// MARK: - Route

protocol PlayerRoute {
    func openPlayer(series: Series)
    func openPlayer(series: Series, playlistItem: PlaylistItem)
}

extension PlayerRoute where Self: RouterProtocol {
    func openPlayer(series: Series) {
        let module = PlayerAssembly.createModule(series: series, parent: self)
        ModalRouter(target: module, parent: nil)
            .set(level: .statusBar)
            .move()
    }

    func openPlayer(series: Series, playlistItem: PlaylistItem) {
        let module = PlayerAssembly.createModule(series: series, playlist: [playlistItem], parent: self)
        ModalRouter(target: module, parent: nil)
            .set(level: .statusBar)
            .move()
    }
}
