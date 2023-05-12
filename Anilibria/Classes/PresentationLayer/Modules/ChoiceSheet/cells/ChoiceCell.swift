import UIKit
import Combine

public final class ChoiceCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var separatorView: UIView!
    
    private var cancellable: AnyCancellable?

    func configure(_ item: ChoiceItem) {
        self.titleLabel.text = item.title
        self.iconView.isHidden = !item.isSelected
        self.separatorView.isHidden = item.isLast
        
        self.cancellable = item.$isSelected.sink(receiveValue: { [weak self] value in
            self?.iconView.isHidden = !value
        })
    }
}
