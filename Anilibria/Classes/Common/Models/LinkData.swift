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
            return .iconVk
        case .youtube:
            return .iconYoutube
        case .patreon:
            return .iconPatreon
        case .telegram:
            return .iconTelegram
        case .discord:
            return .iconDiscord
        case .site:
            return .System.web
        case .boosty:
            return .iconBoosty
        default:
            return .iconAnilibria
        }
    }
}

public struct LinkData: Codable {
    let linkType: LinkType
    let url: URL?
}
