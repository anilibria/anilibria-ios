import UIKit

final class PlayerAssembly {
    static func createModule(series: Series, parent: Router? = nil) -> PlayerViewController {
        let module = PlayerViewController(
            viewModel: MainAppCoordinator.shared.container.resolve()
        )
        module.playerView = DefaultPlayerView()
        let router = PlayerRouter(view: module, parent: parent)
        module.viewModel.bind(router: router, series: series)
        return module
    }
}

// MARK: - Route

protocol PlayerRoute {
    func openPlayer(series: Series)
}

extension PlayerRoute where Self: RouterProtocol {
    func openPlayer(series: Series) {
        let module = PlayerAssembly.createModule(series: series, parent: self)
        PresentRouter(target: module,
                      from: controller,
                      use: BlurPresentationController.self,
                      configure: {
                          $0.isBlured = false
                          $0.transformation = ScaleTransformation()
        }).move()
    }
}
