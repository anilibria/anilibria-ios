import DITranquillity

final class NotifySettingsRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(NotifySettingsRepositoryImp.init)
            .as(NotifySettingsRepository.self)
            .lifetime(.single)
    }
}

protocol NotifySettingsRepository {
    func set(item: NotifySettings)
    func getItem() -> NotifySettings
}

final class NotifySettingsRepositoryImp: NotifySettingsRepository {
    private let key: String = "NotifySettings_KEY"

    private var buffered: NotifySettings?

    func set(item: NotifySettings) {
        self.buffered = item
        UserDefaults.standard[key] = self.buffered
    }

    func getItem() -> NotifySettings {
        if let data = self.buffered {
            return data
        }

        self.buffered = UserDefaults.standard[key] ?? NotifySettings()
        return self.buffered!
    }
}
