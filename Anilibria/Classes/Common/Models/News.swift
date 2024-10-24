import Foundation

public final class News: NSObject, Decodable {
    var id: Int = 0
    var title: String = ""
    var image: URL?
    var vidUrl: URL?
    var views: Int = 0
    var comments: Int = 0
    var date: Date?
}
