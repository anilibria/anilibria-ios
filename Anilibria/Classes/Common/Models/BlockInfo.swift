import Foundation

public final class BlockInfo: NSObject, Decodable {
    var isBlocked: Bool = false
    var reason: String = ""

    public init(from decoder: Decoder) throws {
        super.init()
        self.isBlocked <- decoder["blocked"]
		self.reason <- decoder["reason"]
    }
}
