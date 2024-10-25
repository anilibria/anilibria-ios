import UIKit

public final class SeriesCell: RippleViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!

    private static let textBuilder: AttributeStringBuilder = AttributeStringBuilder()
        .set(font: .font(ofSize: 13, weight: .regular))
        .set(color: UIColor(resource: .Text.secondary))
        .set(lineBreakMode: .byTruncatingTail)

    public override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .font(ofSize: 14, weight: .bold)
        titleLabel.textColor = UIColor(resource: .Text.main)
        containerView.smoothCorners(with: 4)
        containerView.backgroundColor = UIColor(resource: .Surfaces.content)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.cancelDownloadTask()
    }

    func configure(_ item: Series) {
        self.imageView.setImage(from: item.poster,
                                placeholder: UIImage(resource: .imgPlaceholder))
        self.titleLabel.text = item.name?.main ?? ""
        self.descLabel.attributedText = Self.textBuilder.build(item.desc)
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
