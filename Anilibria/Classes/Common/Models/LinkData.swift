import UIKit

public enum LinkType: String, Codable {
    case vk
    case youtube
    case patreon
    case telegram
    case discord
    case boosty
    case anilibria
    case info
    case rules
    case person
    case site
    case unknown

    public var icon: UIImage? {
        switch self {
        case .vk:
            return UIImage(resource: .iconVk)
        case .youtube:
            return UIImage(resource: .menuItemYoutube)
        case .patreon:
            return UIImage(resource: .iconPatreon)
        case .telegram:
            return UIImage(resource: .iconTelegram)
        case .discord:
            return UIImage(resource: .iconDiscord)
        case .site:
            return UIImage(resource: .iconWeb)
        case .boosty:
            return UIImage(resource: .iconBoosty)
        default:
            return UIImage(resource: .iconAnilibria)
        }
    }
}

public struct LinkData: Codable {
    let linkType: LinkType
    let url: URL?
}
