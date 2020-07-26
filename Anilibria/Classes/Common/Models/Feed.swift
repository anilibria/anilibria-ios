import Foundation

public final class Feed: NSObject, Decodable {
    var series: Series?
    var news: News?

    public init(from decoder: Decoder) throws {
        super.init()
		self.series <- decoder["release"]
		self.news <- decoder["youtube"]
    }

    var value: NSObject? {
        if self.series != nil {
            return self.series
        }
        return self.news
    }
}
