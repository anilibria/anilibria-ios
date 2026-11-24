import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class ListItem<T>: NSObject {
    var value: T

    public init(_ value: T) {
        self.value = value
    }
}
