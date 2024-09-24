import UIKit
import Combine

// MARK: - View Controller

final class SeriesViewController: BaseViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headerContainerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var seconTitleLabel: UILabel!
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
    @IBOutlet var supportButton: UIButton!
    @IBOutlet var torrentsStackView: UIStackView!

    private var header: SeriesHeaderView!
    private var weekDayViews: [WeekDayView] = []

    var handler: SeriesEventHandler!

    private let boldTextBuilder = AttributeStringBuilder()
        .set(font: UIFont.font(ofSize: 13, weight: .bold))

    private let regularTextBuilder = AttributeStringBuilder()
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

        self.paramsTextView.setTapLink(handler: action)
        self.descTextView.setTapLink(handler: action)

        self.paramsTextView.linkTextAttributes = [
            .foregroundColor: MainTheme.shared.red,
            .underlineColor: MainTheme.shared.red
        ]

        self.descTextView.linkTextAttributes = [
            .foregroundColor: MainTheme.shared.red,
            .underlineColor: MainTheme.shared.red
        ]
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
        let theme = MainTheme.shared
        self.favoriteStarView.tintColor = favorite ? theme.darkRed : .darkGray
        self.favoriteCountLabel.text = "\(count)"
    }

    func set(series: Series) {
        self.header.configure(series)

        self.set(names: series.names)
        self.setParams(from: series)
        if let desc = series.desc {
            self.set(desc: desc)
        }

        self.anonceLabel.text = series.announce

        if series.statusCode == .finished {
            self.weekDaysContainer.isHidden = true
        } else {
            if let day = series.day {
                self.weekDayViews.first(where: { $0.day == day })?.isSelected = true
            }
        }

        if series.announce.isEmpty {
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

    func set(names: [String]) {
        self.titleLabel.text = names.first

        if names.count > 1 {
            self.seconTitleLabel.text = names.last
        }
    }

    func setParams(from series: Series) {
        let strings = L10n.Screen.Series.self
        var result: NSMutableAttributedString = .init()

        if series.year.isEmpty == false {
            let title = self.boldTextBuilder.build(strings.year)
            let value = self.regularTextBuilder.build("\(series.year)\n")
            result = result + title + value
        }

        if series.voices.isEmpty == false {
            let title = self.boldTextBuilder.build(strings.voices)
            let value = self.regularTextBuilder.build("\(series.voices.joined(separator: ", "))\n")
            result = result + title + value
        }

        if series.type.isEmpty == false {
            let title = self.boldTextBuilder.build(strings.type)
            let value = self.regularTextBuilder.build("\(series.type)\n")
            result = result + title + value
        }

        if series.status.isEmpty == false {
            let title = self.boldTextBuilder.build(strings.status)
            let value = self.regularTextBuilder.build("\(series.status)\n")
            result = result + title + value
        }

        if series.genres.isEmpty == false {
            var data = self.boldTextBuilder.build(strings.genres)
            let linkBuilder = self.regularTextBuilder.copy()

            let last = series.genres.last

            for genre in series.genres {
                if let url = URL(attributeLinkValue: genre) {
                    linkBuilder.set(link: url)
                    data = data + linkBuilder.build(genre)
                    if genre == last {
                        data = data + self.regularTextBuilder.build("\n")
                    } else {
                        data = data + self.regularTextBuilder.build(", ")
                    }
                }
            }

            result = result + data
        }

        self.paramsTextView.attributedText = result
    }

    func set(desc: NSAttributedString) {
        self.descTextView.attributedText = desc
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
        borderColor = .lightGray
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
                self.backgroundColor = MainTheme.shared.darkRed
                self.titleLabel.textColor = MainTheme.shared.white
                self.borderThickness = 0
            } else {
                self.backgroundColor = .clear
                self.titleLabel.textColor = .darkGray
                self.borderThickness = 1
            }
        }
    }
}
