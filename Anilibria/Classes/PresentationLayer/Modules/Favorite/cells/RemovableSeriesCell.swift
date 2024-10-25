import UIKit

public final class RemovableSeriesCell: DraggableRippleCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!

    private var deleteHandler: ActionFunc?

    private static let textBuilder: AttributeStringBuilder = AttributeStringBuilder()
        .set(font: .font(ofSize: 13, weight: .regular))
        .set(color: UIColor(resource: .Text.secondary))
        .set(lineBreakMode: .byTruncatingTail)

    public override func awakeFromNib() {
        super.awakeFromNib()
        draggableView.swipeOffset = 100
        containerView.smoothCorners(with: 4)
        containerView.backgroundColor = UIColor(resource: .Surfaces.content)
    }

    func configure(_ item: Series) {
        self.imageView.setImage(from: item.poster,
                                placeholder: UIImage(resource: .imgPlaceholder))
        self.titleLabel.text = item.name?.main ?? ""
        self.descLabel.attributedText = Self.textBuilder.build(item.desc)
    }

    func setDelete(handler: ActionFunc?) {
        self.deleteHandler = handler
    }

    @IBAction func deleteAction(_ sender: Any) {
        self.deleteHandler?()
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }

    public override func callPrimaryAction() {
        self.deleteHandler?()
    }
}
