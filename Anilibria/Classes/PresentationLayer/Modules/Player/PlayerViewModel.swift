import DITranquillity
import Combine
import UIKit

final class PlayerPart: DIPart {
    static func load(container: DIContainer) {
        container.register(PlayerViewModel.init)
            .lifetime(.objectGraph)
    }
}

final class PlayerViewModel {
    private var router: PlayerRoutable!
    private var series: Series!
    private var context: PlayerContext?
    private var bag = Set<AnyCancellable>()

    @Published private(set) var orientation = InterfaceOrientation.current
    @Published private(set) var playItem: PlayItem?
    @Published private(set) var playbackRate: Double

    let skipViewModel = SkipViewModel()

    private var videoQuality: VideoQuality = .fullHd {
        didSet {
            context?.quality = videoQuality
        }
    }

    var seriesName: String {
        series.name?.main ?? ""
    }

    private var playerSettings: PlayerSettings {
        didSet {
            playbackRate = playerSettings.playbackRate
        }
    }

    var playOnStartup: Bool {
        playerSettings.playOnStartup
    }

    private let playerService: PlayerService

    init(playerService: PlayerService) {
        self.playerService = playerService
        self.playerSettings = playerService.fetchSettings()
        self.playbackRate = playerSettings.playbackRate
        skipViewModel.set(mode: playerSettings.skipMode)
    }
}

extension PlayerViewModel {
    func bind(router: PlayerRoutable,
              series: Series) {
        self.router = router
        self.series = series

        self.playerService
            .fetchPlayerContext(for: self.series)
            .sink(onNext: { [weak self] context in
                guard let self else { return }
                let context = context ?? PlayerContext(
                    quality: playerSettings.quality
                )
                run(with: context)
            })
            .store(in: &bag)
    }

    func selectPlayItem() {
        guard let playItem else { return }
        let selection = PlaylistItemSelectionModel(
            series: series,
            selected: playItem.value
        )

        selection.didSelect = { [weak self] item in
            self?.run(item: item)
        }

        self.router.openItemSelection(with: selection)
    }

    func selectNext() {
        guard let playItem else { return }
        if let item = series?.playlist[safe: playItem.index + 1] {
            run(item: item)
        }
    }

    func selectPrevious() {
        guard let playItem else { return }
        if let item = series?.playlist[safe: playItem.index - 1] {
            run(item: item)
        }
    }

    private func run(item: PlaylistItem) {
        guard let index = series?.playlist.firstIndex(of: item) else { return }
        playItem = PlayItem(
            index: index,
            value: item,
            time: context?.allItems[index] ?? 0,
            quality: videoQuality,
            itemsCount: series?.playlist.count ?? 0
        )
        skipViewModel.set(item: playItem)
    }

    private func seriesEnded() {
        if playerSettings.autoPlay {
            selectNext()
        }
    }

    func update(time: Double) {
        guard let playItem else { return }
        skipViewModel.update(time: time)
        if time >= playItem.value.duration {
            context?.time = 0
            context?.allItems.removeValue(forKey: playItem.index)
            save()
            seriesEnded()
        } else {
            context?.number = playItem.index
            context?.time = time
            context?.allItems[playItem.index] = time
        }
    }

    func showSettings() {
        var groups: [ChoiceGroup] = []
        setOrientation(to: &groups)
        setQuality(to: &groups)
        setRate(to: &groups)
        setAutoPlay(to: &groups)
        setSkipMode(to: &groups)

        self.router.openSheet(with: groups)
    }

    private func setOrientation(to groups: inout [ChoiceGroup]) {
        if UIDevice.current.userInterfaceIdiom != .phone {
            return
        }
        let didSelectOrientation: (InterfaceOrientation) -> Bool = { [weak self] item in
            self?.orientation = item
            item.save()
            return false
        }

        let orientations = InterfaceOrientation.allCases

        let orientationItems = orientations.map {
            ChoiceItem(
                value: $0,
                title: $0.title,
                isSelected: orientation == $0,
                didSelect: didSelectOrientation
            )
        }

        groups.append(ChoiceGroup(
            title: L10n.Common.orientation,
            isExpandable: true,
            items: orientationItems)
        )
    }

