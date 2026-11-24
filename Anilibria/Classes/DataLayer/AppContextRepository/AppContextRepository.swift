//
//  AppContextRepository.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import DITranquillity
import Foundation
import Combine
import CoreData

final class AppContextRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(AppContextRepositoryImp.init)
            .as(AppContextRepository.self)
            .lifetime(.single)
    }
}

protocol AppContextRepository {
    var lasTimeCodesSyncTime: Date? { get set }
}

private final class AppContextRepositoryImp: AppContextRepository {
    private let key: String = "USER_KEY"

    private var buffered: User?
    var lasTimeCodesSyncTime: Date?
}
