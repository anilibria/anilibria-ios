//
//  PaginationViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

class PaginationViewModel: NSObject {
    private(set) var isLoading: Bool = false
    private let loadAction: Action<Action<Bool>>
    let isReady = CurrentValueSubject<Bool, Never>(false)

    init(_ action: @escaping Action<Action<Bool>>) {
        self.loadAction = action
    }

    func reset() {
        isReady.send(false)
        isLoading = false
    }

    func load() {
        if isLoading || !isReady.value { return }
        isLoading = true
        loadAction({ [weak self] isLast in
            self?.isLoading = false
            self?.isReady.send(!isLast)
        })
    }
}
