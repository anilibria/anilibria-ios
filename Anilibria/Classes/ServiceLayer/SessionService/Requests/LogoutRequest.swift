public struct LogoutRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Unit

    let endpoint: String = "/accounts/users/auth/logout"
    let method: NetworkManager.Method = .POST
    var headers: [String : String] = [:]
}
