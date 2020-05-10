import UIKit

final class FilterAssembly {
    class func createModule(_ filter: SeriesFilter,
                            data: FilterData,
                            parent: Router? = nil) -> FilterViewController {
        let module = FilterViewController()
        let router = FilterRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module,
                            router: router,
                            filter: filter,
                            data: data)
        return module
    }
}

// MARK: - Route

protocol FilterRoute {
    func open(filter: SeriesFilter, data: FilterData)
}

extension FilterRoute where Self: RouterProtocol {
    func open(filter: SeriesFilter, data: FilterData) {
        let module = FilterAssembly.createModule(filter, data: data, parent: self)
        PresentRouter(target: module,
                      from: nil,
                      use: BlurPresentationController.self,
                      configure: {
                          $0.isBlured = false
                          $0.transformation = MoveUpTransformation()
        }).move()
    }
}
