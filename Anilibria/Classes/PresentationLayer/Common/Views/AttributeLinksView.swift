import UIKit

final class AttributeLinksView: UITextView {
    private var tapHandler: Action<URL>?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textDragInteraction?.isEnabled = false
        self.delegate = self
    }

    public func setTapLink(handler: Action<URL>?) {
        self.tapHandler = handler
    }
}

extension AttributeLinksView: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        if interaction != .invokeDefaultAction {
            return false
        }

        self.tapHandler?(URL)
        return false
    }
}
