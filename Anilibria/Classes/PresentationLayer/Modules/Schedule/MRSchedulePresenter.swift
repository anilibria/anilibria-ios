import DITranquillity
import RxSwift
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

    private var bag: DisposeBag = DisposeBag()

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
            .subscribe(onSuccess: { [weak self] item in
                self?.router.open(series: item)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .disposed(by: self.bag)
    }

    func didLoad() {
        let items = self.schedules.reduce([NSObject]()) { (result, item) -> [NSObject] in
            if item.items.isEmpty {
                return result
            }
            let title = TitleItem(item.day?.name ?? "")

            return result + [title] + item.items
        }

        self.view.set(items: items)
    }
}
