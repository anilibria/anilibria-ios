import UIKit
import Combine

// MARK: - View Controller

final class SeriesViewController: BaseViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var secondTitleLabel: UILabel!
    @IBOutlet var favoriteView: SeriesFavoriteView!
    @IBOutlet var typeView: SeriesCollectionTypeView!
    @IBOutlet var donateButton: UIButton!
    @IBOutlet var tagsView: TagsView!

    @IBOutlet var infoTextView: AttributeLinksView!
    @IBOutlet var anonceLabel: UILabel!
    @IBOutlet var supportLabel: UILabel!
    @IBOutlet var supportLabelContainer: BorderedView!
    @IBOutlet var supportButton: UIButton!
    @IBOutlet var torrentsStackView: UIStackView!
    @IBOutlet var relatedView: UIView!
    @IBOutlet var relatedStackView: UIStackView!
    @IBOutlet var relatedTitleLabel: UILabel!
    @IBOutlet var relatedShimmerView: ShimmerView!
    @IBOutlet var contentShimmerViews: [ShimmerView] = []

    @IBOutlet var playButtonLabel: UILabel!
    @IBOutlet var playButtonContainer: ShadowView!

    @IBOutlet var weekDayView: WeekDayView!
    @IBOutlet var seriesImageView: UIImageView!

    @IBOutlet var episodesContainer: UIView!
    @IBOutlet var compactEpisodesContainer: UIView!

    private let episodesView = EpisodesView()

    private var bag = Set<AnyCancellable>()

    private var episodesContainreHidden: Bool = true {
        didSet {
            if episodesContainreHidden != oldValue {
                episodesContainer.isHidden = episodesContainreHidden
                compactEpisodesContainer.isHidden = !episodesContainreHidden
                updateEpisodesUI()
            }
        }
    }

    var handler: SeriesEventHandler!

    private var playButtonInset: CGFloat = 0 {
        didSet { updateInsets() }
    }
    private var keyboardInset: CGFloat = 0 {
        didSet { updateInsets() }
    }

    private let boldTextBuilder = AttributeStringBuilder()
        .set(color: .Text.secondary)
        .set(font: UIFont.font(ofSize: 16, weight: .bold))

    private let regularTextBuilder = AttributeStringBuilder()
        .set(color: .Text.main)
        .set(font: UIFont.font(ofSize: 16, weight: .regular))

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationButtons()
        addRefreshControl(scrollView: scrollView)
        seriesImageView.smoothCorners(with: 8)
        updateEpisodesUI()

        let action: Action<URL> = { [weak self] url in
            if url.isAttributeLink {
                if let genre = url.attributeLinkValue {
                    self?.handler.select(genre: genre)
                }
                return
            }
            self?.handler.select(url: url)
        }

        infoTextView.setTapLink(handler: action)

        let color = UIColor.Tint.active
        infoTextView.linkTextAttributes = [
            .foregroundColor: color,
            .underlineColor: color
        ]

        infoTextView.textContainerInset = .zero
        infoTextView.font = .font(ofSize: 16, weight: .regular)
        infoTextView.textColor = .Text.main
        supportLabelContainer.cornerRadius = 6

        relatedShimmerView.smoothCorners(with: 8)
        relatedShimmerView.backgroundColor = .Tint.shimmer
        relatedShimmerView.shimmerColor = .Surfaces.base
        relatedShimmerView.run()

        contentShimmerViews.forEach {
            $0.smoothCorners(with: 8)
            $0.backgroundColor = .Tint.shimmer
            $0.shimmerColor = .Surfaces.base
            $0.run()
        }

        seriesImageView.publisher(for: \.center).removeDuplicates().sink { [weak self] _ in
            guard let self else { return }
            infoTextView.textContainer.exclusionPaths = [
                UIBezierPath(rect: seriesImageView.frame.inset(
                    by: UIEdgeInsets(top: 0, left: -8, bottom: 8, right: 0)
                ))
            ]
        }.store(in: &bag)

        NotificationCenter.default
            .publisher(for: UIApplication.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                self?.updateKeyboard(notification)
            }
            .store(in: &bag)
    }

    private func updateKeyboard(_ note: Notification) {
        guard
            let info = note.userInfo,
            let endFrameScreen = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let endFrameInView = view.convert(endFrameScreen, from: nil)
        let overlap = view.bounds.intersection(endFrameInView).height

        keyboardInset = max(0, overlap - view.safeAreaInsets.bottom)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        episodesContainreHidden = view.bounds.width < 640
        playButtonInset = playButtonContainer.frame.height + 30
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        episodesView.invalidateLayout()
    }

    private func updateInsets() {
        scrollView.contentInset.bottom = max(keyboardInset, playButtonInset)
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Series.title
        self.supportLabel.text = L10n.Common.donatePls
        self.relatedTitleLabel.text = L10n.Common.related
        self.donateButton.setTitle(L10n.Screen.Other.donate, for: .normal)
        self.handler.didLoad()
    }

    private func updateEpisodesUI() {
        episodesView.removeFromSuperview()
        if episodesContainreHidden {
            episodesView.isCompact = true
            compactEpisodesContainer.addSubview(episodesView)
        } else {
            episodesView.isCompact = false
            episodesContainer.addSubview(episodesView)
        }
        episodesView.constraintEdgesToSuperview()
    }

    private func setupNavigationButtons() {
        var items = [UIBarButtonItem]()
        let shareButton = BarButton(image: .System.share) { [weak self] in
            self?.handler.share()
        }
        items.append(shareButton)
        #if targetEnvironment(macCatalyst)
        let refreshButton = BarButton(image: .System.refresh) { [weak self] in
            guard let self else { return }
            _ = showRefreshIndicator()
            handler.refresh()
        }
        items.append(refreshButton)
        #endif
        self.navigationItem.setRightBarButtonItems(items, animated: false)
    }

    override func refresh() {
        super.refresh()
        handler.refresh()
    }

    @IBAction func donateAction(_ sender: Any) {
        self.handler.donate()
    }

    @IBAction func favoriteAction(_ sender: Any) {
        favoriteView.isLoading = true
        let activity = ActivityHolder { [weak self] in
            self?.favoriteView.isLoading = false
        }
        self.handler.favorite(activity)
    }

    @IBAction func selectTypeAction(_ sender: Any) {
        typeView.isLoading = true
        let activity = ActivityHolder { [weak self] in
            self?.typeView.isLoading = false
        }
        self.handler.selectCollection(activity)
    }

    @IBAction func play(_ sender: Any) {
        handler.play()
    }
}

