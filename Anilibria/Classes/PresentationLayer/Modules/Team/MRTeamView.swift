import UIKit

final class TeamViewController: BaseCollectionViewController {
    var handler: TeamEventHandler!

    #if targetEnvironment(macCatalyst)
    private lazy var refreshButton = BarButton(image: UIImage(resource: .iconRefresh)) { [weak self] in
        _ = self?.showRefreshIndicator()
        self?.scrollToTop()
        self?.handler.refresh()
    }
    #endif

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavbar()
        self.addRefreshControl()
        self.handler.didLoad()
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Other.team
    }

    override func refresh() {
        super.refresh()
        self.handler.refresh()
    }

    private func setupNavbar() {
        #if targetEnvironment(macCatalyst)
        navigationItem.setRightBarButtonItems([refreshButton] ,animated: false)
        #endif
    }
}

extension TeamViewController: TeamViewBehavior {
    func scrollToTop() {
        self.collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.contentInset.top)
    }

    func set(items: [TeamGroup]) {
        scrollToTop()
        self.set(sections: items.map { TeamMemberSectionAdapter(group: $0) })
    }
}
