import Foundation

public final class BlockInfo: NSObject, Decodable {
    var isBlocked: Bool = false
    var reason: String = ""

    public init(from decoder: Decoder) throws {
        super.init()
        try decoder.apply { values in
            isBlocked <- values["blocked"]
            reason <- values["reason"]
        }
    }
}
