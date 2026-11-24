import DITranquillity
import Combine
import Foundation

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
    private let linksRepository: LinksRepository

    private var bag = Set<AnyCancellable>()

    init(linksRepository: LinksRepository) {
        self.linksRepository = linksRepository
    }

    func fetchLinks() -> AnyPublisher<[LinkData], Error> {
        return Deferred { [unowned self] in
            let items = self.linksRepository.getItems()

            return AnyPublisher<[LinkData], Error>.just(items)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
