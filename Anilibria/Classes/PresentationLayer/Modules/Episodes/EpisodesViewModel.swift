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
    private var router: (any EpisodesRoutable)!
    private var reversed: Bool = false

    let items = CurrentValueSubject<[PlaylistItem], Never>([])

    func bind(series: Series, router: any EpisodesRoutable) {
        self.series = series
        self.router = router
        items.value = series.playlist
    }

    func search(query: String) {
        let query = query.lowercased()
        DispatchQueue.global().async { [weak self] in
            var result = self?.series.playlist ?? []
            if query.isEmpty == false {
                result = result.filter {
                    $0.fullName.lowercased().contains(query)
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

    func play(item: PlaylistItem) {
        router?.openPlayer(series: series, episode: item)
    }

    func toggleDirection() {
        reversed.toggle()
        items.value.reverse()
    }
}
