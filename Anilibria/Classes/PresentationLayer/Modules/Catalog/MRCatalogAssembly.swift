import UIKit

final class CatalogAssembly {
    static func createModule(data: SeriesSearchData = SeriesSearchData(), parent: Router? = nil) -> CatalogViewController {
        let module = CatalogViewController()
        let router = CatalogRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router, data: data)
        return module
    }
}

// MARK: - Route

protocol CatalogRoute {
    func openCatalog(data: SeriesSearchData)
}

extension CatalogRoute where Self: RouterProtocol {
    func openCatalog(data: SeriesSearchData) {
        let module = CatalogAssembly.createModule(data: data, parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
