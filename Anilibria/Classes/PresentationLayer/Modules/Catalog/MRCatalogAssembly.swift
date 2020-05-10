import UIKit

final class CatalogAssembly {
    class func createModule(filter: SeriesFilter = SeriesFilter(), parent: Router? = nil) -> CatalogViewController {
        let module = CatalogViewController()
        let router = CatalogRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, filter: filter)
        return module
    }
}

// MARK: - Route

protocol CatalogRoute {
    func openCatalog(filter: SeriesFilter)
}

extension CatalogRoute where Self: RouterProtocol {
    func openCatalog(filter: SeriesFilter) {
        let module = CatalogAssembly.createModule(filter: filter, parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
