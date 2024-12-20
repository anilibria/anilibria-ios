import DITranquillity
import Combine
import UIKit

final class TeamPart: DIPart {
    static func load(container: DIContainer) {
        container.register(TeamPresenter.init)
            .as(TeamEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class TeamPresenter {
    private weak var view: TeamViewBehavior!
    private var router: TeamRoutable!

    private let service: MainService

    private var subscriber: AnyCancellable?

    init(service: MainService) {
        self.service = service
    }
}

extension TeamPresenter: TeamEventHandler {
    func bind(view: TeamViewBehavior,
              router: TeamRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        load(activity: view.showLoading(fullscreen: false))
    }

    func refresh() {
        load(activity: view.showRefreshIndicator())
    }

    private func load(activity: ActivityDisposable?) {
        subscriber = service.fetchTeamMembers()
            .sink(onNext: { [weak self] members in
                let items = Dictionary(grouping: members, by: \.team).map {
                    TeamGroup(team: $0, members: $1)
                }.sorted(by: { $0.team.sortOrder < $1.team.sortOrder })
                self?.view.set(items: items)
                activity?.dispose()
            }, onError: { [weak self] error in
                self?.router?.show(error: error)
                activity?.dispose()
            })
    }
}
