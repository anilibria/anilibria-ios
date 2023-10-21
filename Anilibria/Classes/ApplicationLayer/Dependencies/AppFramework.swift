import DITranquillity
import Foundation

public class AppFramework: DIFramework {
    public static func load(container: DIContainer) {
        container.append(part: SomePart.self)
        container.append(part: RepositoriesPart.self)
        container.append(part: ServicesPart.self)
        container.append(part: PersentersPart.self)
    }
}

private class RepositoriesPart: DIPart {
    static let parts: [DIPart.Type] = [
        ConfigRepositoryPart.self,
        HistoryRepositoryPart.self,
        PlayerSettingsRepositoryPart.self,
        UserRepositoryPart.self,
        LinksRepositoryPart.self,
        BackendRepositoryPart.self
    ]

    static func load(container: DIContainer) {
        for part in self.parts {
            container.append(part: part)
        }

        container.register {
            ClearableManagerImp(items: many($0))
        }
        .as(ClearableManager.self)
        .lifetime(.single)
    }
}

private class ServicesPart: DIPart {
    static let parts: [DIPart.Type] = [
        AppConfigurationServicePart.self,
        PlayerServicePart.self,
        FavoriteServicePart.self,
        SessionServicePart.self,
        MenuServicePart.self,
        FeedServicePart.self,
        LinksServicePart.self,
        TorrentServicePart.self
    ]

    static func load(container: DIContainer) {
        for part in self.parts {
            container.append(part: part)
        }
    }
}

private class PersentersPart: DIPart {
    static let parts: [DIPart.Type] = [
        ConfigurationPart.self,
        MainContainerPart.self,
        HistoryPart.self,
        SettingsPart.self,
        FavoritePart.self,
        SocialAuthPart.self,
        SignInPart.self,
        OtherPart.self,
        ChoiceSheetPart.self,
        PlayerPart.self,
        MPVPlayerPart.self,
        CommentsAuthPart.self,
        SeriesContainerPart.self,
        CommentsPart.self,
        SeriesPart.self,
        SearchPart.self,
        FilterPart.self,
        CatalogPart.self,
        SchedulePart.self,
        FeedPart.self,
        NewsPart.self,
        TorrentListPart.self
    ]

    static func load(container: DIContainer) {
        for part in self.parts {
            container.append(part: part)
        }
    }
}

private class SomePart: DIPart {
    static func load(container: DIContainer) {
        container.register {
            BackendConfiguration(converter: JsonResponseConverter(),
                                 interceptor: nil,
                                 retrier: $0)
        }
        .lifetime(.single)

        container.register(MainRetrier.init)
            .injection(cycle: true, { $0.sessionService = $1 })
            .as(LoadRetrier.self)
            .lifetime(.single)
    }
}
