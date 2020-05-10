import Foundation

public struct HistoryData: Codable {
    let series: Series
    let context: PlayerContext?

    init(series: Series, context: PlayerContext) {
        self.series = series
        self.context = context
    }
}
