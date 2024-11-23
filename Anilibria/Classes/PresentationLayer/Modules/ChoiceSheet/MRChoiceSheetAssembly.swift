import UIKit

final class ChoiceSheetAssembly {
    class func createModule(items: [ChoiceGroup], parent: Router? = nil) -> ChoiceSheetViewController {
        let module = ChoiceSheetViewController()
        let router = ChoiceSheetRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, items: items)
        return module
    }
}

// MARK: - Route

protocol ChoiceSheetRoute {
    func openSheet(with items: [ChoiceGroup])
}

extension ChoiceSheetRoute where Self: RouterProtocol {
    func openSheet(with items: [ChoiceGroup]) {
        let module = ChoiceSheetAssembly.createModule(items: items, parent: self)
        PresentRouter(target: module,
                      from: nil,
                      use: BlurPresentationController.self,
                      configure: {
                          $0.isBlured = true
                          $0.transformation = MoveUpTransformation()
        }).set(level: .statusBar).move()
    }
}
