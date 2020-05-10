import DITranquillity
import RxSwift

final class ConfigRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(ConfigRepositoryImp.init)
            .as(ConfigRepository.self)
            .lifetime(.single)
    }
}

protocol ConfigRepository {
    func set(config: AniConfig)
    func getConfig() -> AniConfig?

    func getCurrentSettings() -> AniSettings?
    func setCurrent(settings: AniSettings)
}

final class ConfigRepositoryImp: ConfigRepository {
    private let keyConfig: String = "ANI_CONFIG_KEY"
    private let keySettings: String = "ANI_SETTINGS_KEY"

    let schedulers: SchedulerProvider

    init(schedulers: SchedulerProvider) {
        self.schedulers = schedulers
    }

    func set(config: AniConfig) {
        UserDefaults.standard[keyConfig] = config
    }

    func getConfig() -> AniConfig? {
        UserDefaults.standard[keyConfig]
    }

    func setCurrent(settings: AniSettings) {
        UserDefaults.standard[keySettings] = settings
    }

    func getCurrentSettings() -> AniSettings? {
        UserDefaults.standard[keySettings]
    }
}
