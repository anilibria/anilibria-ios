//
//  Migrations.swift
//  Anilibria
//
//  Created by Ivan Morozov on 26.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

// Migration from old format
extension SeriesRepositoryImp {
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
                let entity = SeriesDataEntity.make(from: data.series, context: holder.context)
                entity?.update(
                    playerContext: data.context,
                    updatedAt: Date(timeIntervalSince1970: TimeInterval(offset)),
                    context: holder.context
                )
            }
            holder.context.saveIfNeeded()
        }
    }
}
