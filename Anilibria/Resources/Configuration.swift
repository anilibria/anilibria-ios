import UIKit

public struct Configuration {
    static var server = "https://api.anilibria.app"
    static var imageServer = "https://api.anilibria.app"

    static func apply(_ settings: AniSettings) {
        self.server = settings.server
        self.imageServer = settings.images
    }
}
