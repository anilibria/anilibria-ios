import Foundation

public struct Series: Codable, Hashable {
    let id: Int
    let type: DescribedValue<String>?
    let year: Int?
    let name: SeriesName?
    let alias: String
    let season: DescribedValue<String>?
    let poster: URL?
    let freshAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
    let isOngoing: Bool
    let ageRating: AgeRating?
    let publishDay: DescribedValue<WeekDay>?
    let desc: String
    let notification: String
    let episodesTotal: Int?
    let isInProduction: Bool
    let isBlockedByGeo: Bool
    let episodesAreUnknown: Bool
    let isBlockedByCopyrights: Bool
    let addedInUsersFavorites: Int
    let averageDurationOfEpisode: Int?
    let genres: [Genre]
    let members: [Member]
    let playlist: [PlaylistItem]
    let torrents: [Torrent]
    let sponsor: Sponsor?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        let urlConverter = URLConverter(Configuration.imageServer)
        let dateConverter = DateConverter()
        id = try container.decode(required: "id")
        type = container.decode("type")
        year = container.decode("year")
        name = container.decode("name")
        alias = container.decode("alias") ?? ""
        season = container.decode("season")
        poster = urlConverter.convert(from: container.decode("poster", "src"))

        freshAt = dateConverter.convert(from: container.decode("fresh_at"))
        createdAt = dateConverter.convert(from: container.decode("created_at"))
        updatedAt = dateConverter.convert(from:container.decode("updated_at"))

        isOngoing = container.decode("is_ongoing") ?? false
        ageRating = container.decode("age_rating")
        publishDay = container.decode("publish_day")
        desc = container.decode("description") ?? ""
        notification = container.decode("notification") ?? ""
        episodesTotal = container.decode("episodes_total")
        isInProduction = container.decode("is_in_production") ?? false
        isBlockedByGeo = container.decode("is_blocked_by_geo") ?? false
        episodesAreUnknown = container.decode("episodes_are_unknown") ?? false
        isBlockedByCopyrights = container.decode("is_blocked_by_copyrights") ?? false
        addedInUsersFavorites = container.decode("added_in_users_favorites") ?? 0
        averageDurationOfEpisode = container.decode("average_duration_of_episode")
        genres = container.decode("genres") ?? []
        members = container.decode("members") ?? []
        playlist = container.decode("episodes") ?? []
        torrents = container.decode("torrents") ?? []
        sponsor = container.decode("sponsor")
    }

    public func encode(to encoder: Encoder) throws {
        encoder.apply(CodingKeyString.self) { container in
            container["id"] = id
            container["type"] = type
            container["year"] = year
            container["name"] = name
            container["alias"] = alias
            container["season"] = season
            container["poster"]["src"] = poster?.absoluteString
            container["fresh_at"] = freshAt
            container["created_at"] = createdAt
            container["updated_at"] = updatedAt
            container["is_ongoing"] = isOngoing
            container["age_rating"] = ageRating
            container["publish_day"] = publishDay
            container["description"] = desc
            container["notification"] = notification
            container["episodes_total"] = episodesTotal
            container["is_in_production"] = isInProduction
            container["is_blocked_by_geo"] = isBlockedByGeo
            container["episodes_are_unknown"] = episodesAreUnknown
            container["is_blocked_by_copyrights"] = isBlockedByCopyrights
            container["added_in_users_favorites"] = addedInUsersFavorites
            container["average_duration_of_episode"] = averageDurationOfEpisode
        }
    }
}

struct SeriesName: Codable, Hashable {
    let main: String
    let english: String
    let alternative: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        main = container.decode("main") ?? ""
        english = container.decode("english") ?? ""
        alternative = container.decode("alternative") ?? ""
    }
}

struct DescribedValue<Value: Codable & Hashable>: Codable, Hashable {
    let value: Value
    let description: String
}

struct AgeRating: Codable, Hashable {
    let value: String
    let label: String
    let isAdult: Bool?
    let description: String

    enum CodingKeys: String, CodingKey {
        case value
        case label
        case isAdult = "is_adult"
        case description
    }
}

struct Genre: Decodable, Hashable {
    let id: Int
    let name: String
    let totalReleases: Int?
    let imageURL: URL?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        let urlConverter = URLConverter(Configuration.imageServer)
        id = try container.decode(required: "id")
        name = container.decode("name") ?? ""
        totalReleases = container.decode("total_releases")
        imageURL = urlConverter.convert(from: container.decode("image", "preview"))
    }
}

struct Member: Decodable, Hashable {
    let id: String
    let name: String
    let role: DescribedValue<String>?
    let user: User?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        id = try container.decode(required: "id")
        name = container.decode("nickname") ?? ""
        role = container.decode("role")
        user = container.decode("user")
    }
}

struct Sponsor: Decodable, Hashable {
    let id: String
    let title: String
    let description: String?
    let urlTitle: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case urlTitle = "url_title"
        case url
    }
}
