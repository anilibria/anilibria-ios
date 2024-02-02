import UIKit

public final class FilterTagCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backView: UIView!

    private var bag: Any?
    private static let titleBuilder: AttributeStringBuilder = AttributeStringBuilder()
        .set(font: UIFont.font(ofSize: 15, weight: .regular))

    func configure(_ item: FilterTag) {
        self.backView.backgroundColor = item.isSelected ? #colorLiteral(red: 0.707420184, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.9247149825, green: 0.9219169021, blue: 0.9385299683, alpha: 1)
        self.titleLabel.textColor = item.isSelected ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.titleLabel.text = item.displayValue
        self.subscribe(item)
    }

    private func subscribe(_ item: FilterTag) {
        self.bag = item.observe(\FilterTag.isSelected) { [weak self] _,_ in
            self?.renderSelect(item)
        }
    }

    static func size(for item: FilterTag) -> CGSize {
        let height: CGFloat = 38
        let width: CGFloat = self.titleBuilder.build(item.displayValue).width(for: height) + 32
        return CGSize(width: width, height: height)
    }

    private func renderSelect(_ item: FilterTag) {
        UIView.animate(withDuration: 0.3) {
            self.backView.backgroundColor = item.isSelected ? #colorLiteral(red: 0.707420184, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.9247149825, green: 0.9219169021, blue: 0.9385299683, alpha: 1)
            self.titleLabel.textColor = item.isSelected ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}
