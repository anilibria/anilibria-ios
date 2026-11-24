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

    func observeHistoryUpdates() -> AnyPublisher<HistoryUpdates, Never>
    func fetchSeriesHistory() -> AnyPublisher<[Series], Never>
    func removeHistory(for series: Series)
    func getActiveEpisodeID(for series: Series) -> String?
    func setActiveEpisodeID(_ episodeID: String, for series: Series)

    func observeTimecodesUpdates() -> AnyPublisher<TimeCodeUpdates, Never>
    func getTimeCode(userID: Int?, episodeID: String) -> TimeCodeData?
    func getTimeCodes(userID: Int?, episodeIDs: [String]) -> AnyPublisher<[String : TimeCodeData], Never>
    func syncTimeCodes(userID: Int?) -> AnyPublisher<Void, any Error>
    func set(timeCodes: [TimeCodeData], series: Series, userID: Int?)
}

final class PlayerServiceImp: PlayerService {
    private let backendRepository: BackendRepository
    private let settingsRepository: PlayerSettingsRepository
    private let historyRepository: HistoryRepository
    private let episodesRepository: EpisodesRepository
    private let settings: CurrentValueSubject<PlayerSettings, Never>
    private let historyUpdates: PassthroughSubject<HistoryUpdates, Never> = .init()
    private let timecodesUpdates: PassthroughSubject<TimeCodeUpdates, Never> = .init()

    private var cancellabes: Set<AnyCancellable> = []

    private let syncTimeKey: String = "SYNC_TIME_KEY"

    private var lastSyncTime: Date? {
        didSet {
            UserDefaults.standard[syncTimeKey] = lastSyncTime
        }
    }

    init(backendRepository: BackendRepository,
         settingsRepository: PlayerSettingsRepository,
         historyRepository: HistoryRepository,
         episodesRepository: EpisodesRepository) {
        self.backendRepository = backendRepository
        self.settingsRepository = settingsRepository
        self.historyRepository = historyRepository
        self.episodesRepository = episodesRepository
        settings = .init(settingsRepository.getSettings())
        self.lastSyncTime = UserDefaults.standard[syncTimeKey]
    }

    func fetchSettings() -> PlayerSettings {
        settings.value
    }

    func observeSettings() -> AnyPublisher<PlayerSettings, Never> {
        settings.eraseToAnyPublisher()
    }

    func observeHistoryUpdates() -> AnyPublisher<HistoryUpdates, Never> {
        historyUpdates.eraseToAnyPublisher()
    }

    func observeTimecodesUpdates() -> AnyPublisher<TimeCodeUpdates, Never> {
        timecodesUpdates.eraseToAnyPublisher()
    }

    func update(settings: PlayerSettings) {
        self.settingsRepository.set(settings: settings)
        self.settings.send(settings)
    }

    func fetchSeriesHistory() -> AnyPublisher<[Series], Never> {
        historyRepository.getSeriesHistory()
    }

    func removeHistory(for series: Series) {
        historyRepository.remove(seriesID: series.id)
        historyUpdates.send(.removed(series: series))
    }

    func getTimeCode(userID: Int?, episodeID: String) -> TimeCodeData? {
        episodesRepository.getTimeCode(for: userID, episodeID: episodeID)
    }

    func getTimeCodes(userID: Int?, episodeIDs: [String]) -> AnyPublisher<[String : TimeCodeData], Never> {
        episodesRepository.getTimeCodes(for: userID, episodeIDs: episodeIDs)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getActiveEpisodeID(for series: Series) -> String? {
        let data = historyRepository.getActiveEpisode(for: series.id)
        switch data {
        case .id(let episodeID):
            return episodeID
        case .index(let index):
            return series.playlist[safe: index]?.id
        default:
            return nil
        }
    }

    func setActiveEpisodeID(_ episodeID: String, for series: Series) {
        historyRepository.add(series: series, episodeID: episodeID)
        historyUpdates.send(.added(series: series))
    }

    func set(timeCodes: [TimeCodeData], series: Series, userID: Int?) {
        episodesRepository.set(timeCodeData: timeCodes, for: userID)
        backendRepository.request(SaveTimecodesRequest(items: timeCodes))
            .sink { _ in }
            .store(in: &cancellabes)
        timecodesUpdates.send(TimeCodeUpdates(seriesID: series.id, timeCodes: timeCodes))
    }

    func syncTimeCodes(userID: Int?) -> AnyPublisher<Void, any Error> {
        if let userID {
            return getUserCodes(userID: userID)
        }
        return .just(())
    }

    private func getUserCodes(userID: Int) -> AnyPublisher<Void, any Error> {
        let request = GetTimecodesRequest(since: lastSyncTime?.addingTimeInterval(-60 * 2))
        return backendRepository.request(request)
        .receive(on: DispatchQueue.global(qos: .userInitiated))
        .flatMap { [unowned self] remoteCodes in
            handleCodes(
                userID: userID,
                remote: remoteCodes,
                date: request.date
            )
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func handleCodes(
        userID: Int,
        remote: [TimeCodeData],
        date: Date
    ) -> AnyPublisher<Void, any Error> {
        lastSyncTime = date

        if !remote.isEmpty {
            episodesRepository.set(timeCodeData: remote, for: userID)
        }
        return .just(())
    }

}

enum HistoryUpdates {
    case removed(series: Series)
    case added(series: Series)
}

struct TimeCodeUpdates {
    let seriesID: Int
    let timeCodes: [TimeCodeData]
}
