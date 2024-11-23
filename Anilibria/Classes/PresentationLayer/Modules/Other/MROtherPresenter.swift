import DITranquillity
import Combine
import UIKit

final class OtherPart: DIPart {
    static func load(container: DIContainer) {
        container.register(OtherPresenter.init)
            .as(OtherEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class OtherPresenter {
    private weak var view: OtherViewBehavior!
    private var router: OtherRoutable!

    private let sessionService: SessionService
    private let linksService: LinksService

    private var bag = Set<AnyCancellable>()
    private var isAuthorized = false

    init(sessionService: SessionService,
         linksService: LinksService) {
        self.sessionService = sessionService
        self.linksService = linksService
    }
}

extension OtherPresenter: OtherEventHandler {
    func didLoad() {
        self.sessionService
            .fetchState()
            .sink(onNext: { [weak self] state in
                switch state {
                case .guest:
                    self?.isAuthorized = false
                    self?.view.set(user: nil, loading: false)
                case let .user(value):
                    self?.isAuthorized = true
                    self?.view.set(user: value, loading: false)
                case nil:
                    self?.view.set(user: nil, loading: true)
                }
            })
            .store(in: &bag)

        self.linksService
            .fetchLinks()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] items in
                self?.view.set(links: items)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)

    }

    func bind(view: OtherViewBehavior, router: OtherRoutable) {
        self.view = view
        self.router = router
    }

    func team() {
        self.router.openTeam()
    }

    func donate() {
        self.router.open(url: URLS.donate)
    }

    func settings() {
        self.router.openSettings()
    }

    func history() {
        self.router.openHistory()
    }

    func tap(link: LinkData) {
        if let url = link.url {
            self.router.open(url: url)
        }
    }

    func loginOrLogout() {
        if self.isAuthorized {
            self.sessionService.logout()
        } else {
            self.router.signInScreen()
        }
    }
}