extension SeriesViewController: SeriesViewBehavior {
    func showUpdatesActivity() -> (any ActivityDisposable)? {
        typeView.isLoading = true
        favoriteView.isLoading = true
        let activity = ActivityHolder { [weak self] in
            self?.typeView.isLoading = false
            self?.favoriteView.isLoading = false
        }
        return activity
    }

    func can(favorite: Bool) {
        self.favoriteView.isUserInteractionEnabled = favorite
    }

    func set(playInfo: String?) {
        if let playInfo {
            playButtonContainer.isHidden = false
            playButtonLabel.text = playInfo
        } else {
            playButtonContainer.isHidden = true
        }
    }

    func set(favorite: Bool) {
        favoriteView.set(favorite: favorite)
    }

    func set(collection: UserCollectionType?) {
        typeView.configure(with: collection)
    }

    func set(episodes: EpisodesViewModel) {
        episodesView.configure(viewModel: episodes)
    }

    func set(series: Series) {
        seriesImageView.setImage(from: series.poster, placeholder: DefaultPlaceholder())
        contentShimmerViews.forEach {
            $0.stop()
            $0.isHidden = true
        }
        self.navigationItem.backButtonTitle = series.name?.main

        self.set(name: series.name)
        self.setParams(from: series)

        self.anonceLabel.text = series.notification

        if let publishDay = series.publishDay, series.isOngoing {
            weekDayView.configure(publishDay.value)
            weekDayView.isSelected = true
            weekDayView.isHidden = false
        } else {
            weekDayView.isHidden = true
        }

        if series.notification.isEmpty {
            self.anonceLabel.isHidden = true
        }

        tagsView.set(tags: series.tags)

        #if targetEnvironment(macCatalyst)
        self.set(torrents: series.torrents)
        #endif
        view.fadeTransition()
    }

