//
//  CatalogViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Combine
import Foundation

final class CatalogViewModel: SeriesViewModelProtocol {
    private let limit: Int = 25
    private var nextPage: Int = 1
    private var pageSubscriber: AnyCancellable?
    private let catalogService: CatalogService

    let items = CurrentValueSubject<[Series], Never>([])

    var router: CatalogRoutable?
    var searchData: SeriesSearchData = SeriesSearchData()

    var select: ((Series) -> Void)?

    private(set) lazy var pagination = PaginationViewModel { [weak self] completion in
        self?.loadPage(completion: completion)
    }

    init(catalogService: CatalogService) {
        self.catalogService = catalogService
    }

    func load(activity: ActivityDisposable?) {
        nextPage = 1
        pagination.reset()
        pageSubscriber = catalogService.fetchCatalog(page: nextPage, limit: limit, data: searchData)
            .sink(onNext: { [weak self, limit] items in
                self?.nextPage += 1
                self?.items.send(items)
                self?.pagination.isReady.send(items.count == limit)
                activity?.dispose()
            }, onError: { [weak self] error in
                self?.router?.show(error: error)
                activity?.dispose()
            })
    }

    private func loadPage(completion: @escaping Action<Bool>) {
        pageSubscriber = catalogService.fetchCatalog(page: nextPage, limit: limit, data: searchData)
            .sink(onNext: { [weak self, limit] items in
                self?.nextPage += 1
                if var currentItems = self?.items.value {
                    currentItems.append(contentsOf: items)
                    self?.items.send(currentItems)
                }
                completion(items.count < limit)
            }, onError: { [weak self] error in
                self?.router?.show(error: error)
                completion(false)
            })
    }
}
