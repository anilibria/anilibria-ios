import UIKit

final class PlayerAssembly {
    static func createModule(
        series: Series,
        userID: Int?,
        episode: PlaylistItem?,
        parent: Router? = nil
    ) -> PlayerViewController {
        let module = PlayerViewController(
            viewModel: MainAppCoordinator.shared.container.resolve()
        )
        module.playerView = DefaultPlayerView()
        let router = PlayerRouter(view: module, parent: parent)
        module.viewModel.bind(
            router: router,
            series: series,
            userID: userID,
            episode: episode
        )
        return module
    }
}

// MARK: - Route

protocol PlayerRoute {
    func openPlayer(userID: Int?, series: Series)
    func openPlayer(userID: Int?, series: Series, episode: PlaylistItem)
}

extension PlayerRoute where Self: RouterProtocol {
    func openPlayer(userID: Int?, series: Series) {
        play(userID: userID, series: series, episode: nil)
    }

    func openPlayer(userID: Int?, series: Series, episode: PlaylistItem) {
        play(userID: userID, series: series, episode: episode)
    }

    private func play(userID: Int?, series: Series, episode: PlaylistItem?) {
        let module = PlayerAssembly.createModule(
            series: series,
            userID: userID,
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
