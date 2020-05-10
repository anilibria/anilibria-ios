import UIKit

public class DraggableRippleCell: RippleViewCell {
    @IBOutlet var draggableView: DraggableView!

    public override func prepareForReuse() {
        super.prepareForReuse()
        self.draggableView.close()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.draggableView.delegate = self
    }
}

extension DraggableRippleCell: DraggableViewDelegate {
    public func didStart() {}

    public func progressChanged(value: CGFloat) {}

    public func didEnd(_ isOpen: Bool) {}
}
