import UIKit

public class DraggableRippleCell: RippleViewCell, DraggableViewDelegate {
    @IBOutlet var draggableView: DraggableView!

    public override func prepareForReuse() {
        super.prepareForReuse()
        self.draggableView.close()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.draggableView.delegate = self
    }

    public func willCallPrimaryAction() {}
    public func callPrimaryAction() {}
    public func cancelCallPrimaryAction() {}
}
