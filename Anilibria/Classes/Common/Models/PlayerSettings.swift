import Foundation

public struct PlayerSettings: Codable {
    var quality: VideoQuality = .fullHd
    var skipMode: SkipCreditsMode = .automatic
    var autoPlay: Bool = true
    var playbackRate: Double = 1.0
    var playOnStartup: Bool = false

    init() {}

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.quality = container.decode(.quality) ?? .fullHd
        self.skipMode = container.decode(.skipMode) ?? .automatic
        self.autoPlay = container.decode(.autoPlay) ?? true
        self.playbackRate = container.decode(.playbackRate) ?? 1.0
        self.playOnStartup = container.decode(.playOnStartup) ?? false
    }

    static var playbackRateOptions: [Double] {
        [0.25, 0.5, 1.0, 1.5, 2.0]
    }

    static func nameFor(rate: Double) -> String {
        "\(rate)x"
    }

    static func nameFor(bool value: Bool) -> String {
        value ? L10n.Common.enabled : L10n.Common.disabled
    }
}

public enum SkipCreditsMode: Codable, CaseIterable {
    case automatic
    case manual
    case disabled

    var name: String {
        switch self {
        case .disabled:
            return L10n.Common.disabled
        case .manual:
            return L10n.Common.manual
        case .automatic:
            return L10n.Common.auto
        }
    }
}
