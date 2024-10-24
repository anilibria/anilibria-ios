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

//    public init(from decoder: Decoder) throws {
//		self.key <- decoder["key"]
//		self.title <- decoder["title"]
//		self.socialUrl <- decoder["socialUrl"] <- URLConverter("")
//		self.resultPattern <- decoder["resultPattern"]
//		self.errorUrlPattern <- decoder["errorUrlPattern"]
//    }
}
