//
//  SeriesRepository.swift
//  Anilibria
//
//  Created by Ivan Morozov on 26.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import DITranquillity
import Foundation
import Combine
import CoreData

final class SeriesRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(SeriesRepositoryImp.init)
            .as(SeriesRepository.self)
            .lifetime(.single)
    }
}

protocol SeriesRepository {
    func getAllSeries() -> AnyPublisher<[Series], Never>
    func getSeriesWithPlayerContext() -> AnyPublisher<[Series], Never>

    func set(playerContext: PlayerContext?, series: Series)
    func getPlayerContext(for seriesID: Int) -> AnyPublisher<PlayerContext?, Never>
}

final class SeriesRepositoryImp: SeriesRepository {
    let holder: CoreDataHolder

    init(holder: CoreDataHolder) {
        self.holder = holder

        self.migrationIfNeeded()
    }

    func getAllSeries() -> AnyPublisher<[Series], Never> {
        return holder.getBackgroundContext()
            .map { context in
                let decoder = JSONDecoder()
                return context.fetch(SeriesDataEntity.self)
                    .compactMap { $0.getSeries(with: decoder) }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getSeriesWithPlayerContext() -> AnyPublisher<[Series], Never> {
        return holder.getBackgroundContext()
            .map { context in
                let decoder = JSONDecoder()
                return context.fetch(
                    PlayerContextEntity.self,
                    sortDescriptors: [NSSortDescriptor(key: "updatedAt", ascending: false)]
                )
                .compactMap { $0.seriesData?.getSeries(with: decoder) }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func add(series: Series) {
        let context = holder.context
        context.performAndWait {
            let predicate = NSPredicate(
                format: "id == %i",
                series.id
            )
            let entity = context.fetch(SeriesDataEntity.self, predicate: predicate).first
            if entity != nil {
                entity?.update(with: series)
            } else {
                SeriesDataEntity.make(from: series, context: context)
            }
            context.saveIfNeeded()
        }
    }

    func set(playerContext: PlayerContext?, series: Series) {
        let context = holder.context
        context.performAndWait {
            let predicate = NSPredicate(
                format: "id == %i",
                series.id
            )
            if let playerContext {
                let entity = context.fetch(SeriesDataEntity.self, predicate: predicate)
                    .first?
                    .apply { $0.update(with: series) } ?? SeriesDataEntity.make(from: series, context: context)
                entity?.update(playerContext: playerContext, context: context)
                context.saveIfNeeded()
            } else {
                context.deleteAll(SeriesDataEntity.self, predicate: predicate)
            }
            context.saveIfNeeded()
        }
    }

    func getPlayerContext(for seriesID: Int) -> AnyPublisher<PlayerContext?, Never> {
        return holder.getBackgroundContext()
            .map { context in
                let predicate = NSPredicate(
                    format: "seriesID == %i",
                    seriesID
                )
                return context.fetch(PlayerContextEntity.self, predicate: predicate)
                    .first?
                    .toContext()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}

extension PlayerContextEntity {
    func toContext(with decoder: JSONDecoder = JSONDecoder()) -> PlayerContext? {
        guard let data else { return nil }
        return try? decoder.decode(PlayerContext.self, from: data)
    }
}

extension SeriesDataEntity {
    func getSeries(with decoder: JSONDecoder = JSONDecoder()) -> Series? {
        guard let series else { return nil }
        return try? decoder.decode(Series.self, from: series)
    }

    @discardableResult
    static func make(from series: Series, context: NSManagedObjectContext) -> SeriesDataEntity? {
        guard let data = try? JSONEncoder().encode(series) else {
            return nil
        }
        let newEntity = SeriesDataEntity(context: context)
        newEntity.id = Int64(series.id)
        newEntity.series = data
        return newEntity
    }

    func update(with series: Series) {
        guard let data = try? JSONEncoder().encode(series) else {
            return
        }
        self.series = data
    }

    func update(
        playerContext: PlayerContext,
        updatedAt: Date = Date(),
        context: NSManagedObjectContext
    ) {
        guard let data = try? JSONEncoder().encode(playerContext) else {
            return
        }

        if let current = self.playerContext {
            current.data = data
            current.updatedAt = updatedAt
        } else {
            let value = PlayerContextEntity(context: context)
            value.data = data
            value.seriesID = self.id
            value.seriesData = self
            value.updatedAt = updatedAt
            self.playerContext = value
        }
    }
}
