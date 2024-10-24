public struct LoginRequest: BackendAPIRequest {
    typealias ResponseObject = ServerResponse

    private(set) var endpoint: String = "/public/login.php"
    private(set) var method: NetworkManager.Method = .POST
    private(set) var parameters: [String: Any]

    init(login: String, password: String, code: String) {
        self.parameters = [
            "mail": login,
            "passwd": password,
            "fa2code": code
        ]
    }
}
