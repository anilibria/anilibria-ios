import UIKit

public final class SearchResultCell: RippleViewCell {
    @IBOutlet var backView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    func configure(_ item: SearchValue) {
        switch item {
        case let .series(value):
            self.configure(item: value)
        case let .google(query):
            self.configure(query: query)
        case .filter:
            self.configure()
        }
    }

    private func configure(item: Series) {
        self.iconView.isHidden = true
        self.imageView.setImage(from: item.poster,
                                placeholder: UIImage(resource: .imgPlaceholder))
        self.titleLabel.text = item.names.first
    }

    private func configure(query: String) {
        self.imageView.image = nil
        self.iconView.isHidden = false
        self.iconView.image = UIImage(resource: .iconGoogle)
        self.titleLabel.text = L10n.Common.GoogleSearch.query(query)
    }

    private func configure() {
        self.imageView.image = nil
        self.iconView.isHidden = false
        self.iconView.image = UIImage(resource: .menuItemSearch)
        self.titleLabel.text = L10n.Common.FilterSearch.title
    }
}
