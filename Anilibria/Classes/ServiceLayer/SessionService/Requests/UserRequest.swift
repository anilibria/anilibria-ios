public struct UserRequest: AuthorizableAPIRequest {
    typealias ResponseObject = User

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/me/profile"
    )
}
