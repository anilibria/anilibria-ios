import UIKit

public enum LinkType: String, Codable {
    case vk
    case youtube
    case patreon
    case telegram
    case discord
    case anilibria
    case info
    case rules
    case person
    case site
    case unknown

    public var icon: UIImage? {
        switch self {
        case .vk:
            return UIImage(named: "icon_vk")
        case .youtube:
            return UIImage(named: "menu_item_youtube")
        case .patreon:
            return UIImage(named: "icon_patreon")
        case .telegram:
            return UIImage(named: "icon_telegram")
        case .discord:
            return UIImage(named: "icon_discord")
        case .site:
            return UIImage(named: "icon_web")
        default:
            return UIImage(named: "icon_anilibria")
        }
    }
}

public final class LinkData: NSObject, Codable {
    var title: String = ""
    var absoluteLink: URL?
    var sitePagePath: URL?
    var linkType: LinkType = .unknown

    var url: URL? {
        if let value = self.absoluteLink {
            return value
        }
        return self.sitePagePath
    }

//    public init(from decoder: Decoder) throws {
//        super.init()
//		self.title <- decoder["title"]
//		self.absoluteLink <- decoder["absoluteLink"] <- URLConverter(Configuration.server)
//		self.sitePagePath <- decoder["sitePagePath"] <- URLConverter(Configuration.server)
//		self.linkType <- decoder["icon"]
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        encoder.apply { values in
//            values["title"] = self.title
//            values["icon"] = self.linkType
//
//            if let link = self.absoluteLink?.absoluteString {
//                values["absoluteLink"] = link
//            }
//
//            if let link = self.sitePagePath?.absoluteString {
//                values["sitePagePath"] = link
//            }
//        }
//    }
}
