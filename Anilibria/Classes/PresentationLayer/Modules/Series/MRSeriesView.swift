import UIKit
import Combine

// MARK: - View Controller

final class SeriesViewController: BaseViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headerContainerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var secondTitleLabel: UILabel!
    @IBOutlet var favoriteCountLabel: UILabel!
    @IBOutlet var favoriteStarView: UIImageView!
    @IBOutlet var favoriteButton: RippleButton!
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

    private var header: SeriesHeaderView!
    private var weekDayViews: [WeekDayView] = []

    var handler: SeriesEventHandler!

    private let boldTextBuilder = AttributeStringBuilder()
        .set(color: UIColor(resource: .Text.secondary))
        .set(font: UIFont.font(ofSize: 13, weight: .bold))

    private let regularTextBuilder = AttributeStringBuilder()
        .set(color: UIColor(resource: .Text.main))
        .set(font: UIFont.font(ofSize: 13, weight: .regular))

    // MARK: - Life cycle

    override func viewDidLoad() {
        self.setupHeader()
        self.setupWeekView()
        super.viewDidLoad()

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

        let color = UIColor(resource: .Tint.active)
        paramsTextView.linkTextAttributes = [
            .foregroundColor: color,
            .underlineColor: color
        ]

        descTextView.linkTextAttributes = [
            .foregroundColor: color,
            .underlineColor: color
        ]

        descTextView.font = .font(ofSize: 14, weight: .regular)
        descTextView.textColor = UIColor(resource: .Text.main)
        supportLabelContainer.cornerRadius = 6
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Series.title
        self.supportLabel.text = L10n.Common.donatePls
        self.handler.didLoad()
    }

    private func setupNavigationButtons() {
        let item = BarButton(image: UIImage(resource: .iconShare),
                             imageEdge: inset(8, 0, 10, 0)) { [weak self] in
            self?.handler.share()
        }
        self.navigationItem.setRightBarButtonItems([item], animated: false)
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

    @IBAction func donateAction(_ sender: Any) {
        self.handler.donate()
    }

    @IBAction func favoriteAction(_ sender: Any) {
        self.handler.favorite()
    }

    @IBAction func weekDaysAction(_ sender: Any) {
        self.handler.schedule()
    }
}

extension SeriesViewController: SeriesViewBehavior {
    func can(favorite: Bool) {
        self.favoriteButton.isUserInteractionEnabled = favorite
    }

    func can(watch: Bool) {
        self.header.setPlayVisible(value: watch)
    }

    func set(favorite: Bool, count: Int) {
        self.favoriteStarView.tintColor = .darkGray
        self.favoriteCountLabel.text = "\(count)"
    }

    func set(series: Series) {
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

        #if targetEnvironment(macCatalyst)
        self.set(torrents: series.torrents)
        #endif
    }

    func set(torrents: [Torrent]) {
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

        if let episodes = series.episodesTotal {
            let title = self.boldTextBuilder.build(strings.episodes)
            let value = self.regularTextBuilder.build("\(episodes)\n")
            result = result + title + value
        }

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
            items.forEach { (role, members) in
                guard let role else { return }
                var data = self.boldTextBuilder.build("\(role.description): ")

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

    func set(desc: String) {
        self.descTextView.text = desc
    }
}

public final class WeekDayView: CircleView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(ofSize: 12, weight: .semibold)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private var subscriber: AnyCancellable?
    
    public private(set) var day: WeekDay?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(titleLabel)
        borderColor = UIColor(resource: .Tint.separator)
        borderThickness = 1
        backgroundColor = .clear
        
        titleLabel.constraintEdgesToSuperview(.init(top: 10, left: 4, bottom: 10, right: 4))
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
    }
    
    func configure(_ weekDay: WeekDay) {
        self.day = weekDay
        titleLabel.text = weekDay.shortName
        
        subscriber = Language.languageChanged.sink { [weak self] in
            self?.titleLabel.text = weekDay.shortName
        }
    }

    var isSelected: Bool = false {
        didSet {
            if self.isSelected {
                self.backgroundColor = UIColor(resource: .Buttons.selected)
                self.titleLabel.textColor = UIColor(resource: .Text.monoLight)
                self.borderThickness = 0
            } else {
                self.backgroundColor = .clear
                self.titleLabel.textColor = UIColor(resource: .Text.secondary)
                self.borderThickness = 1
            }
        }
    }
}
