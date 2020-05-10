import DITranquillity
import RxSwift
import UIKit

final class SeriesContainerPart: DIPart {
    static func load(container: DIContainer) {
        container.register(SeriesContainerPresenter.init)
            .as(SeriesContainerEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class SeriesContainerPresenter {
    private weak var view: SeriesContainerViewBehavior!
    private var router: SeriesContainerRoutable!
    private var series: Series!

    private let feedService: FeedService
    private let sessionService: SessionService

    private let bag: DisposeBag = DisposeBag()
    private var shareBag: DisposeBag!

    init(feedService: FeedService,
         sessionService: SessionService) {
        self.feedService = feedService
        self.sessionService = sessionService
    }

    private func loadSchedules() {
        self.feedService.fetchSchedule()
            .manageActivity(self.view.showLoading(fullscreen: false))
            .subscribe(onSuccess: { [weak self] items in
                self?.router.open(schedules: items)
            }, onError: { [weak self] error in
                self?.router.show(error: error)
            })
            .disposed(by: self.bag)
    }
}

extension SeriesContainerPresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if let command = command as? FilterRouteCommand {
            self.router.openCatalog(filter: command.value)
            return true
        }

        if let command = command as? SeriesCommand {
            self.router.open(series: command.value)
            return true
        }

        if let command = command as? UrlCommand {
            self.router.open(url: command.url)
            return true
        }

        if command is ScheduleCommand {
            self.loadSchedules()
            return true
        }

        return false
    }
}

extension SeriesContainerPresenter: SeriesContainerEventHandler {
    func bind(view: SeriesContainerViewBehavior,
              router: SeriesContainerRoutable,
              series: Series) {
        self.view = view
        self.router = router
        self.series = series
        self.router.responder = self
    }

    func share(sourceView: UIView?) {
        self.shareBag = DisposeBag()
        if let url = URLHelper.releaseUrl(self.series) {
            self.router.openShare(items: [url])
        }
    }

    func createDescription() -> String {
        let strings = L10n.Screen.Series.self
        var result: String = "\(self.series.names.joined(separator: " / "))\n\n"

        if self.series.year.isEmpty == false {
            result += "\(strings.year) \(self.series.year)\n"
        }

        if self.series.voices.isEmpty == false {
            result += "\(strings.voices) \(self.series.voices.joined(separator: ", "))\n"
        }

        if self.series.type.isEmpty == false {
            result += "\(strings.type) \(self.series.type)\n"
        }

        if self.series.status.isEmpty == false {
            result += "\(strings.status) \(self.series.status)\n"
        }

        if self.series.genres.isEmpty == false {
            result += "\(strings.genres) \(self.series.genres.joined(separator: ", "))\n"
        }

        return result.trim()
    }
}
