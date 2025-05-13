import UIKit

final class ChoiceSheetAssembly {
    static func createModule(
        source: any ChoiceGroupSource,
        parent: Router? = nil
    ) -> ChoiceSheetViewController {
        let module = ChoiceSheetViewController()
        let router = ChoiceSheetRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, source: source)
        return module
    }
}

// MARK: - Route

protocol ChoiceSheetRoute {
    func openSheet(with source: any ChoiceGroupSource)
}

extension ChoiceSheetRoute where Self: RouterProtocol {
    func openSheet(with source: any ChoiceGroupSource) {
        let module = ChoiceSheetAssembly.createModule(source: source, parent: self)
        PresentRouter(target: module,
                      from: nil,
                      use: BlurPresentationController.self,
                      configure: {
                          $0.isBlured = true
                          $0.transformation = MoveUpTransformation()
        }).set(level: .statusBar).move()
    }

    func openSheet(with items: [ChoiceGroup]) {
        openSheet(with: SimpleChoiceGroupSource(items: items))
    }
}
