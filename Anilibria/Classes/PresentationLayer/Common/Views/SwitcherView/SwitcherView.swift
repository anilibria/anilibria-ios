import RxSwift
import UIKit

public final class SwitcherView: LoadableView {
    @IBOutlet var titleLabels: [UILabel] = []
    @IBOutlet var leftButton: RippleButton!
    @IBOutlet var leftArrowView: UIView!
    @IBOutlet var rightButton: RippleButton!
    @IBOutlet var rightArrowView: UIView!

    private let duration: Double = 0.3
    private var tapHandler: Action<Int>?
    private var canMoveLeft: Bool = true
    private var canMoveRight: Bool = true

    private let selectedRelay: BehaviorSubject<Int> = .init(value: 0)
    private(set) var currentIndex: Int = 0 {
        didSet {
            self.selectedRelay.onNext(self.currentIndex)
        }
    }

    private var items: [Any] = []
    private var titleFactory: ActionIO<Any,String>?

    public func set<T>(items: [T], index: Int, title factory: @escaping ActionIO<T,String>) {
        self.titleFactory = { item in
            if let value = item as? T {
                return factory(value)
            }
            return ""
        }

        self.items = items
        self.set(current: index)
    }

    public func didTapTitle(handler: Action<Int>?) {
        self.tapHandler = handler
    }

    public func set(current index: Int) {
        self.currentIndex = index
        self.inittialState()
    }

    public func getSelectedSequence() -> Observable<Int> {
        return self.selectedRelay
    }

    public override func setupNib() {
        super.setupNib()
        self.inittialState()
    }

    private func currentTitles(for index: Int) -> [String] {
        let count = self.items.count
        var result: [String] = []

        let previous = index - 1
        let next = index + 1

        if previous < 0 {
            result.append("")
        } else {
            let title = self.titleFactory?(self.items[previous]) ?? ""
            result.append(title)
        }

        if index < count && index >= 0 {
            let title = self.titleFactory?(self.items[index]) ?? ""
            result.append(title)
        } else {
            result.append("")
        }

        if next >= count {
            result.append("")
        } else {
            let title = self.titleFactory?(self.items[next]) ?? ""
            result.append(title)
        }

        return result
    }

    private func title(next: Bool, for index: Int) -> String {
        let count = self.items.count
        let direction: Int = next ? 1 : -1

        let actual = index + 2 * direction

        if actual < count && actual >= 0 {
            let title = self.titleFactory?(self.items[actual]) ?? ""
            return title
        }

        return ""
    }

    private func inittialState() {
        let titles = self.currentTitles(for: self.currentIndex)

        self.titleLabels[1].text = titles[0]
        self.titleLabels[2].text = titles[1]
        self.titleLabels[3].text = titles[2]

        self.titleLabels[0].alpha = 0
        self.titleLabels[1].alpha = 0.3
        self.titleLabels[2].alpha = 1
        self.titleLabels[3].alpha = 0.3

        self.titleLabels[1].transform = .identity
        self.titleLabels[2].transform = .identity
        self.titleLabels[3].transform = .identity

        let animate = { value in
            UIView.animate(withDuration: 0.2, animations: value)
        }

        if titles[0].isEmpty {
            self.canMoveLeft = false
            animate { self.leftArrowView.alpha = 0 }
        } else {
            self.canMoveLeft = true
            animate { self.leftArrowView.alpha = 1 }
        }

        if titles[2].isEmpty {
            self.canMoveRight = false
            animate { self.rightArrowView.alpha = 0 }
        } else {
            self.canMoveRight = true
            animate { self.rightArrowView.alpha = 1 }
        }
    }

    private func move(next: Bool) {
        let direction: CGFloat = next ? 1 : -1
        let title = self.title(next: next, for: self.currentIndex)

        self.titleLabels[0].transform = CGAffineTransform(translationX: direction * 160, y: 0)
        self.titleLabels[0].alpha = 0
        self.titleLabels[0].text = title
        self.canMoveLeft = false
        self.canMoveRight = false

        let points: CGFloat = 80 * direction

        UIView.animate(withDuration: self.duration,
                       animations: {
                           self.titleLabels[0].transform = CGAffineTransform(translationX: points, y: 0)
                           self.titleLabels[0].alpha = 0.3

                           self.titleLabels[1].alpha = (1 - direction) / 2
                           self.titleLabels[2].alpha = 0.3
                           self.titleLabels[3].alpha = 1 - (1 - direction) / 2

                           self.titleLabels[1].transform = CGAffineTransform(translationX: -points, y: 0)
                           self.titleLabels[2].transform = CGAffineTransform(translationX: -points, y: 0)
                           self.titleLabels[3].transform = CGAffineTransform(translationX: -points, y: 0)

                       }, completion: { _ in
                           self.currentIndex += Int(direction)
                           self.inittialState()
        })
    }

    private func moveLeft() {
        if self.canMoveLeft {
            self.move(next: false)
        }
    }

    private func moveRight() {
        if self.canMoveRight {
            self.move(next: true)
        }
    }

    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            self.moveRight()
        } else if sender.direction == .right {
            self.moveLeft()
        }
    }

    @IBAction func previosTapped(_ sender: Any) {
        self.moveLeft()
    }

    @IBAction func nextTapped(_ sender: Any) {
        self.moveRight()
    }

    @IBAction func titleTapped(_ sender: Any) {
        self.tapHandler?(self.currentIndex)
    }
}
