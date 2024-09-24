import UIKit

public struct Configuration {
    static var server = "https://www.anilibria.tv"
    static var imageServer = "https://www.anilibria.tv"

    static func apply(_ settings: AniSettings) {
        self.server = settings.server
        self.imageServer = settings.images
    }
}
