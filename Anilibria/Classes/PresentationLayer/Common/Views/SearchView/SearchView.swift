import RxCocoa
import RxSwift
import UIKit

public final class SearchView: UIView {
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var searchField: UITextField! {
        didSet {
            self.layer.zPosition = CGFloat.greatestFiniteMagnitude
            self.setupSearchField()
        }
    }

    private let bag: DisposeBag = DisposeBag()
    private let queryRelay: PublishRelay<String> = PublishRelay()

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
        self.searchField.rx.text
            .orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.queryRelay.accept(text)
                self?.cancelIsHidden = text.isEmpty
                self?.isSearching = !text.isEmpty
            })
            .disposed(by: self.bag)
    }

    public private(set) var isSearching: Bool = false

    func querySequence() -> Observable<String> {
        return self.queryRelay.asObservable()
            .distinctUntilChanged()
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
        self.queryRelay.accept("")
    }

    public override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}
