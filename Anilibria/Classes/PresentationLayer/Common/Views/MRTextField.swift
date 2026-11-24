import UIKit
import Combine

public class MRTextField: UITextField {
    var nonActiveAlpha: CGFloat = 0.3
    @IBOutlet var targetView: UIView? {
        didSet {
            self.targetView?.alpha = self.nonActiveAlpha
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    fileprivate func setup() {
        addTarget(self, action: #selector(begin), for: .editingDidBegin)
        addTarget(self, action: #selector(end), for: .editingDidEnd)
        addTarget(self, action: #selector(resignFirstResponder), for: .editingDidEndOnExit)
    }

    @objc private func begin() {
        UIView.animate(withDuration: 0.2) {
            self.targetView?.alpha = 1
        }
    }

    @objc private func end() {
        UIView.animate(withDuration: 0.2) {
            self.targetView?.alpha = self.nonActiveAlpha
        }
    }
}

// Workaround to avoid keyboard hangs
public class SecureTextField: MRTextField, UITextFieldDelegate {
    @Published private(set) var secureText: String = ""
    private let secureChar: String = "•"
    private var cancellable: AnyCancellable?

    override func setup() {
        super.setup()
        self.delegate = self

        cancellable = textPublisher.sink { [weak self] text in
            guard let self else { return }
            if secureText.isEmpty, text?.isEmpty == false {
                secureText = text ?? ""
                self.text = String(repeating: secureChar, count: secureText.count)
            }
        }
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) ||
           action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

    public override func replace(_ range: UITextRange, withText text: String) {
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        let nsrange = NSRange(location: location, length: length)
        if let range = Range(nsrange, in: secureText) {
            secureText = secureText.replacingCharacters(in: range, with: text)
        }
        super.replace(range, withText: text)
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.starts(with: "\n") {
            textField.resignFirstResponder()
            return false
        }

        if let range = Range(range, in: secureText) {
            secureText = secureText.replacingCharacters(in: range, with: string)
        }

        textField.text = String(repeating: secureChar, count: secureText.count)

        if let newPosition = textField.position(
            from: textField.beginningOfDocument,
            offset: range.location + string.utf16.count
        ) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        return false
    }
}
