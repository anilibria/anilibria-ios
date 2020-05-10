import UIKit

public class ListItem<T>: NSObject {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}
