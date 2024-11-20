//
//  CatalogSectionsAdapter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class CatalogSectionsAdapter: SectionAdapterProtocol {
    private let seriesAdapter = SectionAdapter([])
    private let paginationAdapter = SectionAdapter([])
    private var context: AdapterContext?
    private let viewModel: CatalogViewModel

    private var cancellabes = Set<AnyCancellable>()

    init(_ viewModel: CatalogViewModel) {
        self.viewModel = viewModel

        viewModel.$items.sink { [weak self] series in
            guard let self else { return }
            let items = series.map {
                SeriesCellAdapter(viewModel: $0, seclect: viewModel.seclect)
            }

            seriesAdapter.set(items)
            context?.reload(section: seriesAdapter)
            if paginationAdapter.getItems().isEmpty && !items.isEmpty {
                paginationAdapter.set([PaginationAdapter(viewModel: viewModel.pagination)])
                context?.reload(section: paginationAdapter)
            }
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

    func getSectionLayout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        nil
    }
}
