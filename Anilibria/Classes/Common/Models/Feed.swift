import Foundation

public final class Feed: NSObject, Decodable {
    var series: Series?
    var news: News?

    var value: (any Hashable)? {
        if self.series != nil {
            return self.series
        }
        return self.news
    }
}
