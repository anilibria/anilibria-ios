import UIKit

final class FilterAssembly {
    static func createModule(_ filter: SeriesSearchData.Filter,
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
    func open(filter: SeriesSearchData.Filter, data: FilterData)
}

extension FilterRoute where Self: RouterProtocol {
    func open(filter: SeriesSearchData.Filter, data: FilterData) {
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
