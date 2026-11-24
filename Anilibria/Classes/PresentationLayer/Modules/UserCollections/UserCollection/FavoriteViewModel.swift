//
//  FavoriteViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 22.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import DITranquillity
import Combine
import UIKit

final class FavoritePart: DIPart {
    static func load(container: DIContainer) {
        container.register(FavoriteViewModel.init)
            .lifetime(.objectGraph)
    }
}

final class FavoriteViewModel: UserCollectionViewModelProtocol {
    private let limit: Int = 25
    private var nextPage: Int = 1
    private var pageSubscriber: AnyCancellable?
    private var bag = Set<AnyCancellable>()

    private let service: FavoriteService

    weak var activityBehavior: ActivityBehavior?
    private var router: UserCollectionRoutable?

    let items = CurrentValueSubject<[Series], Never>([])
    private var currentItems: [Series] {
        items.value
    }

    @Published private var searchData: SeriesSearchData = SeriesSearchData()

    var filterActive: AnyPublisher<Bool, Never> {
        $searchData.removeDuplicates().map { !$0.filter.isEmpty }.eraseToAnyPublisher()
    }

    private(set) var select: ((Series) -> Void)?
    private(set) var delete: ((Series) -> Void)?

    private(set) lazy var pagination = PaginationViewModel { [weak self] completion in
        self?.loadPage(completion: completion)
    }

    init(service: FavoriteService) {
        self.service = service

        select = { [weak self] item in
            self?.select(series: item)
        }

        delete = { [weak self] item in
            self?.unfavorite(series: item)
        }

        service.favoritesUpdates().sink { [weak self] updates in
            switch updates {
            case .added(let series):
                self?.append(series: series)
            case .deleted(let series):
                self?.remove(series: series)
            }
        }.store(in: &bag)
    }

    func bind(router: UserCollectionRoutable) {
        self.router = router
        self.router?.responder = self
    }

    private func load(with activity: ActivityDisposable?) {
        nextPage = 1
        pagination.reset()
        pageSubscriber = service.fetchSeries(limit: limit, page: nextPage, data: searchData)
            .manageActivity(activity)
            .sink(onNext: { [weak self, limit] items in
                self?.nextPage += 1
                self?.items.send(items)
                self?.pagination.isReady.send(items.count == limit)
            }, onError: { [weak self] error in
                self?.router?.show(error: error)
            })
    }

    func didLoad() {
        self.load(with: activityBehavior?.showLoading(fullscreen: false))
    }

    func refresh() {
        self.load(with: activityBehavior?.showRefreshIndicator())
    }

    func search(query: String) {
        searchData.search = query.lowercased()
        refresh()
    }

    func openFilter() {
        service.fetchFilterData()
            .manageActivity(activityBehavior?.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] data in
                guard let self else { return }
                router?.open(filter: searchData.filter, data: data)
            }, onError: { [weak self] error in
                self?.router?.show(error: error)
            })
            .store(in: &bag)
    }

    private func unfavorite(series: Series) {
        service.favorite(add: false, series: series)
            .manageActivity(activityBehavior?.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] _ in
                self?.remove(series: series)
            }, onError: { [weak self] error in
                self?.router?.show(error: error)
            })
            .store(in: &bag)
    }

    private func select(series: Series) {
        router?.open(series: series)
    }

    private func remove(series: Series) {
        var newItems = currentItems
        newItems.removeAll(where: { $0.id == series.id })
        items.send(newItems)
    }

    private func append(series: Series) {
        if searchData.filter.sorting == nil {
            var newItems = currentItems
            newItems.insert(series, at: 0)
            items.send(newItems)
        }
    }

    private func loadPage(completion: @escaping Action<Bool>) {
        pageSubscriber = service.fetchSeries(limit: limit, page: nextPage, data: searchData)
            .sink(onNext: { [weak self, limit] items in
                self?.nextPage += 1
                if var currentItems = self?.currentItems {
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

extension FavoriteViewModel: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let filterCommand = command as? FilterRouteCommand {
            if searchData.filter != filterCommand.value {
                searchData.filter = filterCommand.value
                refresh()
            }
            return true
        }
        return false
    }
}
