import UIKit
import Combine

// MARK: - View Controller

final class SeriesViewController: BaseViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headerContainerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var secondTitleLabel: UILabel!
    @IBOutlet var favoriteView: SeriesFavoriteView!
    @IBOutlet var typeView: SeriesCollectionTypeView!
    @IBOutlet var tagsView: TagsView!

    @IBOutlet var paramsTextView: AttributeLinksView!
    @IBOutlet var descTextView: AttributeLinksView!
    @IBOutlet var weekDayStackView: UIStackView!
    @IBOutlet var weekDaysContainer: UIView!
    @IBOutlet var anonceLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var supportLabel: UILabel!
    @IBOutlet var supportLabelContainer: BorderedView!
    @IBOutlet var supportButton: UIButton!
    @IBOutlet var torrentsStackView: UIStackView!
    @IBOutlet var relatedView: UIView!
    @IBOutlet var relatedStackView: UIStackView!
    @IBOutlet var relatedTitleLabel: UILabel!
    @IBOutlet var relatedShimmerView: ShimmerView!
    @IBOutlet var contentShimmerViews: [ShimmerView] = []

    private var header: SeriesHeaderView!
    private var weekDayViews: [WeekDayView] = []

    var handler: SeriesEventHandler!

    private let boldTextBuilder = AttributeStringBuilder()
        .set(color: .Text.secondary)
        .set(font: UIFont.font(ofSize: 14, weight: .bold))

    private let regularTextBuilder = AttributeStringBuilder()
        .set(color: .Text.main)
        .set(font: UIFont.font(ofSize: 14, weight: .regular))

    // MARK: - Life cycle

    override func viewDidLoad() {
        self.setupHeader()
        self.setupWeekView()
        super.viewDidLoad()
        self.setupNavigationButtons()
        addRefreshControl(scrollView: scrollView)

        let action: Action<URL> = { [weak self] url in
            if url.isAttributeLink {
                if let genre = url.attributeLinkValue {
                    self?.handler.select(genre: genre)
                }
                return
            }
            self?.handler.select(url: url)
        }

        paramsTextView.setTapLink(handler: action)
        descTextView.setTapLink(handler: action)

        let color = UIColor.Tint.active
        paramsTextView.linkTextAttributes = [
            .foregroundColor: color,
            .underlineColor: color
        ]

        descTextView.linkTextAttributes = [
            .foregroundColor: color,
            .underlineColor: color
        ]

        descTextView.font = .font(ofSize: 14, weight: .regular)
        descTextView.textColor = .Text.main
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
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Series.title
        self.supportLabel.text = L10n.Common.donatePls
        self.relatedTitleLabel.text = L10n.Common.related
        self.handler.didLoad()
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

    private func setupHeader() {
        if let header = SeriesHeaderView.fromNib() {
            self.header = header
            self.scrollView.contentInset.top = 320
            self.headerContainerView.addSubview(header)
            header.constraintEdgesToSuperview()
            self.header.setPlay { [weak self] in
                self?.handler.play()
            }
        }
    }
    
    private func setupWeekView() {
        let days = WeekDay.allCases
        
        for day in days {
            let view = WeekDayView()
            view.configure(day)
            weekDayStackView.addArrangedSubview(view)
            weekDayViews.append(view)
        }
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

    @IBAction func weekDaysAction(_ sender: Any) {
        self.handler.schedule()
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

    func can(watch: Bool) {
        self.header.setPlayVisible(value: watch)
    }

    func set(favorite: Bool) {
        favoriteView.set(favorite: favorite)
    }

    func set(collection: UserCollectionType?) {
        typeView.configure(with: collection)
    }

    func set(series: Series) {
        contentShimmerViews.forEach {
            $0.stop()
            $0.isHidden = true
        }
        self.header.configure(series)
        self.navigationItem.backButtonTitle = series.name?.main

        self.set(name: series.name)
        self.setParams(from: series)
        self.set(desc: series.desc)

        self.anonceLabel.text = series.notification

        if let publishDay = series.publishDay, series.isOngoing {
            self.weekDayViews.first(where: { $0.day == publishDay.value })?.isSelected = true
        } else {
            self.weekDaysContainer.isHidden = true
        }

        if series.notification.isEmpty {
            self.anonceLabel.isHidden = true
        }

        self.separatorView.isHidden = self.weekDaysContainer.isHidden &&
            self.anonceLabel.isHidden

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

    func setParams(from series: Series) {
        let strings = L10n.Screen.Series.self
        var result: NSMutableAttributedString = .init()

        if let type = series.type {
            let title = self.boldTextBuilder.build(strings.type)
            let value = self.regularTextBuilder.build("\(type.description)\n")
            result = result + title + value
        }

        if let year = series.year {
            let title = self.boldTextBuilder.build(strings.year)
            let value = self.regularTextBuilder.build("\(year)\n")
            result = result + title + value
        }

        if let season = series.season {
            let title = self.boldTextBuilder.build(strings.season)
            let value = self.regularTextBuilder.build("\(season.description)\n")
            result = result + title + value
        }

        if let duration = series.averageDurationOfEpisode {
            let title = self.boldTextBuilder.build(strings.duration)
            let time = L10n.Screen.Series.approximalMinutes("\(duration)")
            let value = self.regularTextBuilder.build("\(time)\n")
            result = result + title + value
        }

        let availableCount = series.playlist.count
        let title = self.boldTextBuilder.build(strings.episodes)
        let episodes = series.episodesTotal.map { "\($0)"} ?? "?"
        let value = self.regularTextBuilder.build("\(availableCount)/\(episodes)\n")
        result = result + title + value

        if series.genres.isEmpty == false {
            var data = self.boldTextBuilder.build(strings.genres)
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
                var data = self.boldTextBuilder.build("\(role.description): ")
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

        self.paramsTextView.attributedText = result
    }

    func set(desc: NSAttributedString?) {
        guard let desc else {
            self.descTextView.attributedText = nil
            return
        }
        self.descTextView.attributedText = regularTextBuilder.build(desc)
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
