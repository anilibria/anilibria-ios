public struct LoginRequest: BackendAPIRequest {
    typealias ResponseObject = LoginResponse

    let endpoint: String
    let method: NetworkManager.Method
    let body: (any Encodable)?
    let parameters: [String : Any]

    init(login: String, password: String) {
        self.endpoint = "/accounts/users/auth/login"
        self.method = .POST
        self.parameters = [:]
        self.body = LoginBody(login: login, password: password)
    }

    init(provider: AuthProviderData) {
        self.endpoint = "/accounts/users/auth/social/authenticate"
        self.method = .GET
        self.parameters = ["state": provider.state]
        self.body = nil
    }
}

private struct LoginBody: Encodable {
    let login: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
}
