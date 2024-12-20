public struct UserRequest: BackendAPIRequest {
    typealias ResponseObject = User

    private(set) var endpoint: String = "/accounts/users/me/profile"
    private(set) var method: NetworkManager.Method = .GET
}
