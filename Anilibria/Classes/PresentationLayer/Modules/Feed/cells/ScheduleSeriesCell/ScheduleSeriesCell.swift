import UIKit

final class ScheduleSeriesCell: RippleViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var releaseIndicatorView: [UIView]!
    

    func configure(_ schedule: ScheduleItem) {

        self.imageView.setImage(
            from: schedule.item.poster,
            placeholder: ScheduleImagePlaceholder(title: schedule.item.name?.main ?? "")
        )
        self.renderIndicator(schedule)
    }

    private func renderIndicator(_ schedule: ScheduleItem) {
        let hasUpdates = schedule.newEpisode != nil
        self.releaseIndicatorView.forEach { $0.isHidden = !hasUpdates }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}

final class ScheduleImagePlaceholder: UIView, ImagePlaceholder {
    private let imageView = UIImageView()

    init(title: String) {
        super.init(frame: .zero)
        setup(title)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup("")
    }

    private func setup(_ title: String) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.constraintEdgesToSuperview()

        let spacer = UIView()
        let titleLabel = InsetsLabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.numberOfLines = 2
        titleLabel.insets = .init(top: 0, left: 8, bottom: 8, right: 8)
        titleLabel.textColor = .Text.main
        titleLabel.text = title
        titleLabel.textAlignment = .center

        spacer.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spacer.heightAnchor.constraint(equalToConstant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 44),
            imageView.heightAnchor.constraint(equalToConstant: 44),
            titleLabel.heightAnchor.constraint(equalToConstant: 44)
        ])

        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)

        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .Text.secondary
        backgroundColor = .Tint.shimmer
    }

    func addTo(view: UIView) {
        self.removeFromSuperview()
        view.addSubview(self)
        self.constraintEdgesToSuperview()
    }

    func removeFrom(view: UIView) {
        self.removeFromSuperview()
    }
}
