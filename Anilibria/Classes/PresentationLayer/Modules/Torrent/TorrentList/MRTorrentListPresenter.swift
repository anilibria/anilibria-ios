//
//  MRTorrentListPresenter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import DITranquillity
import Combine
import UIKit

final class TorrentListPart: DIPart {
    static func load(container: DIContainer) {
        container.register(TorrentListPresenter.init)
            .as(TorrentListEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class TorrentListPresenter {
    private weak var view: TorrentListViewBehavior!
    private var router: TorrentListRoutable!
    private var metadata: TorrentMetaData!
    private var series: Series!
    private var activity: ActivityDisposable?
    private var bag = Set<AnyCancellable>()

    let torrentService: TorrentService

    init(torrentService: TorrentService) {
        self.torrentService = torrentService
    }
}

extension TorrentListPresenter: TorrentListEventHandler {
    func bind(view: TorrentListViewBehavior, router: TorrentListRoutable, metadata: TorrentMetaData, series: Series) {
        self.view = view
        self.router = router
        self.metadata = metadata
        self.series = series
    }

    func didLoad() {
        view.set(title: metadata.series)
        activity = self.view.showLoading(fullscreen: false)
        load()
    }

    func select(model: TorrentListItemViewModel) {
        if model.item.status == .ready {
            open(file: model.item)
            return
        }
        if model.operation != nil {
            return
        }
        TorrentClient.instance.makeOperation(series: model.item)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak model] operation in
                model?.operation = operation
                operation.download()
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func refresh() {
        activity = self.view.showRefreshIndicator()
        load()
    }

    private func open(file: SeriesFile?) {
        guard let url = file?.filePath else { return }
        router.openPlayer(series: series, playlistItem: .init(title: "", url: url))
    }

    private func load() {
        guard let url = metadata.url else { return }
        self.torrentService.fetchTorrentData(for: series.id, url: url)
            .manageActivity(activity)
            .sink(onNext: { [weak self] items in
                self?.view.set(items: items.map({ file in
                    TorrentListItemViewModel(
                        item: file,
                        operation: TorrentClient.instance.getExistingOperation(for: file)
                    )
                }))
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

}
