public struct LogoutRequest: BackendAPIRequest {
    typealias ResponseObject = Unit

    let endpoint: String = "/accounts/users/auth/logout"
    let method: NetworkManager.Method = .POST
}
