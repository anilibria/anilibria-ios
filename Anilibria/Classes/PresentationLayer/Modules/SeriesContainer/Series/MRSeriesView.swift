import UIKit

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
    @IBOutlet var weekDayViews: [WeekDayView]!
    @IBOutlet var weekDaysContainer: UIView!
    @IBOutlet var anonceLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var supportLabel: UILabel!
    @IBOutlet var supportButton: UIButton!
    @IBOutlet var torrentsStackView: UIStackView!

    private var header: SeriesHeaderView!

    var handler: SeriesEventHandler!

    private let boldTextBuilder = AttributeStringBuilder()
        .set(font: UIFont.font(ofSize: 13, weight: .bold))

    private let regularTextBuilder = AttributeStringBuilder()
        .set(font: UIFont.font(ofSize: 13, weight: .regular))

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHeader()
        self.handler.didLoad()

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
        self.supportLabel.text = L10n.Common.donatePls
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
            if let index = series.day?.index {
                self.weekDayViews[index].isSelected = true
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
    @IBOutlet var titleLabel: UILabel!

    var isSelected: Bool = false {
        didSet {
            if self.isSelected {
                self.backgroundColor = MainTheme.shared.darkRed
                self.titleLabel.textColor = MainTheme.shared.white
                self.borderThickness = 0
            } else {
                self.backgroundColor = .clear
                self.titleLabel.textColor = .lightGray
                self.borderThickness = 1
            }
        }
    }
}
