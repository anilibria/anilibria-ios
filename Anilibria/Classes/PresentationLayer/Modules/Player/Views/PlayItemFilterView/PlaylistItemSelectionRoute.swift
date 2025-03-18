//
//  PlaylistItemSelectionRoute.swift
//  Anilibria
//
//  Created by Ivan Morozov on 17.03.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

protocol PlaylistItemSelectionRoute {
    func openItemSelection(with model: PlaylistItemSelectionModel)
}

extension PlaylistItemSelectionRoute where Self: RouterProtocol {
    func openItemSelection(with model: PlaylistItemSelectionModel) {
        let view = PlayItemFilterView()
        view.viewModel = model
        let module = ChoiceSheetAssembly.createModule(source: model, parent: self)
        module.additionalView = view
        PresentRouter(target: module,
                      from: nil,
                      use: BlurPresentationController.self,
                      configure: {
                          $0.isBlured = true
                          $0.transformation = MoveUpTransformation()
        }).set(level: .statusBar).move()
    }
}
