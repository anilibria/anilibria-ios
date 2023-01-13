import DITranquillity
import Foundation
import Combine

final class FeedServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(FeedServiceImp.init)
            .as(FeedService.self)
            .lifetime(.perRun(.weak))
    }
}

protocol FeedService {
    func fetchRandom() -> AnyPublisher<Series, Error>
    func fetchFiltedData() -> AnyPublisher<FilterData, Error>
    func fetchSchedule() -> AnyPublisher<[Schedule], Error>
    func fetchFeed(page: Int) -> AnyPublisher<[Feed], Error>
    func fetchNews(page: Int) -> AnyPublisher<[News], Error>
    func fetchCatalog(page: Int, filter: SeriesFilter) -> AnyPublisher<[Series], Error>
    func search(query: String) -> AnyPublisher<[Series], Error>
    func series(with code: String) -> AnyPublisher<Series, Error>
}

final class FeedServiceImp: FeedService {
    let backendRepository: BackendRepository

    private var filterData: FilterData?
    private var comments: VKComments?

    init(backendRepository: BackendRepository) {
        self.backendRepository = backendRepository
    }

    func fetchSchedule() -> AnyPublisher<[Schedule], Error> {
        return Deferred { [unowned self] in
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
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchFeed(page: Int) -> AnyPublisher<[Feed], Error> {
        return Deferred { [unowned self] in
            let request = FeedRequest(page: page)
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchNews(page: Int) -> AnyPublisher<[News], Error> {
        return Deferred { [unowned self] in
            let request = NewsRequest(page: page)
            return self.backendRepository
                .request(request)
                .map { $0.items }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchCatalog(page: Int, filter: SeriesFilter) -> AnyPublisher<[Series], Error> {
        return Deferred { [unowned self] in
            let request = CatalogRequest(filter: filter, page: page)
            return self.backendRepository
                .request(request)
                .map { $0.items }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func search(query: String) -> AnyPublisher<[Series], Error> {
        return Deferred { [unowned self] in
            let request = SearchRequest(query: query)
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchRandom() -> AnyPublisher<Series, Error> {
        return Deferred { [unowned self] in
            let request = RandomSeriesRequest()
            return self.backendRepository
                .request(request)
                .flatMap { [unowned self] in
                    self.series(with: $0.code)
                }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func series(with code: String) -> AnyPublisher<Series, Error> {
        return Deferred { [unowned self] in
            Publishers.Zip(self.fetchComments(code: code),self.fetchSeries(code: code))
                .map {
                    $1.comments = $0
                    return $1
                }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchComments(code: String) -> AnyPublisher<VKComments, Error> {
        return Deferred { [unowned self] in
            if let comments = self.comments {
                return  AnyPublisher<VKComments, Error>.just(comments.generateUrl(for: code))
            }
            let request = CommentsRequest()
            return self.backendRepository
                .request(request)
                .do(onNext: { [unowned self] item in
                    self.comments = item
                })
                .map { $0.generateUrl(for: code) }
                .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchSeries(code: String) -> AnyPublisher<Series, Error> {
        return Deferred { [unowned self] in
            let request = SeriesRequest(code: code)
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchFiltedData() -> AnyPublisher<FilterData, Error> {
        return Deferred { [unowned self] in
            if let data = self.filterData {
                return AnyPublisher<FilterData, Error>.just(data)
            }
            return Publishers.Zip(self.fetchGenres(), self.fetchYears()).map {
                let data = FilterData()
                data.genres = $0
                data.years = $1
                return data
            }.do(onNext: { [weak self] in
                self?.filterData = $0
            })
            .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchGenres() -> AnyPublisher<[String], Error> {
        return Deferred { [unowned self] in
            let request = GenresRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchYears() -> AnyPublisher<[String], Error> {
        return Deferred { [unowned self] in
            let request = YearsRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
