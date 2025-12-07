public struct LogoutRequest: AuthorizableAPIRequest {
    typealias ResponseObject = Unit

    var requestData: RequestData = .init(
        endpoint: "/accounts/users/auth/logout",
        method: .POST
    )
}
