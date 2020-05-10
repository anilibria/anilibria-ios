import Foundation

public final class PageData<T: Decodable>: NSObject, Decodable {
    var items: [T] = []
    var pagination: PaginationData?

    public init(from decoder: Decoder) throws {
        super.init()
        try decoder.apply { values in
            items <- values["items"]
            pagination <- values["pagination"]
        }
    }
}

public final class PaginationData: NSObject, Decodable {
    var page: Int = 0
    var perPage: Int = 0
    var allPages: Int = 0
    var allItems: Int = 0

    public init(from decoder: Decoder) throws {
        super.init()
        try decoder.apply { values in
            page <- values["page"]
            perPage <- values["perPage"]
            allPages <- values["allPages"]
            allItems <- values["allItems"]
        }
    }
}
