import UIKit

public final class SeriesCell: RippleViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!

    private static let textBuilder: AttributeStringBuilder = AttributeStringBuilder()
        .set(font: .font(ofSize: 13, weight: .regular))
        .set(color: .darkGray)
        .set(lineBreakMode: .byTruncatingTail)
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.cancelDownloadTask()
    }

    func configure(_ item: Series) {
        self.imageView.setImage(from: item.poster,
                                placeholder: UIImage(resource: .imgPlaceholder))
        let name = item.names.first ?? ""
        if item.count.isEmpty {
            self.titleLabel.text = name
        } else {
            self.titleLabel.text = "\(name) (\(item.count))"
        }
        if let value = item.desc {
            self.descLabel.attributedText = Self.textBuilder.build(value.string)
        } else {
            self.descLabel.text = ""
        }
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
