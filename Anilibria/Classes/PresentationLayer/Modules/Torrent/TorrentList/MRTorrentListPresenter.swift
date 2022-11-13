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
    private var torrentData: TorrentData?
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

    func select(file: TorrentFile) {
        guard let torrent = torrentData else { return }
        self.torrentService.download(series: series, torrent: torrent, file: file)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] url in
                self?.open(file: file, url: url)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func refresh() {
        activity = self.view.showRefreshIndicator()
        load()
    }

    private func open(file: TorrentFile, url: URL?) {
        guard let url = url, let index = torrentData?.content.files.firstIndex(of: file) else { return }
        router.openPlayer(series: series, playlistItem: .init(title: file.name,
                                                              url: url))
    }

    private func load() {
        guard let url = metadata.url else { return }
        self.torrentService.fetchTorrentData(for: url)
            .manageActivity(activity)
            .sink(onNext: { [weak self] item in
                self?.updateData(item)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    private func updateData(_ item: TorrentData) {
        self.torrentData = item
        self.view.set(items: item.content.files)
    }
}
