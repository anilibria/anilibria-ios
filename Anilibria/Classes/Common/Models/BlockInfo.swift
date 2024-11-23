import Foundation

public final class BlockInfo: NSObject, Decodable {
    var isBlocked: Bool = false
    var reason: String = ""
}
