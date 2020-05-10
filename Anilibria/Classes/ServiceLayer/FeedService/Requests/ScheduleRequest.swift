public struct ScheduleRequest: BackendAPIRequest {
    typealias ResponseObject = [Schedule]

    private(set) var endpoint: String = "/public/api/index.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init() {
        self.parameters = [
            "query": "schedule",
            "filter": "id,code,poster,names,last,series"
        ]
    }
}
