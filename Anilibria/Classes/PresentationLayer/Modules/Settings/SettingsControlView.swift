//
//  SettingsControlView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 16.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class SettingsControlView: LoadableView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var button: UIButton!

    private var subscribers = Set<AnyCancellable>()

    func configure(item: SettingsControlItem) {
        titleLabel.text = item.title

        item.$value
            .sink { [weak self] value in
                self?.valueLabel.text = value
            }
            .store(in: &subscribers)
        
        button.publisher(for: .touchUpInside).sink {
            item.select()
        }.store(in: &subscribers)
    }
}

public final class SettingsControlItem {
    let title: String
    @Published var value: String
    private let action: ((SettingsControlItem) -> Void)

    init(
        title: String,
        value: String,
        action: @escaping (SettingsControlItem) -> Void
    ) {
        self.title = title
        self.value = value
        self.action = action
    }

    func select() {
        action(self)
    }
}
