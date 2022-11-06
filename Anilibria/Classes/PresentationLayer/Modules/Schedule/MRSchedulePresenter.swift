import DITranquillity
import Combine
import UIKit

final class SchedulePart: DIPart {
    static func load(container: DIContainer) {
        container.register(SchedulePresenter.init)
            .as(ScheduleEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class SchedulePresenter {
    private weak var view: ScheduleViewBehavior!
    private var router: ScheduleRoutable!
    private var schedules: [Schedule] = []

    private let feedService: FeedService

    private var bag = Set<AnyCancellable>()

    init(feedService: FeedService) {
        self.feedService = feedService
    }
}

extension SchedulePresenter: ScheduleEventHandler {
    func bind(view: ScheduleViewBehavior,
              router: ScheduleRoutable,
              schedules: [Schedule]) {
        self.view = view
        self.router = router
        self.schedules = schedules
    }

    func select(series: Series) {
        self.feedService.series(with: series.code)
            .manageActivity(self.view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] item in
                self?.router.open(series: item)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }

    func didLoad() {
        self.view.set(items: self.schedules)
    }
}
