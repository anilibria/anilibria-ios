import DITranquillity
import Combine
import Foundation

final class PlayerServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(PlayerServiceImp.init)
            .as(PlayerService.self)
            .lifetime(.single)
    }
}

protocol PlayerService: AnyObject {
    func fetchSettings() -> PlayerSettings
    func update(settings: PlayerSettings)

    func observeSettings() -> AnyPublisher<PlayerSettings, Never>
    func fetchSeriesHistory() -> AnyPublisher<[Series], Never>
    func fetchPlayerContext(for series: Series) -> AnyPublisher<PlayerContext?, Never>
    func set(context: PlayerContext, for series: Series)
    func removeHistory(for series: Series)
}

final class PlayerServiceImp: PlayerService {
    private let settingsRepository: PlayerSettingsRepository
    private let seriesRepository: SeriesRepository
    private let settings: CurrentValueSubject<PlayerSettings, Never>

    init(settingsRepository: PlayerSettingsRepository,
         seriesRepository: SeriesRepository) {
        self.settingsRepository = settingsRepository
        self.seriesRepository = seriesRepository
        settings = .init(settingsRepository.getSettings())
    }

    func fetchSettings() -> PlayerSettings {
        settings.value
    }

    func observeSettings() -> AnyPublisher<PlayerSettings, Never> {
        settings.eraseToAnyPublisher()
    }

    func update(settings: PlayerSettings) {
        self.settingsRepository.set(settings: settings)
        self.settings.send(settings)
    }

    func fetchSeriesHistory() -> AnyPublisher<[Series], Never> {
        seriesRepository.getSeriesWithPlayerContext()
    }

    func fetchPlayerContext(for series: Series) -> AnyPublisher<PlayerContext?, Never> {
        seriesRepository.getPlayerContext(for: series.id)
    }

    func set(context: PlayerContext, for series: Series) {
        seriesRepository.add(series: series)
        seriesRepository.set(playerContext: context, seriesID: series.id)
    }

    func removeHistory(for series: Series) {
        seriesRepository.set(playerContext: nil, seriesID: series.id)
    }
}
