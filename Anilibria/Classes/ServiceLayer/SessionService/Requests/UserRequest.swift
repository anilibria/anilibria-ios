public struct UserRequest: BackendAPIRequest {
    typealias ResponseObject = User

    let endpoint: String = "/accounts/users/me/profile"
    let method: NetworkManager.Method = .GET
}
