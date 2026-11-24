import Foundation

public enum AuthProvider: String, CaseIterable {
    case vk
    case google
    case patreon
    case discord
}

public struct AuthProviderData: Decodable {
    let url: URL
    let state: String
}
