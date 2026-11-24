//
//  PlayItemFilterView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 17.03.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class PlayItemFilterView: LoadableView {
    @IBOutlet var textField: UITextField!
    @IBOutlet var sortingButton: UIButton!

    private var cancellables: Set<AnyCancellable> = []
    var viewModel: PlaylistItemSelectionModel?

    override func setupNib() {
        super.setupNib()
        smoothCorners(with: 5)
        textField.placeholder = L10n.Common.Search.byName
        textField.placeHolderColor = UIColor.white.withAlphaComponent(0.5)
        textField.tintColor = .Text.monoLight

        textField.publisher(for: .editingDidEndOnExit).sink { [weak self] text in
            self?.textField.resignFirstResponder()
        }.store(in: &cancellables)

        textField.textPublisher.sink { [weak self] text in
            self?.viewModel?.text = text ?? ""
        }.store(in: &cancellables)

        sortingButton.publisher(for: .touchUpInside).sink { [weak self] in
                self?.viewModel?.isAscending.toggle()
        }.store(in: &cancellables)
    }
}
