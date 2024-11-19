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
        LinkData(
            linkType: .vk,
            url: URL(string: "https://vk.com/anilibria")
        ),
        LinkData(
            linkType: .telegram,
            url: URL(string: "https://t.me/anilibria")
        ),
        LinkData(
            linkType: .discord,
            url: URL(string: "https://discord.gg/M6yCGeGN9B")
        ),
        LinkData(
            linkType: .youtube,
            url: URL(string: "https://www.youtube.com/user/anilibriatv")
        ),
        LinkData(
            linkType: .patreon,
            url: URL(string: "https://www.patreon.com/anilibria")
        ),
        LinkData(
            linkType: .boosty,
            url: URL(string: "https://boosty.to/anilibriatv")
        )
    ]

    func getItems() -> [LinkData] {
        items
    }
}
