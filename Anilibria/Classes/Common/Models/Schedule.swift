import Foundation

public final class Schedule: NSObject, Decodable {
    var day: WeekDay?
    var items: [Series] = []

    public init(from decoder: Decoder) throws {
        super.init()
        try decoder.apply { values in
            day <- values["day"]
            items <- values["items"]
        }
    }
}
