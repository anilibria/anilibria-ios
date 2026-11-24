//
//  EpisodesViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 28.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation
import Combine
import DITranquillity

class EpisodesViewModel {
    private var series: Series?
    private var userID: Int?
    private var reversed: Bool = false

    private var episodeIndexes: [String: Int] = [:]
    private var searchQuery: String = ""

    let items = CurrentValueSubject<[EpisodeViewModel]?, Never>(nil)
    private var list: [EpisodeViewModel] = [] {
        didSet {
            isEmpty = list.isEmpty
        }
    }
    
    @Published private(set) var isEmpty: Bool = true
    @Published private(set) var activeEpisode: PlaylistItem?

    private let playerService: PlayerService
    private var playerBag = Set<AnyCancellable>()
    private var updatesBag = Set<AnyCancellable>()

    var playHandler: ((PlaylistItem) -> Void)?
    var showOptionsHandler: (([ChoiceGroup]) -> Void)?

    init(playerService: PlayerService) {
        self.playerService = playerService
    }

    func set(series: Series, userID: Int?) {
        self.userID = userID
        self.series = series
        loadTimeCodes()
    }

    private func loadTimeCodes() {
        guard let series else { return }
        playerBag.removeAll()
        playerService.getTimeCodes(userID: userID, episodeIDs: series.playlist.map(\.id))
            .sink { [weak self] data in
                guard let self else { return }
                list = series.playlist.reversed().enumerated().map { offset, item in
                    self.episodeIndexes[item.id] = offset
                    return EpisodeViewModel(
                        item: item,
                        timecode: data[item.id, default: .init(episodeID: item.id)],
                        didTapOnWatched: { [weak self] in self?.toggle(watching: $0) }
                    )
                }
                items.value = list
                updateActive()
            }.store(in: &playerBag)

        let timecodesUpdates = playerService.observeTimecodesUpdates()
            .filter { [series] in $0.seriesID == series.id }
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .map { [weak self] data -> Void in
                guard let self else { return }
                data.timeCodes.forEach {
                    if let index = self.episodeIndexes[$0.episodeID] {
                        self.list[index].timecode = $0
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .share()

        timecodesUpdates.sink { [weak self] in
            guard let self else { return }
            search(query: searchQuery)
        }
        .store(in: &playerBag)

        Publishers.CombineLatest(
            timecodesUpdates,
            playerService.observeHistoryUpdates()
                .filter { [series] in $0.seriesID == series.id }
        ).sink { [weak self] _, _ in
            self?.updateActive()
        }.store(in: &playerBag)
    }

    func search(query: String) {
        searchQuery = query.lowercased()
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            var result = self.list
            if searchQuery.isEmpty == false {
                result = result.filter {
                    $0.fullName.lowercased().contains(self.searchQuery)
                }
            }

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.reversed {
                    self.items.value = result.reversed()
                } else {
                    self.items.value = result
                }
            }
        }
    }

    func play(item: EpisodeViewModel) {
        self.playHandler?(item.item)
    }

    func toggleDirection() {
        reversed.toggle()
        if let value = items.value {
            items.value = value.reversed()
        }
    }

    func showOptions() {
        let items = [true, false].map {
            ChoiceItem(
                value: $0,
                title: $0 ? L10n.Common.watchAll : L10n.Common.unwatchAll,
                isSelected: false,
                didSelect: { [weak self] item in
                    self?.setAllAsWatched(isWatched: item)
                    return true
                }
            )
        }

        showOptionsHandler?([ChoiceGroup(items: items)])
    }

    private func setAllAsWatched(isWatched: Bool) {
        guard let series, !list.isEmpty else { return }
        playerService.set(
            timeCodes: list.lazy
                .filter { $0.timecode.isWatched != isWatched }
                .map { $0.toggleWatching().timecode },
            series: series,
            userID: userID
        )
    }

    private func toggle(watching episode: EpisodeViewModel) {
        guard let series else { return }
        playerService.set(
            timeCodes: [episode.toggleWatching().timecode],
            series: series,
            userID: userID
        )
    }


    private func updateActive() {
        guard let series else { return }
        let activeIndex = playerService.getActiveEpisodeID(for: series).flatMap({ id in
            list.firstIndex(where: { $0.item.id == id })
        }) ?? list.count - 1

        guard activeIndex > -1 else {
            activeEpisode = nil
            return
        }

        func searchActual(with index: Int) -> EpisodeViewModel {
            let target = list[index]
            if index == 0 || !target.timecode.isWatched {
                return target
            }
            return searchActual(with: index - 1)
        }

        activeEpisode = searchActual(with: activeIndex).item
    }
}

private extension EpisodeViewModel {
    func toggleWatching() -> EpisodeViewModel {
        var result = self
        result.timecode.isWatched.toggle()
        if result.timecode.isWatched {
            result.timecode.time = result.item.duration - 1
        } else {
            result.timecode.time = 0
        }
        return result
    }
}

private extension HistoryUpdates {
    var seriesID: Int {
        switch self {
        case .added(let series), .removed(let series):
            return series.id
        }
    }
}
