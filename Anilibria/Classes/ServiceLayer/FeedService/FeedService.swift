import DITranquillity
import Foundation
import RxCocoa
import RxSwift

final class FeedServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(FeedServiceImp.init)
            .as(FeedService.self)
            .lifetime(.perRun(.weak))
    }
}

protocol FeedService {
    func fetchRandom() -> Single<Series>
    func fetchFiltedData() -> Single<FilterData>
    func fetchSchedule() -> Single<[Schedule]>
    func fetchFeed(page: Int) -> Single<[Feed]>
    func fetchNews(page: Int) -> Single<[News]>
    func fetchCatalog(page: Int, filter: SeriesFilter) -> Single<[Series]>
    func search(query: String) -> Single<[Series]>
    func series(with code: String) -> Single<Series>
}

final class FeedServiceImp: FeedService {
    let schedulers: SchedulerProvider
    let backendRepository: BackendRepository

    private var filterData: FilterData?
    private var comments: VKComments?

    init(schedulers: SchedulerProvider,
         backendRepository: BackendRepository) {
        self.schedulers = schedulers
        self.backendRepository = backendRepository
    }

    func fetchSchedule() -> Single<[Schedule]> {
        return Single.deferred { [unowned self] in
            let request = ScheduleRequest()
            return self.backendRepository
                .request(request)
                .map {
                    $0.forEach({ item in
                        item.items.sort(by: { one, two -> Bool in
                            guard let first = one.lastRelease,
                                let second = two.lastRelease else {
                                return false
                            }
                            return first > second
                        })
                    })
                    return $0
                }
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func fetchFeed(page: Int) -> Single<[Feed]> {
        return Single.deferred { [unowned self] in
            let request = FeedRequest(page: page)
            return self.backendRepository
                .request(request)
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func fetchNews(page: Int) -> Single<[News]> {
        return Single.deferred { [unowned self] in
            let request = NewsRequest(page: page)
            return self.backendRepository
                .request(request)
                .map { $0.items }
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func fetchCatalog(page: Int, filter: SeriesFilter) -> Single<[Series]> {
        return Single.deferred { [unowned self] in
            let request = CatalogRequest(filter: filter, page: page)
            return self.backendRepository
                .request(request)
                .map { $0.items }
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func search(query: String) -> Single<[Series]> {
        return Single.deferred { [unowned self] in
            let request = SearchRequest(query: query)
            return self.backendRepository
                .request(request)
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func fetchRandom() -> Single<Series> {
        return Single.deferred { [unowned self] in
            let request = RandomSeriesRequest()
            return self.backendRepository
                .request(request)
                .flatMap { [unowned self] in
                    self.series(with: $0.code)
                }
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func series(with code: String) -> Single<Series> {
        return Single.deferred { [unowned self] in
            Single.zip(self.fetchComments(code: code),
                       self.fetchSeries(code: code)) {
                $1.comments = $0
                return $1
            }
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    private func fetchComments(code: String) -> Single<VKComments> {
        return Single.deferred { [unowned self] in
            if let comments = self.comments {
                return .just(comments.generateUrl(for: code))
            }
            let request = CommentsRequest()
            return self.backendRepository
                .request(request)
                .do(onSuccess: { [unowned self] item in
                    self.comments = item
                })
                .map { $0.generateUrl(for: code) }
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    private func fetchSeries(code: String) -> Single<Series> {
        return Single.deferred { [unowned self] in
            let request = SeriesRequest(code: code)
            return self.backendRepository
                .request(request)
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func fetchFiltedData() -> Single<FilterData> {
        return Single.deferred { [unowned self] in
            if let data = self.filterData {
                return .just(data)
            }
            return Single.zip(self.fetchGenres(), self.fetchYears()) {
                let data = FilterData()
                data.genres = $0
                data.years = $1
                return data
            }.do(onSuccess: { [weak self] in
                self?.filterData = $0
            })
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    private func fetchGenres() -> Single<[String]> {
        return Single.deferred { [unowned self] in
            let request = GenresRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    private func fetchYears() -> Single<[String]> {
        return Single.deferred { [unowned self] in
            let request = YearsRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }
}
