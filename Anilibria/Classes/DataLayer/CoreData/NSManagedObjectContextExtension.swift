//
//  NSManagedObjectContextExtension.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObjectContext {
    func saveIfNeeded() {
        if !hasChanges { return }
        do {
            try save()
        } catch {
            assertionFailure("\(error)")
            rollback()
        }
    }

    func deleteAll<Entity: NSManagedObject>(
        _ type: Entity.Type,
        predicate: NSPredicate? = nil
    ) {
        _ = deleteAllWithResult(type, predicate: predicate)
    }

    func deleteAllWithResult<Entity: NSManagedObject>(
        _ type: Entity.Type,
        predicate: NSPredicate? = nil
    ) -> Int{
        let request = Entity.fetchRequest()
        request.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        let deleteResult = try? execute(deleteRequest) as? NSBatchDeleteResult
        if let ids = deleteResult?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: ids],
                into: [self]
            )
            return ids.count
        }
        return 0
    }

    func fetch<Entity: NSManagedObject>(_ type: Entity.Type,
                                        sortDescriptors: [NSSortDescriptor] = [],
                                        predicate: NSPredicate? = nil) -> [Entity] {
        let request = Entity.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate

        if let result = try? fetch(request) as? [Entity] {
            return result
        }
        return []
    }

    func count<Entity: NSManagedObject>(_ type: Entity.Type,
                                        sortDescriptors: [NSSortDescriptor] = [],
                                        predicate: NSPredicate? = nil) -> Int {
        let request = Entity.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate

        if let result = try? count(for: request) {
            return result
        }
        return 0
    }

    func performAndWaitWithResult<T>(_ block: @Sendable () -> T) -> T {
        if #available(iOS 15.0, *) {
            return performAndWait(block)
        } else {
            lazy var result: T = block()
            performAndWait {
                _ = result
            }
            return result
        }
    }
}
