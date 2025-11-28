import UIKit

final class PlayerAssembly {
    static func createModule(
        series: Series,
        episode: PlaylistItem?,
        parent: Router? = nil
    ) -> PlayerViewController {
        let module = PlayerViewController(
            viewModel: MainAppCoordinator.shared.container.resolve()
        )
        module.playerView = DefaultPlayerView()
        let router = PlayerRouter(view: module, parent: parent)
        module.viewModel.bind(router: router, series: series, episode: episode)
        return module
    }
}

// MARK: - Route

protocol PlayerRoute {
    func openPlayer(series: Series)
    func openPlayer(series: Series, episode: PlaylistItem)
}

extension PlayerRoute where Self: RouterProtocol {
    func openPlayer(series: Series) {
        play(series: series, episode: nil)
    }

    func openPlayer(series: Series, episode: PlaylistItem) {
        play(series: series, episode: episode)
    }

    private func play(series: Series, episode: PlaylistItem?) {
        let module = PlayerAssembly.createModule(
            series: series,
            episode: episode,
            parent: self
        )
        PresentRouter(target: module,
                      from: controller,
                      use: BlurPresentationController.self,
                      configure: {
                          $0.isBlured = false
                          $0.transformation = ScaleTransformation()
        }).move()
    }
}