    private func setQuality(to groups: inout [ChoiceGroup]) {
        guard let playItem else { return }
        let didSelect: (VideoQuality) -> Bool = { [weak self] item in
            self?.update(quality: item)
            return false
        }

        let qualities = playItem.value.supportedQualities()
        let items = qualities.map {
            ChoiceItem(
                value: $0,
                title: $0.name, isSelected: videoQuality == $0,
                didSelect: didSelect
            )
        }

        groups.append(ChoiceGroup(
            title: L10n.Common.quality,
            isExpandable: true,
            items: items
        ))
    }

    private func setRate(to groups: inout [ChoiceGroup]) {
        let didSelect: (Double) -> Bool = { [weak self] item in
            guard let self else { return false }
            playerSettings.playbackRate = item
            playerService.update(settings: playerSettings)
            return false
        }

        let options = PlayerSettings.playbackRateOptions
        let items = options.map {
            ChoiceItem(
                value: $0,
                title: PlayerSettings.nameFor(rate: $0),
                isSelected: playerSettings.playbackRate == $0,
                didSelect: didSelect
            )
        }

        groups.append(ChoiceGroup(
            title: L10n.Common.playbackRate,
            isExpandable: true,
            items: items)
        )
    }

    private func setAutoPlay(to groups: inout [ChoiceGroup]) {
        let didSelect: (Bool) -> Bool = { [weak self] item in
            guard let self else { return false }
            playerSettings.autoPlay = item
            playerService.update(settings: playerSettings)
            return false
        }

        let items = [true, false].map {
            ChoiceItem(
                value: $0,
                title: PlayerSettings.nameFor(bool: $0),
                isSelected: playerSettings.autoPlay == $0,
                didSelect: didSelect
            )
        }

        groups.append(ChoiceGroup(
            title: L10n.Common.autoPlay,
            isExpandable: true,
            items: items)
        )
    }

    private func setSkipMode(to groups: inout [ChoiceGroup]) {
        let didSelect: (SkipCreditsMode) -> Bool = { [weak self] item in
            guard let self else { return false }
            playerSettings.skipMode = item
            playerService.update(settings: playerSettings)
            skipViewModel.set(mode: item)
            return false
        }

        let items = SkipCreditsMode.allCases.map {
            ChoiceItem(
                value: $0,
                title: $0.name,
                isSelected: playerSettings.skipMode == $0,
                didSelect: didSelect
            )
        }

        groups.append(ChoiceGroup(
            title: L10n.Common.skipCredits,
            isExpandable: true,
            items: items)
        )
    }

    func back() {
        self.router.back()
    }

    func save() {
        guard let context else { return }
        self.playerService
            .set(context: context, for: self.series)
            .sink()
            .store(in: &bag)
    }

    private func update(quality: VideoQuality) {
        if let time = context?.time {
            videoQuality = quality
            playItem?.set(quality: quality, time: time)
        }
    }

    private func run(with context: PlayerContext) {
        self.context = context
        let index = context.number
        let time = context.time
        videoQuality = context.quality

        if let item = series?.playlist[safe: index] {
            playItem = PlayItem(
                index: index,
                value: item,
                time: time,
                quality: videoQuality,
                itemsCount: series?.playlist.count ?? 0
            )
            skipViewModel.set(item: playItem)
        }
    }
}


extension UIInterfaceOrientationMask {
    var name: String {
        switch self {
        case .portrait: return L10n.Common.Orientation.portrait
        case .landscapeLeft: return L10n.Common.Orientation.landscape
        case .all: return L10n.Common.Orientation.system
        default: return ""
        }
    }
}

struct PlayItem {
    let index: Int
    let value: PlaylistItem
    private(set) var time: Double = 0
    private(set) var quality: VideoQuality?
    private(set) var url: URL?

    let isLast: Bool
    let isFirst: Bool

    var name: String {
        if let ordinal = value.ordinal  {
            return "\(NSNumber(value: ordinal))"
        }
        return value.title
    }

    init(index: Int,
         value: PlaylistItem,
         time: Double,
         quality: VideoQuality,
         itemsCount: Int) {
        self.index = index
        self.value = value
        self.isLast = index == itemsCount - 1
        self.isFirst = index == 0
        set(quality: quality, time: time)
    }

    fileprivate mutating func set(quality: VideoQuality, time: Double) {
        let videoUrl = value.video[quality]
        if videoUrl == nil, let bestQuality = value.supportedQualities().first {
            self.quality = bestQuality
            self.url = value.video[bestQuality]
        } else {
            self.quality = quality
            self.url = videoUrl
        }
        set(time: time)
    }

    fileprivate mutating func set(time: Double) {
        self.time = time
    }
}
