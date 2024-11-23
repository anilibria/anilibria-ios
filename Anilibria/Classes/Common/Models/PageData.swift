import Foundation

public struct PageData<T: Decodable>: Decodable {
    let items: [T]
    let pagination: PaginationData?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        self.items = container.decode("data") ?? []
        self.pagination = container.decode("meta", "pagination")
    }
}

public struct PaginationData: Decodable {
    let page: Int

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        self.page = container.decode("current_page") ?? 0
    }
}
