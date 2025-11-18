public struct LinksRequest: AuthorizableAPIRequest {
    typealias ResponseObject = [LinkData]

    let endpoint: String = "/public/api/index.php"
    let method: NetworkManager.Method = .POST
    let parameters: [String: Any]
    var headers: [String : String] = [:]

    init() {
        self.parameters = [
            "query": "link_menu"
        ]
    }
}
