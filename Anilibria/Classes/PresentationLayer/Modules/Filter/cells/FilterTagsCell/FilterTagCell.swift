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

    static func size(for item: FilterTag) -> CGSize {
        let height: CGFloat = 38
        let width: CGFloat = self.titleBuilder.build(item.displayValue).width(for: height) + 32
        return CGSize(width: width, height: height)
    }

    private func renderSelect(_ selected: Bool, animated: Bool) {
        func apply() {
            if selected {
                backView.backgroundColor = UIColor(resource: .Buttons.selected)
                titleLabel.textColor = UIColor(resource: .Text.reversedMain)
            } else {
                backView.backgroundColor = UIColor(resource: .Buttons.unselected)
                titleLabel.textColor = UIColor(resource: .Text.main)
            }
        }

        UIView.animate(withDuration: 0.3) {
            apply()
        }
    }
}
