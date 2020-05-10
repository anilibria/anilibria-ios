import DITranquillity
import RxSwift

final class PlayerServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(PlayerServiceImp.init)
            .as(PlayerService.self)
            .lifetime(.single)
    }
}

protocol PlayerService: class {
    func fetchSettings() -> PlayerSettings
    func update(settings: PlayerSettings)

    func fetchSeriesHistory() -> Single<[Series]>
    func fetchPlayerContext(for series: Series) -> Single<PlayerContext?>
    func set(context: PlayerContext, for series: Series) -> Single<Void>
    func removeHistory(for series: Series) -> Single<Void>
}

final class PlayerServiceImp: PlayerService {
    private let schedulers: SchedulerProvider
    private let settingsRepository: PlayerSettingsRepository
    private let historyRepository: HistoryRepository

    init(schedulers: SchedulerProvider,
         settingsRepository: PlayerSettingsRepository,
         historyRepository: HistoryRepository) {
        self.schedulers = schedulers
        self.settingsRepository = settingsRepository
        self.historyRepository = historyRepository
    }

    func fetchSettings() -> PlayerSettings {
        return self.settingsRepository.getSettings()
    }

    func update(settings: PlayerSettings) {
        self.settingsRepository.set(settings: settings)
    }

    func fetchSeriesHistory() -> Single<[Series]> {
        return Single.deferred { [unowned self] in
            let series = self.historyRepository.getItems()
                .map { $0.series }
            return .just(series)
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func fetchPlayerContext(for series: Series) -> Single<PlayerContext?> {
        return Single.deferred { [unowned self] in
            let item = self.historyRepository.getItems()
                .first(where: { $0.series.id == series.id })
            return .just(item?.context)
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func set(context: PlayerContext, for series: Series) -> Single<Void> {
        return Single.deferred { [unowned self] in
            let data = HistoryData(series: series, context: context)
            self.historyRepository.set(item: data)
            return .just(())
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    func removeHistory(for series: Series) -> Single<Void> {
        return Single.deferred { [unowned self] in
            self.historyRepository.remove(data: series.id)
            return .just(())
        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }
}
