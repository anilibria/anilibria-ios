import Foundation
import UIKit

public enum MenuItemType: String, CaseIterable {
    case feed, catalog, news, favorite, other

    var index: Int {
        return MenuItemType.allCases.firstIndex(of: self) ?? 0
    }
}

public typealias DoubleImage = (normal: UIImage, selected: UIImage)

public final class MenuItem: NSObject {
    let type: MenuItemType
    let icon: UIImage

    public init(type: MenuItemType, icon: UIImage) {
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
            MenuItem(type: .feed, icon: #imageLiteral(resourceName: "menu_item_feed.pdf")),
            MenuItem(type: .catalog, icon: #imageLiteral(resourceName: "menu_item_search.pdf")),
            MenuItem(type: .news, icon:#imageLiteral(resourceName: "menu_item_youtube.pdf")),
            MenuItem(type: .favorite, icon:#imageLiteral(resourceName: "star-outline")),
            MenuItem(type: .other, icon: #imageLiteral(resourceName: "menu_item_settings.pdf"))
        ]
    }
}
