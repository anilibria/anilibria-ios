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
    let desc: NSAttributedString?
    let notification: String
    let episodesTotal: Int?
    let isInProduction: Bool
    let isBlockedByGeo: Bool
    let episodesAreUnknown: Bool
    let isBlockedByCopyrights: Bool
    let addedIn: [UserCollectionKey: Int]
    let averageDurationOfEpisode: Int?
    let genres: [Genre]
    let members: [Member]
    let playlist: [PlaylistItem]
    let torrents: [Torrent]
    let sponsor: Sponsor?

    var isBlocked: Bool {
        isBlockedByGeo || isBlockedByCopyrights
    }

    private let originalDesc: String

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case year
        case name
        case alias
        case season
        case notification

        case poster
        case src

        case freshAt = "fresh_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"

        case isOngoing = "is_ongoing"
        case ageRating = "age_rating"
        case publishDay = "publish_day"
        case originalDesc = "description"
        case episodesTotal = "episodes_total"
        case isInProduction = "is_in_production"
        case isBlockedByGeo = "is_blocked_by_geo"
        case episodesAreUnknown = "episodes_are_unknown"
        case isBlockedByCopyrights = "is_blocked_by_copyrights"
        case averageDurationOfEpisode = "average_duration_of_episode"

        case favorite = "added_in_users_favorites"
        case planned = "added_in_planned_collection"
        case watched = "added_in_watched_collection"
        case watching = "added_in_watching_collection"
        case postponed = "added_in_postponed_collection"
        case abandoned = "added_in_abandoned_collection"

        case genres
        case members
        case playlist = "episodes"
        case torrents
        case sponsor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urlConverter = URLConverter()
        let dateConverter = DateConverter()
        let atributedContverter = AttributedConverter(css: Css.text())
        id = try container.decode(required: .id)
        type = container.decode(.type)
        year = container.decode(.year)
        name = container.decode(.name)
        alias = container.decode(.alias) ?? ""
        season = container.decode(.season)
        poster = urlConverter.convert(from: container.decode(.poster, .src))

        freshAt = dateConverter.convert(from: container.decode(.freshAt))
        createdAt = dateConverter.convert(from: container.decode(.createdAt))
        updatedAt = dateConverter.convert(from:container.decode(.updatedAt))

        isOngoing = container.decode(.isOngoing) ?? false
        ageRating = container.decode(.ageRating)
        publishDay = container.decode(.publishDay)
        originalDesc = container.decode(.originalDesc) ?? ""
        desc = atributedContverter.convert(from: originalDesc)
        notification = container.decode(.notification) ?? ""
        episodesTotal = container.decode(.episodesTotal)
        isInProduction = container.decode(.isInProduction) ?? false
        isBlockedByGeo = container.decode(.isBlockedByGeo) ?? false
        episodesAreUnknown = container.decode(.episodesAreUnknown) ?? true
        isBlockedByCopyrights = container.decode(.isBlockedByCopyrights) ?? false
        averageDurationOfEpisode = container.decode(.averageDurationOfEpisode)
        genres = (container.decode(.genres) ?? []).sorted(by: { $0.name < $1.name })
        members = container.decode(.members) ?? []
        playlist = container.decode(.playlist) ?? []
        torrents = container.decode(.torrents) ?? []
        sponsor = container.decode(.sponsor)

        var info = [UserCollectionKey: Int]()
        info[.favorite] = container.decode(.favorite) ?? 0
        info[.planned] = container.decode(.planned) ?? 0
        info[.watched] = container.decode(.watched) ?? 0
        info[.watching] = container.decode(.watching) ?? 0
        info[.postponed] = container.decode(.postponed) ?? 0
        info[.abandoned] = container.decode(.abandoned) ?? 0
        addedIn = info

    }

    public func encode(to encoder: Encoder) throws {
        encoder.apply(CodingKeys.self) { container in
            container[.id] = id
            container[.type] = type
            container[.year] = year
            container[.name] = name
            container[.alias] = alias
            container[.season] = season
            container[.poster][.src] = poster?.absoluteString
            container[.freshAt] = freshAt
            container[.createdAt] = createdAt
            container[.updatedAt] = updatedAt
            container[.isOngoing] = isOngoing
            container[.ageRating] = ageRating
            container[.publishDay] = publishDay
            container[.originalDesc] = originalDesc
            container[.notification] = notification
            container[.episodesTotal] = episodesTotal
            container[.isInProduction] = isInProduction
            container[.isBlockedByGeo] = isBlockedByGeo
            container[.episodesAreUnknown] = episodesAreUnknown
            container[.isBlockedByCopyrights] = isBlockedByCopyrights
            container[.averageDurationOfEpisode] = averageDurationOfEpisode
            container[.favorite] = addedIn[.favorite]
            container[.planned] = addedIn[.planned]
            container[.watched] = addedIn[.watched]
            container[.watching] = addedIn[.watching]
            container[.postponed] = addedIn[.postponed]
            container[.abandoned] = addedIn[.abandoned]
            container[.genres] = genres
            container[.members] = members
            container[.playlist] = playlist
            container[.torrents] = torrents
            container[.sponsor] = sponsor
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

struct Genre: Codable, Hashable {
    let id: Int
    let name: String
    let totalReleases: Int?
    let imageURL: URL?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        let urlConverter = URLConverter()
        id = try container.decode(required: "id")
        name = container.decode("name") ?? ""
        totalReleases = container.decode("total_releases")
        imageURL = urlConverter.convert(from: container.decode("image", "preview"))
    }

    public func encode(to encoder: Encoder) throws {
        encoder.apply(CodingKeyString.self) { container in
            container["id"] = id
            container["name"] = name
            container["total_releases"] = totalReleases
            container["image"]["preview"] = imageURL?.absoluteString
        }
    }
}

struct Member: Codable, Hashable {
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

    public func encode(to encoder: Encoder) throws {
        encoder.apply(CodingKeyString.self) { container in
            container["id"] = id
            container["nickname"] = name
            container["role"] = role
            container["user"] = user
        }
    }
}

struct Sponsor: Codable, Hashable {
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
