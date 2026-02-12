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

final class EpisodesPart: DIPart {
    static func load(container: DIContainer) {
        container.register(EpisodesViewModel.init)
            .lifetime(.objectGraph)
    }
}

class EpisodesViewModel {
    private var series: Series!
    private var userID: Int?
    private var router: (any EpisodesRoutable)!
    private var reversed: Bool = false

    let items = CurrentValueSubject<[EpisodeViewModel]?, Never>(nil)
    private var list: [EpisodeViewModel] = []
    private var episodeIndexes: [String: Int] = [:]
    private var searchQuery: String = ""

    private let playerService: PlayerService
    private var bag = Set<AnyCancellable>()

    init(playerService: PlayerService) {
        self.playerService = playerService
    }

    func bind(userID: Int?, series: Series, router: any EpisodesRoutable) {
        self.userID = userID
        self.series = series
        self.router = router
    }

    func didLoad() {
        playerService.getTimeCodes(userID: userID, seriesID: series.id)
            .sink { [weak self] data in
                guard let self else { return }
                list = series.playlist.reversed().enumerated().map { [userID] offset, item in
                    self.episodeIndexes[item.id] = offset
                    return EpisodeViewModel(
                        item: item,
                        timecode: data[item.id, default: .init(episodeID: item.id, userID: userID)],
                        didTapOnWatched: { [weak self] in self?.toggle(watching: $0) }
                    )
                }
                items.value = list
            }.store(in: &bag)

        playerService.observeTimecodesUpdates()
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
            .sink { [weak self] in
                guard let self else { return }
                search(query: searchQuery)
            }
            .store(in: &bag)
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
        router?.openPlayer(userID: userID, series: series, episode: item.item)
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

        self.router.openSheet(with: [ChoiceGroup(items: items)])
    }

    private func setAllAsWatched(isWatched: Bool) {
        playerService.set(
            timeCodes: list.lazy
                .filter { $0.timecode.isWatched != isWatched }
                .map { $0.toggleWatching().timecode },
            for: series
        )
    }

    private func toggle(watching episode: EpisodeViewModel) {
        playerService.set(
            timeCodes: [episode.toggleWatching().timecode],
            for: series
        )
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
