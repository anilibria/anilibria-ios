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

    private let mainService: MainService

    private var bag = Set<AnyCancellable>()

    init(mainService: MainService) {
        self.mainService = mainService
    }
}

extension SchedulePresenter: ScheduleEventHandler {
    func bind(view: ScheduleViewBehavior,
              router: ScheduleRoutable) {
        self.view = view
        self.router = router
    }

    func select(series: Series) {
        router.open(series: series)
    }

    func didLoad() {
        self.mainService.fetchSchedule()
            .manageActivity(view.showLoading(fullscreen: false))
            .sink(onNext: { [weak self] schedules in
                self?.view.set(items: schedules)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .store(in: &bag)
    }
}
