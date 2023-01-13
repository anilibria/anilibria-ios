import Foundation

public final class Schedule: NSObject, Decodable {
    var day: WeekDay?
    var items: [Series] = []
    var title: TitleItem {
        TitleItem(day?.name ?? "")
    }

    public init(from decoder: Decoder) throws {
        super.init()
		self.day <- decoder["day"]
		self.items <- decoder["items"]
    }
}
