import UIKit
import Combine

final class SoonCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var segmentControl: UISegmentedControl!

    private var cancellables: Set<AnyCancellable> = []

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = L10n.Screen.Feed.schedule
        rippleContainerView?.smoothCorners(with: 8)
        segmentControl.setTitleTextAttributes([
            .foregroundColor: UIColor.Text.monoLight,
        ], for: .selected)
        segmentControl.setTitleTextAttributes([
            .foregroundColor: UIColor.Text.main,
        ], for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    func configure(_ model: SoonViewModel) {
        updateSegments(model)
        Language.languageChanged.sink { [weak self, weak model] in
            guard let model else { return }
            self?.updateSegments(model)
            self?.titleLabel.text = L10n.Screen.Feed.schedule
        }.store(in: &cancellables)

        segmentControl.publisher(for: .valueChanged).sink { [weak model, segmentControl] _ in
            guard let segmentControl else { return }
            model?.select(index: segmentControl.selectedSegmentIndex)
        }.store(in: &cancellables)
    }

    private func updateSegments(_ model: SoonViewModel) {
        segmentControl.removeAllSegments()
        model.days.enumerated().forEach { offset, day in
            segmentControl.insertSegment(withTitle: day.title, at: offset, animated: false)
        }
        if let index = model.days.firstIndex(of: model.selectedDay.value) {
            segmentControl.selectedSegmentIndex = index
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}

private extension ShortSchedule.Day {
    var title: String {
        switch self {
        case .tomorrow: L10n.Common.tomorrow
        case .today: L10n.Common.today
        case .yesterday: L10n.Common.yesterday
        }
    }
}