    func set(series: [Series], current: Series) {
        relatedShimmerView.isHidden = true
        relatedShimmerView.stop()
        if series.isEmpty {
            relatedView.isHidden = true
            return
        }
        relatedView.isHidden = false
        series.enumerated().forEach { index, item in
            guard let view = RelatedSeriesView.fromNib() else {
                return
            }
            view.configure(index: index, series: item, selected: item.id == current.id)
            view.setTap { [weak self] in
                self?.handler.select(series: $0)
            }
            relatedStackView.addArrangedSubview(view)
        }
        relatedView.fadeTransition()
    }

    func set(torrents: [Torrent]) {
        torrentsStackView.arrangedSubviews.forEach {
            torrentsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let views = torrents.lazy.compactMap { item -> TorrentView? in
            let view = TorrentView.fromNib()
            view?.configure(item)
            view?.setTap { [weak self] in
                self?.handler.download(torrent: $0)
            }
            return view
        }
        for view in views {
            self.torrentsStackView.addArrangedSubview(view)
        }
    }

    func set(name: SeriesName?) {
        self.titleLabel.text = name?.main

        if name?.english.isEmpty == false {
            secondTitleLabel.isHidden = false
            secondTitleLabel.text = name?.english
        } else {
            secondTitleLabel.isHidden = true
        }
    }

    private func setParams(from series: Series) {
        let strings = L10n.Screen.Series.self
        var result: NSMutableAttributedString = .init()

        if let type = series.type {
            let title = self.boldTextBuilder.build(strings.type.withColon())
            let value = self.regularTextBuilder.build("\(type.description)\n")
            result = result + title + value
        }

        if let year = series.year {
            let title = self.boldTextBuilder.build(strings.year.withColon())
            let value = self.regularTextBuilder.build("\(year)\n")
            result = result + title + value
        }

        if let season = series.season {
            let title = self.boldTextBuilder.build(strings.season.withColon())
            let value = self.regularTextBuilder.build("\(season.description)\n")
            result = result + title + value
        }

        if let duration = series.averageDurationOfEpisode {
            let title = self.boldTextBuilder.build(strings.duration.withColon())
            let time = L10n.Screen.Series.approximalMinutes("\(duration)")
            let value = self.regularTextBuilder.build("\(time)\n")
            result = result + title + value
        }

        let availableCount = series.playlist.count
        let title = self.boldTextBuilder.build(strings.episodes.withColon())
        let episodes = series.episodesTotal.map { "\($0)"} ?? "?"
        let value = self.regularTextBuilder.build("\(availableCount)/\(episodes)\n")
        result = result + title + value

        if series.genres.isEmpty == false {
            var data = self.boldTextBuilder.build(strings.genres.withColon())
            let linkBuilder = self.regularTextBuilder.copy()

            let last = series.genres.last

            for genre in series.genres {
                if let url = URL(attributeLinkValue: "\(genre.id)") {
                    linkBuilder.set(link: url)
                    data = data + linkBuilder.build(genre.name)
                    if genre == last {
                        data = data + self.regularTextBuilder.build("\n")
                    } else {
                        data = data + self.regularTextBuilder.build(", ")
                    }
                }
            }

            result = result + data
        }

        if series.members.isEmpty == false {
            let items = Dictionary(grouping: series.members, by: { $0.role })
            let roles = items.compactMap { $0.key }.sorted(by: { $0.value < $1.value })
            roles.forEach { role in
                var data = self.boldTextBuilder.build(role.description.withColon())
                let members = items[role] ?? []
                let last = members.last
                for member in members {
                    data = data + regularTextBuilder.build(member.name)
                    if member == last {
                        data = data + self.regularTextBuilder.build("\n")
                    } else {
                        data = data + self.regularTextBuilder.build(", ")
                    }
                }
                result = result + data
            }
        }

        result = result + regularTextBuilder.build("\n")
        if let desc = series.desc {
            result = result + regularTextBuilder.build(desc)
        }
        self.infoTextView.attributedText = result
    }
}


private extension Series {
    var tags: [TagsView.Tag] {
        UserCollectionKey.allCases.compactMap {
            if let count = addedIn[$0], count > 0 {
                return .init(icon: $0.icon, title: "\(count)")
            }
            return nil
        }
    }
}

private extension String {
    func withColon() -> String {
        "\(self): "
    }
}

public final class ExpandedSpaceView: UIView {
    public override var intrinsicContentSize: CGSize {
        UIView.layoutFittingExpandedSize
    }
}
