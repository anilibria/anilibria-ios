import Foundation

public struct VKComments: Decodable {
    private var serverUrl: URL?
    private(set) var script: String = ""
    private(set) var baseUrl: URL?

    public init(from decoder: Decoder) throws {
		self.serverUrl <- decoder["baseUrl"] <- URLConverter(Configuration.widgetServer)
		self.script <- decoder["script"]
    }

    func generateUrl(for seriesCode: String) -> VKComments {
        var copy = self
        copy.baseUrl = self.serverUrl?
            .appendingPathComponent("release")
            .appendingPathComponent("\(seriesCode).html")
        return copy
    }
}
