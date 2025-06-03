import Foundation
import UIKit

public enum MenuItemType: String, CaseIterable {
    case feed, catalog, news, collections, other

    var index: Int {
        return MenuItemType.allCases.firstIndex(of: self) ?? 0
    }
}

public typealias DoubleImage = (normal: UIImage, selected: UIImage)

public final class MenuItem: NSObject {
    let type: MenuItemType
    let icon: UIImage?

    public init(type: MenuItemType, icon: UIImage?) {
        self.type = type
        self.icon = icon
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? MenuItem {
            return self.type == other.type
        }
        return super.isEqual(object)
    }
}

public final class MenuListItem: ListItem<[MenuItem]> {}

public final class MenuItemsFactory {
    static func create() -> [MenuItem] {
        return [
            MenuItem(type: .feed, icon: UIImage(resource: .menuItemFeed)),
            MenuItem(type: .catalog, icon: UIImage(resource: .menuItemSearch)),
            MenuItem(type: .news, icon: UIImage(resource: .menuItemYoutube)),
            MenuItem(type: .collections, icon: UIImage(systemName: "book")),
            MenuItem(type: .other, icon: UIImage(resource: .menuItemSettings))
        ]
    }
}
