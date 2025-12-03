//
//  EpisodesRepository.swift
//  Anilibria
//
//  Created by Ivan Morozov on 26.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import DITranquillity
import Foundation
import Combine
import CoreData

final class EpisodesRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(EpisodesRepositoryImp.init)
            .as(EpisodesRepository.self)
            .lifetime(.single)
    }
}

protocol EpisodesRepository {
    func set(timeCodeData: TimeCodeData, for seriesID: Int)
    func set(timeCodeData: [TimeCodeData], for seriesID: Int)
    func getTimeCode(for userID: Int?, episodeID: String) -> TimeCodeData?
    func getTimeCodes(for userID: Int?, seriesID: Int) -> AnyPublisher<[String: TimeCodeData], Never>
}

final class EpisodesRepositoryImp: EpisodesRepository {
    let holder: CoreDataHolder

    init(holder: CoreDataHolder) {
        self.holder = holder
    }

    func set(timeCodeData: TimeCodeData, for seriesID: Int) {
        let context = holder.context
        context.performAndWait {
            let predicate = NSPredicate(
                format: "episodeID == %@",
                timeCodeData.episodeID
            )
            let entity = context.fetch(EpisodeContextEntity.self, predicate: predicate)
                .first ?? EpisodeContextEntity(context: context)
            entity.update(with: timeCodeData, seriesID: seriesID)
            context.saveIfNeeded()
        }
    }

    func getTimeCode(for userID: Int?, episodeID: String) -> TimeCodeData? {
        holder.context.performAndWaitWithResult {
            holder.context.fetch(
                EpisodeContextEntity.self,
                predicate: NSPredicate(
                    format: "userID == %i AND episodeID == %@",
                    userID ?? 0,
                    episodeID
                )
            )
            .first?.toTimeCode()
        }
    }

    func set(timeCodeData: [TimeCodeData], for seriesID: Int) {
        let context = holder.context
        var items: [String: TimeCodeData] = [:]
        timeCodeData.forEach { data in
            items[data.episodeID] = data
        }
        context.performAndWait {
            let predicate = NSPredicate(
                format: "episodeID in %@",
                Array(items.keys)
            )
            let entities = context.fetch(EpisodeContextEntity.self, predicate: predicate)
            entities.forEach { entity in
                if let data = items.removeValue(forKey: entity.episodeID ?? "") {
                    entity.update(with: data, seriesID: seriesID)
                }
            }

            items.values.forEach { data in
                let entity = EpisodeContextEntity(context: context)
                entity.update(with: data, seriesID: seriesID)
            }

            context.saveIfNeeded()
        }
    }

    func getTimeCodes(for userID: Int?, seriesID: Int) -> AnyPublisher<[String: TimeCodeData], Never> {
        holder.getBackgroundContext().map { context in
            let predicate = NSPredicate(
                format: "userID == %i AND seriesID == %i",
                userID ?? 0,
                seriesID
            )
            return context.fetch(EpisodeContextEntity.self, predicate: predicate)
                .reduce([:], { result, item in
                    var nextResult = result
                    if let id = item.episodeID {
                        nextResult[id] = item.toTimeCode()
                    }
                    return nextResult
                })
        }.eraseToAnyPublisher()
    }
}

extension EpisodeContextEntity {
    func toTimeCode() -> TimeCodeData {
        TimeCodeData(
            episodeID: episodeID ?? "",
            userID: userID == 0 ? nil : Int(userID),
            time: time,
            isWatched: isWatched,
            updatedAt: updatedAt
        )
    }

    func update(with data: TimeCodeData, seriesID: Int) {
        if self.episodeID?.isEmpty != false {
            self.episodeID = data.episodeID
        }
        if let id = data.userID {
            self.userID = Int64(id)
        } else {
            self.userID = 0
        }
        self.time = data.time
        self.isWatched = data.isWatched
        self.updatedAt = data.updatedAt
        self.seriesID = Int64(seriesID)
    }
}
