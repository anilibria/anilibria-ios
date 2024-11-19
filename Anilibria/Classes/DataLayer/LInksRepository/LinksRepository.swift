import DITranquillity
import Foundation

final class LinksRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(LinksRepositoryImp.init)
            .as(LinksRepository.self)
            .lifetime(.single)
    }
}

protocol LinksRepository {
    func getItems() -> [LinkData]
}

final class LinksRepositoryImp: LinksRepository {
    let items: [LinkData] = [
        LinkData(linkType: .vk, url: URLS.vk),
        LinkData(linkType: .telegram, url: URLS.telegram),
        LinkData(linkType: .discord, url: URLS.discord),
        LinkData(linkType: .youtube, url: URLS.youtube),
        LinkData(linkType: .patreon, url: URLS.patreon),
        LinkData(linkType: .boosty, url: URLS.boosty)
    ]

    func getItems() -> [LinkData] {
        items
    }
}
