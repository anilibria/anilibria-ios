//
//  CoreDataHolderPart.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation
import DITranquillity
import CoreData
import Combine

final class CoreDataHolderPart: DIPart {
    static func load(container: DIContainer) {
        container.register(CoreDataHolder.init)
            .lifetime(.single)
    }
}

final class CoreDataHolder {
    private let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }

    init() {
        self.container = NSPersistentContainer(name: "DataStorage")
        self.container.loadPersistentStores { [weak self] desc, error in
            if let error = error {
                assertionFailure("\(error)")
                self?.log(.error, "\(error)\nDESC: \(desc)")
            }
        }
    }

    func getBackgroundContext() -> AnyPublisher<NSManagedObjectContext, Never> {
        AnyPublisher.create { [unowned self] promise in
            container.performBackgroundTask { context in
                promise(.send(context))
                promise(.completed)
            }
            return AnyCancellable {}
        }
    }
}

extension CoreDataHolder: Loggable {
    var defaultLoggingTag: LogTag { .unnamed }
}
