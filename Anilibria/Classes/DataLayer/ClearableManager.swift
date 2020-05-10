import Foundation

protocol Clearable {
    func clear()
}

protocol ClearableManager: Clearable {}

final class ClearableManagerImp: ClearableManager {
    private let items: [Clearable]

    init(items: [Clearable]) {
        self.items = items
    }

    func clear() {
        self.items.forEach { $0.clear() }
    }
}
