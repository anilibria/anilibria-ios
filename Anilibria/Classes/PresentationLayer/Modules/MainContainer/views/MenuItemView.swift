import UIKit

final class MenuItemView: LoadableView {
    @IBOutlet var iconView: UIImageView!
    private(set) var type: MenuItemType?

    private var tapHandler: Action<MenuItemType>?

    public var isSelected: Bool = false {
        didSet {
            self.iconView.tintColor = if isSelected {
                UIColor(resource: .Tint.active)
            } else {
                UIColor(resource: .Tint.main)
            }
        }
    }

    func configure(_ item: MenuItem) {
        self.iconView.image = item.icon
        self.type = item.type
    }

    func setTap(_ handler: @escaping Action<MenuItemType>) {
        self.tapHandler = handler
    }

    @IBAction func tapAction(_ sender: Any) {
        if let type = self.type {
            self.tapHandler?(type)
        }
    }
}
