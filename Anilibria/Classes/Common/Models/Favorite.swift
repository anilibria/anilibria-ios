import Foundation

public final class Favorite: NSObject, Decodable {
    var rating: Int = 0
    var added: Bool = false

    public init(from decoder: Decoder) throws {
        super.init()
        try decoder.apply { values in
            rating <- values["rating"]
            added <- values["added"]
        }
    }
}
