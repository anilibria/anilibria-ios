import DITranquillity
import Combine

final class LinksServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(LinksServiceImp.init)
            .as(LinksService.self)
            .lifetime(.single)
    }
}

protocol LinksService: AnyObject {
    func fetchLinks() -> AnyPublisher<[LinkData], Error>
}

final class LinksServiceImp: LinksService {
    private let backendRepository: BackendRepository
    private let linksRepository: LinksRepository

    private var bag = Set<AnyCancellable>()

    init(backendRepository: BackendRepository,
         linksRepository: LinksRepository) {
        self.backendRepository = backendRepository
        self.linksRepository = linksRepository
    }

    func fetchLinks() -> AnyPublisher<[LinkData], Error> {
        return Deferred { [unowned self] in
            let items = self.linksRepository.getItems()

            if !items.isEmpty {
                return AnyPublisher<[LinkData], Error>.just(items)
            }

            let request = LinksRequest()
            return self.backendRepository
                .request(request)
                .do(onNext: { [weak self] (items) in
                    self?.linksRepository.set(items: items)
                })
                .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
