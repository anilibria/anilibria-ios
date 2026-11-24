import DITranquillity
import Foundation
import Combine

final class MainServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(MainServiceImp.init)
            .as(MainService.self)
            .lifetime(.perRun(.weak))
    }
}

protocol MainService {
    func fetchRandom() -> AnyPublisher<Series?, Error>
    func fetchTodaySchedule() -> AnyPublisher<ShortSchedule, Error>
    func fetchSchedule() -> AnyPublisher<[Schedule], Error>
    func fetchNews(limit: Int) -> AnyPublisher<[News], Error>
    func search(query: String) -> AnyPublisher<[Series], Error>
    func series(with id: Int) -> AnyPublisher<Series, Error>
    func fetchPromo() -> AnyPublisher<[PromoItem], Error>
    func fetchFranchise(for seriesID: Int) -> AnyPublisher<[Franchise], Error>
    func fetchTeamMembers() -> AnyPublisher<[TeamMember], Error>
}

final class MainServiceImp: MainService {
    let backendRepository: BackendRepository
    private var randomSeries: ArraySlice<Series>?

    init(backendRepository: BackendRepository) {
        self.backendRepository = backendRepository
    }

    func fetchSchedule() -> AnyPublisher<[Schedule], Error> {
        return Deferred { [unowned self] in
            let request = ScheduleWeekRequest()
            return self.backendRepository
                .request(request)
        }
        .map { items in
            Dictionary(grouping: items, by: { $0.item.publishDay?.value })
                .sorted(by: { first, second in
                    switch (first.key, second.key) {
                    case (_, nil):
                        return true
                    case (nil, _):
                        return false
                    case (let firstKey?, let secondKey?):
                        return firstKey.rawValue < secondKey.rawValue
                    }
                }).map {
                    Schedule(day: $0, items: $1)
                }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchTodaySchedule() -> AnyPublisher<ShortSchedule, any Error> {
        return Deferred { [unowned self] in
            let request = ScheduleNowRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchNews(limit: Int) -> AnyPublisher<[News], Error> {
        return Deferred { [unowned self] in
            let request = NewsRequest(limit: limit)
            return self.backendRepository
                .request(request)
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

    func fetchRandom() -> AnyPublisher<Series?, Error> {
        if let series = randomSeries?.popFirst() {
            return .just(series)
        }
        return Deferred { [unowned self] in
            let request = RandomSeriesRequest(limit: 20)
            return self.backendRepository
                .request(request)
                .map {
                    self.randomSeries = ArraySlice($0)
                    return self.randomSeries?.popFirst()
                }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchPromo() -> AnyPublisher<[PromoItem], any Error> {
        return Deferred { [unowned self] in
            let request = PromoRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func series(with id: Int) -> AnyPublisher<Series, Error> {
        return Deferred { [unowned self] in
            let request = SeriesRequest(id: id)
            return self.backendRepository
                .request(request)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchFranchise(for seriesID: Int) -> AnyPublisher<[Franchise], Error> {
        return Deferred { [unowned self] in
            let request = FranchiseRequest(seriesID: seriesID)
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchTeamMembers() -> AnyPublisher<[TeamMember], Error> {
        return Deferred { [unowned self] in
            let request = TeamMembersRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
