import UIKit

public struct Configuration {
    static var server = "https://www.anilibria.top"
    static var imageServer = "https://anilibria.top"

    static func apply(_ settings: AniSettings) {
        self.server = settings.server
        self.imageServer = settings.images
    }
}
