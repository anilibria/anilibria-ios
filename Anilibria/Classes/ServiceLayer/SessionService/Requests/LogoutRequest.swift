public struct LogoutRequest: BackendAPIRequest {
    typealias ResponseObject = Unit

    private(set) var endpoint: String = "/accounts/users/auth/logout"
    private(set) var method: NetworkManager.Method = .POST
}
