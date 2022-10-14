import DITranquillity
import RxSwift

final class FavoriteServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(FavoriteServiceImp.init)
            .as(FavoriteService.self)
            .lifetime(.single)
    }
}

protocol FavoriteService: AnyObject {
    func fetchSeries() -> Single<[Series]>
    func favorite(add: Bool, series: Series) -> Single<Unit>
}

final class FavoriteServiceImp: FavoriteService {
    let schedulers: SchedulerProvider
    let backendRepository: BackendRepository

    private var bag: DisposeBag = DisposeBag()

    init(schedulers: SchedulerProvider,
         backendRepository: BackendRepository) {
        self.schedulers = schedulers
        self.backendRepository = backendRepository
    }

    func fetchSeries() -> Single<[Series]> {
        return Single.deferred { [unowned self] in
            let request = FavoriteListRequest()
            return self.backendRepository
                .request(request)
                .map { $0.items }
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func favorite(add: Bool, series: Series) -> Single<Unit> {
        if add {
            return self.add(series: series)
        }
        return self.remove(series: series)
    }

    func add(series: Series) -> Single<Unit> {
        return Single.deferred { [unowned self] in
            let request = AddFavoriteRequest(id: series.id)
            return self.backendRepository
                .request(request)
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func remove(series: Series) -> Single<Unit> {
        return Single.deferred { [unowned self] in
            let request = RemoveFavoriteRequest(id: series.id)
            return self.backendRepository
                .request(request)
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }
}
