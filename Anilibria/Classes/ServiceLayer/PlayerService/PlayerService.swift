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
    func fetchSeriesHistory() -> AnyPublisher<[Series], Error>
    func fetchPlayerContext(for series: Series) -> AnyPublisher<PlayerContext?, Error>
    func set(context: PlayerContext, for series: Series) -> AnyPublisher<Void, Error>
    func removeHistory(for series: Series) -> AnyPublisher<Void, Error>
}

final class PlayerServiceImp: PlayerService {
    private let settingsRepository: PlayerSettingsRepository
    private let historyRepository: HistoryRepository
    private let settings: CurrentValueSubject<PlayerSettings, Never>

    init(settingsRepository: PlayerSettingsRepository,
         historyRepository: HistoryRepository) {
        self.settingsRepository = settingsRepository
        self.historyRepository = historyRepository
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

    func fetchSeriesHistory() -> AnyPublisher<[Series], Error> {
        return Deferred { [unowned self] in
            let series = self.historyRepository.getItems()
                .map { $0.series }
            return AnyPublisher<[Series], Error>.just(series)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchPlayerContext(for series: Series) -> AnyPublisher<PlayerContext?, Error> {
        return Deferred { [unowned self] in
            let item = self.historyRepository.getItems()
                .first(where: { $0.series.id == series.id })
            return AnyPublisher<PlayerContext?, Error>.just(item?.context)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func set(context: PlayerContext, for series: Series) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            let data = HistoryData(series: series, context: context)
            self.historyRepository.set(item: data)
            return AnyPublisher<Void, Error>.just(())
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func removeHistory(for series: Series) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            self.historyRepository.remove(data: series.id)
            return  AnyPublisher<Void, Error>.just(())
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
