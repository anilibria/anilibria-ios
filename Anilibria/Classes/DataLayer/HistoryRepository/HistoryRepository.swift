//
//  HistoryRepository.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import DITranquillity
import Foundation
import Combine
import CoreData

final class HistoryRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(HistoryRepositoryImp.init)
            .as(HistoryRepository.self)
            .lifetime(.single)
    }
}

protocol HistoryRepository {
    func getSeriesHistory() -> AnyPublisher<[Series], Never>
    func getActiveEpisode(for seriesID: Int) -> ActiveEpisode?
    func add(series: Series, episodeID: String)
    func remove(seriesID: Int)
}

final class HistoryRepositoryImp: HistoryRepository {
    let holder: CoreDataHolder

    init(holder: CoreDataHolder) {
        self.holder = holder

        self.migrationIfNeeded()
    }

    func getSeriesHistory() -> AnyPublisher<[Series], Never> {
        return holder.getBackgroundContext()
            .map { context in
                let decoder = JSONDecoder()
                return context.fetch(
                    SeriesDataEntity.self,
                    sortDescriptors: [NSSortDescriptor(key: "updatedAt", ascending: false)]
                )
                .compactMap { $0.getSeries(with: decoder) }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func add(series: Series, episodeID: String) {
        let context = holder.context
        context.performAndWait {
            let predicate = NSPredicate(
                format: "id == %i",
                series.id
            )
            let entity = context.fetch(SeriesDataEntity.self, predicate: predicate).first
            if entity != nil {
                entity?.update(with: series, episodeID: episodeID)
            } else {
                SeriesDataEntity.make(from: series, episodeID: episodeID, context: context)
            }
            context.saveIfNeeded()
        }
    }

    func remove(seriesID: Int) {
        let context = holder.context
        context.performAndWait {
            let predicate = NSPredicate(
                format: "id == %i",
                seriesID
            )
            context.deleteAll(SeriesDataEntity.self, predicate: predicate)
            context.saveIfNeeded()
        }
    }

    func getActiveEpisode(for seriesID: Int) -> ActiveEpisode? {
        let context = holder.context
        return context.performAndWaitWithResult {
            let predicate = NSPredicate(
                format: "id == %i",
                seriesID
            )
            let entity = context.fetch(SeriesDataEntity.self, predicate: predicate).first
            if let id = entity?.activeEpisodeID {
                return ActiveEpisode.id(id)
            }

            if let index = entity?.activeEpisodeIndex {
                return ActiveEpisode.index(Int(index))
            }

            return nil
        }
    }
}

extension SeriesDataEntity {
    func getSeries(with decoder: JSONDecoder = JSONDecoder()) -> Series? {
        guard let series else { return nil }
        return try? decoder.decode(Series.self, from: series)
    }

    @discardableResult
    static func make(
        from series: Series,
        episodeID: String? = nil,
        episodeIndex: Int = -1,
        updatedAt: Date = Date(),
        context: NSManagedObjectContext
    ) -> SeriesDataEntity? {
        guard let data = try? JSONEncoder().encode(series) else {
            return nil
        }
        let newEntity = SeriesDataEntity(context: context)
        newEntity.id = Int64(series.id)
        newEntity.series = data
        newEntity.activeEpisodeID = episodeID
        newEntity.activeEpisodeIndex = Int32(episodeIndex)
        newEntity.updatedAt = updatedAt
        return newEntity
    }

    func update(with series: Series, episodeID: String) {
        guard let data = try? JSONEncoder().encode(series) else {
            return
        }
        self.series = data
        self.activeEpisodeID = episodeID
        self.activeEpisodeIndex = -1
        self.updatedAt = Date()
    }
}

enum ActiveEpisode {
    case id(String)
    case index(Int)
}
