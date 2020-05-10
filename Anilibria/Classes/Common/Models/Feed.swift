import Foundation

public final class Feed: NSObject, Decodable {
    var series: Series?
    var news: News?

    public init(from decoder: Decoder) throws {
        super.init()
        try decoder.apply { values in
            series <- values["release"]
            news <- values["youtube"]
        }
    }

    var value: NSObject? {
        if self.series != nil {
            return self.series
        }
        return self.news
    }
}
