//
//  Migrations.swift
//  Anilibria
//
//  Created by Ivan Morozov on 26.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

// Migration from old format
extension HistoryRepositoryImp {
    private struct HistoryHolder: Codable {
        var items: [HistoryData]
    }

    private struct HistoryData: Codable {
        let series: Series
        let context: PlayerContext?

        init(series: Series, context: PlayerContext) {
            self.series = series
            self.context = context
        }
    }

    func migrationIfNeeded() {
        let key = "HISTORY_KEY_2"

        guard let history: HistoryHolder = UserDefaults.standard[key] else {
            return
        }
        UserDefaults.standard[key] = nil
        migrate(history: history)
    }

    private func migrate(history: HistoryHolder) {
        holder.context.performAndWait {
            history.items.reversed().enumerated().forEach { offset, data in
                SeriesDataEntity.make(
                    from: data.series,
                    episodeIndex: data.context?.number ?? -1,
                    updatedAt: Date(timeIntervalSince1970: TimeInterval(offset)),
                    context: holder.context
                )
            }
            holder.context.saveIfNeeded()
        }
    }
}

private struct PlayerContext: Codable {
    var quality: VideoQuality
    var number: Int = 0
    var time: Double = 0
    var allItems: [Int: Double] = [:]

    enum CodingKeys: String, CodingKey {
        case quality
        case number
        case time
        case allItems
    }

    public init(quality: VideoQuality) {
        self.quality = quality
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quality = container.decode(.quality) ?? .fullHd
        number = container.decode(.number) ?? 0
        time = container.decode(.time) ?? 0
        allItems = container.decode(.allItems) ?? [:]
    }
}
