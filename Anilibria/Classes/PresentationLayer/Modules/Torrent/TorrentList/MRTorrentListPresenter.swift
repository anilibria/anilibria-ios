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
    private var client: TorrentClient?

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

    func select(file: SeriesFile) {
        if file.status == .ready {
            open(file: file)
            return
        }
        self.torrentService.makeClient(series: file)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] client in
                self?.client = client
                client.download()
                self?.open(file: file)
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
        self.torrentService.fetchTorrentData(for: series, url: url)
            .manageActivity(activity)
            .sink(onNext: { [weak self] items in
                self?.view.set(items: items)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

}
