import DITranquillity
import RxSwift

final class LinksServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(LinksServiceImp.init)
            .as(LinksService.self)
            .lifetime(.single)
    }
}

protocol LinksService: AnyObject {
    func fetchLinks() -> Single<[LinkData]>
}

final class LinksServiceImp: LinksService {
    private let schedulers: SchedulerProvider
    private let backendRepository: BackendRepository
    private let linksRepository: LinksRepository

    private var bag: DisposeBag = DisposeBag()

    init(schedulers: SchedulerProvider,
         backendRepository: BackendRepository,
         linksRepository: LinksRepository) {
        self.schedulers = schedulers
        self.backendRepository = backendRepository
        self.linksRepository = linksRepository
    }

    func fetchLinks() -> Single<[LinkData]> {
        return Single.deferred { [unowned self] in
            let items = self.linksRepository.getItems()

            if !items.isEmpty {
                return Single.just(items)
            }

            let request = LinksRequest()
            return self.backendRepository
                .request(request)
                .do(onSuccess: { [weak self] (items) in
                    self?.linksRepository.set(items: items)
                })
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }
}
