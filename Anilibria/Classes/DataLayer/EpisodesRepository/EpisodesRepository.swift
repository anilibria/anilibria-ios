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
    func set(timeCodeData: [TimeCodeData], for userID: Int?)
    func getTimeCode(for userID: Int?, episodeID: String) -> TimeCodeData?
    func getTimeCodes(for userID: Int?, episodeIDs: [String]) -> AnyPublisher<[String: TimeCodeData], Never>
}

final class EpisodesRepositoryImp: EpisodesRepository {
    let holder: CoreDataHolder

    init(holder: CoreDataHolder) {
        self.holder = holder
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

    func set(timeCodeData: [TimeCodeData], for userID: Int?) {
        let context = holder.context
        var items: [String: TimeCodeData] = [:]
        timeCodeData.forEach { data in
            items[data.episodeID] = data
        }
        context.performAndWait {
            let predicate = NSPredicate(
                format: "userID == %i AND episodeID in %@",
                userID ?? 0,
                Array(items.keys)
            )
            let entities = context.fetch(EpisodeContextEntity.self, predicate: predicate)
            entities.forEach { entity in
                if let data = items.removeValue(forKey: entity.episodeID ?? "") {
                    entity.update(with: data, userID: userID)
                }
            }

            items.values.forEach { data in
                let entity = EpisodeContextEntity(context: context)
                entity.update(with: data, userID: userID)
            }

            context.saveIfNeeded()
        }
    }

    func getTimeCodes(for userID: Int?, episodeIDs: [String]) -> AnyPublisher<[String: TimeCodeData], Never> {
        holder.getBackgroundContext().map { context in
            let predicate = NSPredicate(
                format: "userID == %i AND episodeID in %@",
                userID ?? 0,
                episodeIDs
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
            time: time,
            isWatched: isWatched,
            updatedAt: updatedAt
        )
    }

    func update(with data: TimeCodeData, userID: Int?) {
        if self.episodeID?.isEmpty != false {
            self.episodeID = data.episodeID
        }
        if let id = userID {
            self.userID = Int64(id)
        } else {
            self.userID = 0
        }
        self.time = data.time
        self.isWatched = data.isWatched
        self.updatedAt = data.updatedAt
    }
}
