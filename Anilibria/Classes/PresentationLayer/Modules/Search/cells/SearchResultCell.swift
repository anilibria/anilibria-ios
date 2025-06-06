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
                                placeholder: .imgPlaceholder)
        self.titleLabel.text = item.name?.main
    }

    private func configure(query: String) {
        self.imageView.image = nil
        self.iconView.isHidden = false
        self.iconView.image = .iconGoogle.withRenderingMode(.alwaysTemplate)
        self.titleLabel.text = L10n.Common.GoogleSearch.query(query)
    }

    private func configure() {
        self.imageView.image = nil
        self.iconView.isHidden = false
        self.iconView.image = .System.search.withRenderingMode(.alwaysTemplate)
        self.titleLabel.text = L10n.Common.FilterSearch.title
    }
}
