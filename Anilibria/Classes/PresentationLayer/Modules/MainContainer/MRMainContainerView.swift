import UIKit

// MARK: - View Controller

final class MainContainerViewController: BaseViewController {
    @IBOutlet var menuTabBar: MenuTabController!
    @IBOutlet var pagerView: PagerView!

    var handler: MainContainerEventHandler!
    private var pages: [MenuControllerData] = []
    private var currentPages: [MenuControllerData] = []

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPager()
        self.handler.didLoad()
    }

    func setupPager() {
        self.pagerView.delegate = self
        self.pagerView.didIndexChanged { [weak self] index in
            if let type = self?.currentPages[safe: index]?.type {
                self?.menuTabBar.set(selected: type)
            }
        }
    }
}

extension MainContainerViewController: PagerViewDelegate {
    func numberOfPages(for pagerView: PagerView) -> Int {
        currentPages.count
    }

    func pagerView(_ pagerView: PagerView, pageFor index: Int) -> UIViewController? {
        currentPages[safe: index]?.controller
    }
}

extension MainContainerViewController: MainContainerViewBehavior {
    func set(items: [MenuItem]) {
        self.pages = MenuItemsControllersFactory.create(for: items)
        self.currentPages = pages
        self.menuTabBar.set(items) { [weak self] type in
            self?.handler.select(item: type)
        }
    }

    func set(selected: MenuItemType) {
        self.menuTabBar.set(selected: selected)
        if let index = currentPages.firstIndex(where: { $0.type == selected }) {
            self.pagerView.scrollTo(index: index, animated: true)
        }
    }

    func change(visible: Bool, for item: MenuItemType) {
        self.menuTabBar.change(visible: visible, for: item)
        self.currentPages.removeAll(where: { $0.type == item })
    }
}

final class MenuTabController: UIStackView {
    private var views: [MenuItemView] = []

    func set(_ items: [MenuItem], selectionChanged: @escaping Action<MenuItemType>) {
        self.views.forEach {
            $0.removeFromSuperview()
        }

        self.views = []

        items.forEach {
            let item = MenuItemView()
            item.configure($0)
            item.setTap(selectionChanged)
            self.views.append(item)
            self.addArrangedSubview(item)
        }
    }

    func set(selected: MenuItemType) {
        self.views.forEach {
            $0.isSelected = $0.type == selected
        }
    }

    func change(visible: Bool, for item: MenuItemType) {
        let value = self.views.first(where: { $0.type == item })
        value?.isHidden = !visible
    }
}
