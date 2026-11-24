import Combine
import UIKit

final class MainContainerViewController: UITabBarController, UITabBarControllerDelegate {
    private let handler: MainContainerEventHandler

    private var pages: [MenuControllerData] = []
    private var collectionsVisible = false
    private var languageUpdates: AnyCancellable?

    init(handler: MainContainerEventHandler) {
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
        delegate = self
        handler.bind(view: self)
        handler.didLoad()
        languageUpdates = Language.languageChanged.sink { [weak self] _ in
            self?.updateTitles()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Surfaces.base
        tabBar.tintColor = .Tint.active
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let page = pages.first(where: { $0.controller === viewController }) else { return }
        handler.select(item: page.type)
    }

    private func updateTitles() {
        for page in pages {
            page.controller.tabBarItem.title = page.type.tabTitle
        }
    }

    private func updateVisibleTabs() {
        let selected = selectedViewController
        let controllers = pages.filter { $0.type != .collections || collectionsVisible }.map(\.controller)
        setViewControllers(controllers, animated: false)
        if let selected, controllers.contains(where: { $0 === selected }) {
            selectedViewController = selected
        }
    }
}

extension MainContainerViewController: MainContainerViewBehavior {
    func set(items: [MenuItem]) {
        pages = MenuItemsControllersFactory.create(for: items)
        for (item, page) in zip(items, pages) {
            let tab = UITabBarItem(title: item.type.tabTitle, image: item.icon, selectedImage: nil)
            tab.accessibilityIdentifier = "tab.\(item.type.rawValue)"
            page.controller.tabBarItem = tab
        }
        updateVisibleTabs()
    }

    func set(selected: MenuItemType) {
        guard let controller = pages.first(where: { $0.type == selected })?.controller,
              viewControllers?.contains(where: { $0 === controller }) == true else { return }
        selectedViewController = controller
    }

    func change(visible: Bool, for item: MenuItemType) {
        guard item == .collections, visible != collectionsVisible else { return }
        collectionsVisible = visible
        updateVisibleTabs()
    }
}

private extension MenuItemType {
    var tabTitle: String {
        switch self {
        case .feed: L10n.Screen.Feed.title
        case .catalog: L10n.Screen.Catalog.title
        case .news: L10n.Screen.News.title
        case .collections: L10n.Common.Collections.title
        case .other: L10n.Screen.Other.title
        }
    }
}
