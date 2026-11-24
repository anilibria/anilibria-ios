import UIKit
import Combine

public final class ChoiceCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var separatorView: UIView!

    private var cancellables = Set<AnyCancellable>()

    func configure(_ item: ChoiceItem) {
        cancellables.removeAll()
        self.titleLabel.attributedText = item.title
        self.iconView.isHidden = !item.isSelected
        self.rippleContainerView.smoothCorners(with: 4)

        item.$isSelected.sink(receiveValue: { [weak self] value in
            self?.iconView.isHidden = !value
        }).store(in: &cancellables)

        item.$isLast.sink(receiveValue: { [weak self] value in
            self?.separatorView.isHidden = value
        }).store(in: &cancellables)
    }
}
