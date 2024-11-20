//
//  CatalogViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Combine
import Foundation

final class CatalogViewModel {
    private var nextPage: Int = 1
    private var pageSubscriber: AnyCancellable?
    private let catalogService: CatalogService

    @Published var items: [Series] = []

    var router: CatalogRoutable?
    var filter: SeriesFilter = SeriesFilter()

    var seclect: ((Series) -> Void)?

    private(set) lazy var pagination = PaginationViewModel { [weak self] completion in
        self?.loadPage(completion: completion)
    }

    init(catalogService: CatalogService) {
        self.catalogService = catalogService
    }

    func load(activity: ActivityDisposable?) {
        nextPage = 1
        pagination.isLast = false
        pageSubscriber = catalogService.fetchCatalog(page: nextPage, filter: filter)
            .sink(onNext: { [weak self] items in
                self?.nextPage += 1
                self?.items = items
                activity?.dispose()
            }, onError: { [weak self] error in
                self?.router?.show(error: error)
                activity?.dispose()
            })
    }

    private func loadPage(completion: @escaping Action<Bool>) {
        pageSubscriber = catalogService.fetchCatalog(page: nextPage, filter: filter)
            .sink(onNext: { [weak self] items in
                self?.nextPage += 1
                self?.items.append(contentsOf: items)
                completion(items.isEmpty)
            }, onError: { [weak self] error in
                self?.router?.show(error: error)
                completion(false)
            })
    }
}
