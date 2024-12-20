import DITranquillity
import Foundation

final class HistoryRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(HistoryRepositoryImp.init)
            .as(HistoryRepository.self)
            .lifetime(.single)
    }
}

protocol HistoryRepository {
    func set(item: HistoryData)
    func remove(data id: Int)
    func set(items: [HistoryData])
    func getItems() -> [HistoryData]
}

final class HistoryRepositoryImp: HistoryRepository {
    private let key: String = "HISTORY_KEY_2"

    private var buffered: HistoryHolder?

    func set(items: [HistoryData]) {
        self.buffered = HistoryHolder(items: items)
        UserDefaults.standard[key] = self.buffered
    }

    func getItems() -> [HistoryData] {
        if let data = self.buffered {
            return data.items
        }

        self.buffered = UserDefaults.standard[key] ?? HistoryHolder(items: [])
        return self.buffered!.items
    }

    func set(item: HistoryData) {
        var items = self.getItems()
        items.removeAll(where: { $0.series.id == item.series.id })
        items.insert(item, at: 0)
        self.set(items: items)
    }

    func remove(data id: Int) {
        var items = self.getItems()
        items.removeAll(where: { $0.series.id == id })
        self.set(items: items)
    }
}

private struct HistoryHolder: Codable {
    var items: [HistoryData]
}
