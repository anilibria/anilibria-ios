//
//  PlaylistItemSelectionModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 17.03.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

final class PlaylistItemSelectionModel: ActionSheetGroupSource {
    private let selected: PlaylistItem
    private var items: [ChoiceItem] = []
    private var reloadItems: (([ChoiceGroup]) -> Void)?

    var didSelect: ((PlaylistItem) -> Void)?

    var text: String = "" {
        didSet {
            updateItems()
        }
    }

    var isAscending: Bool = true {
        didSet {
            updateItems()
        }
    }

    init(series: Series, selected: PlaylistItem) {
        self.selected = selected

        let didSelect: (PlaylistItem) -> Bool = { [weak self] item in
            self?.didSelect?(item)
            return true
        }

        self.items = series.playlist.map { value in
            ChoiceItem(
                value: value,
                title: value.fullName,
                isSelected: value == selected,
                didSelect: didSelect
            )
        }
    }

    func fetchItems(_ handler: @escaping ([ChoiceGroup]) -> Void) {
        reloadItems = handler
        updateItems()
    }

    private func updateItems() {
        var result = isAscending ? items : items.reversed()

        if !text.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(text)
            }
        }

        reloadItems?([ChoiceGroup(items: result)])
    }
}
