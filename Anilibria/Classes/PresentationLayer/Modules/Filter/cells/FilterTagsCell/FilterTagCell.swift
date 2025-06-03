import UIKit

public final class FilterTagCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backView: UIView!

    private var bag: Any?
    private static let titleBuilder: AttributeStringBuilder = AttributeStringBuilder()
        .set(font: UIFont.font(ofSize: 15, weight: .regular))

    func configure(_ item: FilterTag) {
        renderSelect(item.isSelected, animated: false)
        self.titleLabel.text = item.displayValue
        self.subscribe(item)
    }

    private func subscribe(_ item: FilterTag) {
        self.bag = item.value.isSelected.dropFirst().sink { [weak self] value in
            self?.renderSelect(value, animated: true)
        }
    }

    private func renderSelect(_ selected: Bool, animated: Bool) {
        func apply() {
            if selected {
                backView.backgroundColor = UIColor(resource: .Buttons.selected)
                titleLabel.textColor = UIColor(resource: .Text.monoLight)
            } else {
                backView.backgroundColor = UIColor(resource: .Buttons.unselected)
                titleLabel.textColor = UIColor(resource: .Text.main)
            }
        }

        if animated {
            UIView.animate(withDuration: 0.3) {
                apply()
            }
        } else {
            apply()
        }
    }
}
