//
//  CatalogSectionsAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

protocol SeriesViewModelProtocol {
    var items: CurrentValueSubject<[Series], Never> { get }
    var select: ((Series) -> Void)? { get }
    var delete: ((Series) -> Void)? { get }
    var pagination: PaginationViewModel { get }
}

extension SeriesViewModelProtocol {
    var delete: ((Series) -> Void)? { nil }
}

final class SeriesSectionsAdapter: SectionAdapterProtocol {
    private let seriesAdapter = SectionAdapter([])
    private let paginationAdapter = SectionAdapter([])
    private var context: AdapterContext?
    private let viewModel: any SeriesViewModelProtocol

    private var cancellabes = Set<AnyCancellable>()

    init(_ viewModel: any SeriesViewModelProtocol) {
        self.viewModel = viewModel
        seriesAdapter.estimatedHeight = 140
        paginationAdapter.estimatedHeight = 84

        let factory: (Series) -> BaseCellAdapter<Series>
        if viewModel.delete != nil {
            factory = {
                RemovableSeriesCellAdapter(
                    viewModel: $0,
                    handler: .init(
                        select: viewModel.select,
                        delete: viewModel.delete
                    )
                )
            }
        } else {
            factory = {
                SeriesCellAdapter(viewModel: $0, seclect: viewModel.select)
            }
        }

        viewModel.items.sink { [weak self] series in
            guard let self else { return }
            let items = series.map { factory($0) }

            seriesAdapter.set(items)
            context?.reloadItems(in: seriesAdapter)
        }.store(in: &cancellabes)

        viewModel.pagination.isReady.removeDuplicates().sink { [weak self] value in
            guard let self else { return }
            if value {
                paginationAdapter.set([PaginationAdapter(viewModel: viewModel.pagination)])
            } else {
                paginationAdapter.set([])
            }
            context?.reloadItems(in: paginationAdapter, animated: false)
        }.store(in: &cancellabes)
    }

    func set(context: AdapterContext) {
        self.context = context
    }

    func getIdentifiers() -> [AnyHashable] {
        seriesAdapter.getIdentifiers() + paginationAdapter.getIdentifiers()
    }

    func getItems(for identifier: AnyHashable?) -> [AnyCellAdapter] {
        seriesAdapter.getItems(for: identifier) +
        paginationAdapter.getItems(for: identifier)
    }

    func getSectionLayout(
        for identifier: AnyHashable,
        environment: any NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        if let layout = seriesAdapter.getSectionLayout(for: identifier, environment: environment) {
            return layout
        }

        if let layout = paginationAdapter.getSectionLayout(for: identifier, environment: environment) {
            return layout
        }

        return nil
    }
}
