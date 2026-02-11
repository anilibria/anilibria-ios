import Combine
import UIKit

public final class SearchView: LoadableView {
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var searchField: UITextField! {
        didSet {
            self.layer.zPosition = 1000
            self.setupSearchField()
        }
    }

    public private(set) var isSearching: Bool = false
    public var text: String { self.searchField.text ?? "" }

    private var bag = Set<AnyCancellable>()
    private let queryRelay = PassthroughSubject<String, Never>()

    private var cancelIsHidden: Bool = true {
        didSet {
            if self.cancelIsHidden != oldValue {
                UIView.animate(withDuration: 0.3) {
                    self.cancelButton.alpha = self.cancelIsHidden ? 0 : 1
                }
            }
        }
    }

    private func setupSearchField() {
        self.searchField.placeholder = L10n.Common.Search.byName
        self.searchField.textPublisher.map { $0 ?? "" }
            .sink(onNext: { [weak self] text in
                self?.queryRelay.send(text)
                self?.cancelIsHidden = text.isEmpty
                self?.isSearching = !text.isEmpty
            })
            .store(in: &bag)
        self.searchField.publisher(for: .primaryActionTriggered).sink { [weak self] _ in
            self?.searchField.resignFirstResponder()
        }
        .store(in: &bag)
    }


    func querySequence() -> AnyPublisher<String, Never> {
        return self.queryRelay.removeDuplicates().eraseToAnyPublisher()
    }

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        self.searchField.resignFirstResponder()
        return super.resignFirstResponder()
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.searchField.resignFirstResponder()
        self.isSearching = false
        self.searchField.text = ""
        self.queryRelay.send("")
        self.cancelIsHidden = true
    }

    public override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}
