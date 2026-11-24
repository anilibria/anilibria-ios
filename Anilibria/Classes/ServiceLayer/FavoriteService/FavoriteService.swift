import DITranquillity
import Combine
import Foundation

final class FavoriteServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(FavoriteServiceImp.init)
            .as(FavoriteService.self)
            .lifetime(.single)
    }
}

enum FavoriteUpdates {
    case added(Series)
    case deleted(Series)
}

protocol FavoriteService: AnyObject {
    func favoritesUpdates() -> AnyPublisher<FavoriteUpdates, Never>
    func fetchSeries(limit: Int, page: Int, data: SeriesSearchData) -> AnyPublisher<[Series], Error>
    func favorite(add: Bool, series: Series) -> AnyPublisher<Void, Error>
    func getFavoriteState(for seriesID: Int) -> AnyPublisher<Bool, Error>
    func fetchFilterData() -> AnyPublisher<FilterData, Error>
}

final class FavoriteServiceImp: FavoriteService {
    let backendRepository: BackendRepository
    private var favoriteIDsTime: Date?
    private var favoriteIDs: Set<Int> = []
    private let updates = PassthroughSubject<FavoriteUpdates, Never>()

    private var bag = Set<AnyCancellable>()

    init(backendRepository: BackendRepository) {
        self.backendRepository = backendRepository
    }

    func favoritesUpdates() -> AnyPublisher<FavoriteUpdates, Never> {
        updates
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func getFavoriteState(for seriesID: Int) -> AnyPublisher<Bool, Error> {
        if let favoriteIDsTime, Date().distance(to: favoriteIDsTime) > 60 * 60  {
            return .just(favoriteIDs.contains(seriesID))
        }

        return Deferred { [unowned self] in
            let request = FavoriteIDsRequest()
            return self.backendRepository
                .request(request)
        }
        .receive(on: DispatchQueue.main)
        .map { [unowned self] in
            self.favoriteIDs = Set($0)
            self.favoriteIDsTime = Date()
            return favoriteIDs.contains(seriesID)
        }
        .eraseToAnyPublisher()
    }

    func fetchSeries(limit: Int, page: Int, data: SeriesSearchData) -> AnyPublisher<[Series], Error> {
        return Deferred { [unowned self] in
            let request = FavoriteListRequest(data: data, page: page, limit: limit)
            return self.backendRepository
                .request(request)
                .map { $0.items }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func favorite(add: Bool, series: Series) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            let request = ChangeFavoriteRequest(add: add, id: series.id)
            return self.backendRepository
                .request(request)
                .map { _ in
                    if add {
                        self.favoriteIDs.insert(series.id)
                        self.updates.send(.added(series))
                    } else {
                        self.favoriteIDs.remove(series.id)
                        self.updates.send(.deleted(series))
                    }
                }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchFilterData() -> AnyPublisher<FilterData, Error> {
        return Deferred { [unowned self] in
            return self.fetchAgeRatings()
                .zip(self.fetchGenres(), { ages, genres in
                    var data = FilterData()
                    data.ageRatings = ages
                    data.genres = genres
                    return data
                })
                .zip(self.fetchSortings(), { data, value in
                    var result = data
                    result.sortings = value
                    return result
                })
                .zip(self.fetchReleaseTypes(), { data, value in
                    var result = data
                    result.releaseTypes = value
                    return result
                })
                .zip(self.fetchYears(), { data, value in
                    var result = data
                    result.years = value
                    return result
                })
                .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchAgeRatings() -> AnyPublisher<[AgeRating], Error> {
        return Deferred { [unowned self] in
            let request = FavoriteFilterAgeRatingsRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchReleaseTypes() -> AnyPublisher<[DescribedValue<String>], Error> {
        return Deferred { [unowned self] in
            let request = FavoriteFilterReleaseTypesRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchSortings() -> AnyPublisher<[Sorting], Error> {
        return Deferred { [unowned self] in
            let request = FavoriteFilterSortingRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchGenres() -> AnyPublisher<[Genre], Error> {
        return Deferred { [unowned self] in
            let request = FavoriteFilterGenresRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchYears() -> AnyPublisher<[Int], Error> {
        return Deferred { [unowned self] in
            let request = FavoriteFilterYearsRequest()
            return self.backendRepository
                .request(request)
                .map { $0.sorted(by: <) }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
