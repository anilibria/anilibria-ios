import DITranquillity

final class PlayerSettingsRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(PlayerSettingsRepositoryImp.init)
            .as(PlayerSettingsRepository.self)
            .lifetime(.single)
    }
}

protocol PlayerSettingsRepository {
    func set(settings: PlayerSettings)
    func getSettings() -> PlayerSettings
}

final class PlayerSettingsRepositoryImp: PlayerSettingsRepository {
    private let key: String = "PLAYER_SETTINGS_KEY"

    private var buffered: PlayerSettings?

    func set(settings: PlayerSettings) {
        self.buffered = settings
        UserDefaults.standard[key] = settings
    }

    func getSettings() -> PlayerSettings {
        if let data = self.buffered {
            return data
        }

        self.buffered = UserDefaults.standard[key] ?? PlayerSettings()
        return self.buffered!
    }
}
