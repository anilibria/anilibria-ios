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
    func fetchSchedule() -> AnyPublisher<[Schedule], Error>
    func fetchFeed(page: Int) -> AnyPublisher<[Feed], Error>
    func fetchNews(page: Int) -> AnyPublisher<[News], Error>
    func fetchCatalog(page: Int, filter: SeriesFilter) -> AnyPublisher<[Series], Error>
    func search(query: String) -> AnyPublisher<[Series], Error>
    func series(with code: String) -> AnyPublisher<Series, Error>
}

final class FeedServiceImp: FeedService {
    let backendRepository: BackendRepository

    init(backendRepository: BackendRepository) {
        self.backendRepository = backendRepository
    }

    func fetchSchedule() -> AnyPublisher<[Schedule], Error> {
        return .just([])
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
                    self.series(with: $0.alias)
                }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func series(with code: String) -> AnyPublisher<Series, Error> {
        return Deferred { [unowned self] in
            let request = SeriesRequest(alias: code)
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
