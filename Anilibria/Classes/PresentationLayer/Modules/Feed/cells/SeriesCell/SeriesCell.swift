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
        let name = item.name?.main ?? ""
        if item.episodesTotal == 0 {
            self.titleLabel.text = name
        } else {
            self.titleLabel.text = "\(name) (\(item.episodesTotal))"
        }
        self.descLabel.attributedText = Self.textBuilder.build(item.desc)
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
