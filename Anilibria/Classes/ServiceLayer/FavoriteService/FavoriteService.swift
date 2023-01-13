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

protocol FavoriteService: AnyObject {
    func fetchSeries() -> AnyPublisher<[Series], Error>
    func favorite(add: Bool, series: Series) -> AnyPublisher<Unit, Error>
}

final class FavoriteServiceImp: FavoriteService {
    let backendRepository: BackendRepository

    private var bag = Set<AnyCancellable>()

    init(backendRepository: BackendRepository) {
        self.backendRepository = backendRepository
    }

    func fetchSeries() -> AnyPublisher<[Series], Error> {
        return Deferred { [unowned self] in
            let request = FavoriteListRequest()
            return self.backendRepository
                .request(request)
                .map { $0.items }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func favorite(add: Bool, series: Series) -> AnyPublisher<Unit, Error> {
        if add {
            return self.add(series: series)
        }
        return self.remove(series: series)
    }

    func add(series: Series) -> AnyPublisher<Unit, Error> {
        return Deferred { [unowned self] in
            let request = AddFavoriteRequest(id: series.id)
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func remove(series: Series) -> AnyPublisher<Unit, Error> {
        return Deferred { [unowned self] in
            let request = RemoveFavoriteRequest(id: series.id)
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
