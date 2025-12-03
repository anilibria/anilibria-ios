public struct UserRequest: AuthorizableAPIRequest {
    typealias ResponseObject = User

    let endpoint: String = "/accounts/users/me/profile"
    let method: NetworkManager.Method = .GET
    var headers: [String : String] = [:]
}
