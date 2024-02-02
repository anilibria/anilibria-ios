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
    @Published private(set) var isLast: Bool = false
    
    init(_ action: @escaping Action<Action<Bool>>) {
        self.loadAction = action
    }
    
    func load() {
        if isLoading { return }
        isLoading = true
        loadAction({ [weak self] isLast in
            self?.isLoading = false
            self?.isLast = isLast
        })
    }
}
