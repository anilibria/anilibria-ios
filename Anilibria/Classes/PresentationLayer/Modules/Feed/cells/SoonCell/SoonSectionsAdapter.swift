//
//  SoonSectionsAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class SoonSectionsAdapter: SectionAdapterProtocol {
    private let soonAdapter: SectionAdapter
    private let scheduleAdapter = ScheduleSeriesSectionAdapter([])
    private var context: AdapterContext?
    private let viewModel: SoonViewModel

    private var cancellabes = Set<AnyCancellable>()

    init(_ viewModel: SoonViewModel) {
        self.viewModel = viewModel
        self.soonAdapter = SectionAdapter([SoonCellAdapter(viewModel: viewModel)])

        viewModel.selectedDay.sink { [weak self] _ in
            guard let self else { return }
            let items = viewModel.items.map {
                ScheduleSeriesCellAdapter(viewModel: $0, seclect: viewModel.selectSeries)
            }

            scheduleAdapter.set(items)
            context?.reloadItems(in: scheduleAdapter)
        }.store(in: &cancellabes)
    }

    func set(context: AdapterContext) {
        self.context = context
    }

    func getIdentifiers() -> [AnyHashable] {
        soonAdapter.getIdentifiers() + scheduleAdapter.getIdentifiers()
    }

    func getItems(for identifier: AnyHashable?) -> [AnyCellAdapter] {
        soonAdapter.getItems(for: identifier) +
        scheduleAdapter.getItems(for: identifier)
    }

    func getSectionLayout(
        for identifier: AnyHashable,
        environment: any NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        if let layout = soonAdapter.getSectionLayout(for: identifier, environment: environment) {
            return layout
        }
        if let layout = scheduleAdapter.getSectionLayout(for: identifier, environment: environment) {
            return layout
        }
        return nil
    }
}
