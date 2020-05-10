import Foundation

public enum OAuthSocial: String, Decodable {
    case vk
}

public struct SocialOAuthData: Decodable {
    private(set) var key: OAuthSocial?
    private(set) var title: String = ""
    private(set) var socialUrl: URL?
    private(set) var resultPattern: String = ""
    private(set) var errorUrlPattern: String = ""

    public init(from decoder: Decoder) throws {
        try decoder.apply { values in
            key <- values["key"]
            title <- values["title"]
            socialUrl <- values["socialUrl"] <- URLConverter("")
            resultPattern <- values["resultPattern"]
            errorUrlPattern <- values["errorUrlPattern"]
        }
    }
}
