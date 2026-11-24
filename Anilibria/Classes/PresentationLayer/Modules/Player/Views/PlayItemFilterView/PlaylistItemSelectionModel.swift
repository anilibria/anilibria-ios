//
//  PlaylistItemSelectionModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 17.03.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation
import UIKit

final class PlaylistItemSelectionModel: ActionSheetGroupSource {
    private let selected: PlaylistItem
    private var items: [ChoiceItem] = []
    private var reloadItems: (([ChoiceGroup]) -> Void)?

    private let episodeNumberBuilder = AttributeStringBuilder()
        .set(font: UIFont.font(ofSize: 17, weight: .semibold))
        .set(color: .Text.monoLight)

    private let episodeNameBuilder = AttributeStringBuilder()
        .set(font: UIFont.font(ofSize: 15, weight: .regular))
        .set(color: .Text.monoLight.withAlphaComponent(0.8))

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
            var result = NSMutableAttributedString()
            if let number = value.episode {
                result = episodeNumberBuilder.build(number)
            }
            if let name = value.title {
                if result.string.isEmpty {
                    result = episodeNumberBuilder.build(name)
                } else {
                    result = result + NSMutableAttributedString(string: "\n") + episodeNameBuilder.build(name)
                }
            }

            return ChoiceItem(
                value: value,
                title: result,
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
                $0.title.string.localizedCaseInsensitiveContains(text)
            }
        }

        reloadItems?([ChoiceGroup(items: result)])
    }
}
