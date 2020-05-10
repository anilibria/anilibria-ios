import UIKit

public class Selectable<T>: NSObject {
    var value: T
    @objc dynamic var isSelected: Bool = false

    init(_ value: T) {
        self.value = value
    }
}
