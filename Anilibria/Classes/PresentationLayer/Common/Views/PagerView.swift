import UIKit

public typealias PageDirection = UIPageViewController.NavigationDirection

public final class PagerView: UIView {
    public var loopEnabled: Bool = false

    private var pageControllers: [UIViewController] = []
    private var indexHandler: Action<Int?>?
    private lazy var pageController: UIPageViewController = UIPageViewController(transitionStyle: .scroll,
                                                                                 navigationOrientation: .horizontal,
                                                                                 options: nil)
        .apply {
        $0.delegate = self
        self.addSubview($0.view)
    }

    private(set) var currentIndex: Int? {
        didSet {
            if self.currentIndex != oldValue {
                self.indexHandler?(self.currentIndex)
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }

    private func setupNib() {
        self.pageController.view.pinToParent()
    }

    func set(controllers: [UIViewController]) {
        self.pageControllers = controllers
        if controllers.count > 1 {
            self.pageController.dataSource = self
        }
    }

    func didIndexChanged(_ handler: @escaping Action<Int?>) {
        self.indexHandler = handler
    }

    func scrollTo(index: Int, direction: PageDirection, animated: Bool) {
        if index < 0 || index >= self.pageControllers.count {
            return
        }
        let controller = self.pageControllers[index]
        self.currentIndex = index
        self.pageController.setViewControllers([controller],
                                               direction: direction,
                                               animated: animated)
    }

    func require(gesture: UIScreenEdgePanGestureRecognizer?) {
        if gesture == nil { return }
        let result = self.findSubviewOfClass(anyClass: UIScrollView.self, inView: self)

        guard let subscrollviews = result as? [UIScrollView] else {
            return
        }

        for subscrollview in subscrollviews {
            subscrollview.panGestureRecognizer.require(toFail: gesture!)
        }
    }

    private func findSubviewOfClass(anyClass: AnyClass, inView view: UIView) -> [UIView] {
        var subviewsOfClass: [UIView] = []

        if view.responds(to: #selector(getter: UIView.subviews)) {
            for subview in view.subviews {
                if subview.isKind(of: anyClass) {
                    subviewsOfClass.append(subview)
                }

                let subsubviewOfClass = self.findSubviewOfClass(anyClass: anyClass, inView: subview)
                subviewsOfClass.append(contentsOf: subsubviewOfClass)
            }
        }

        return subviewsOfClass
    }
}

extension PagerView: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pageControllers.firstIndex(of: viewController) else {
            return nil
        }

        let beforeIndex = index - 1

        if beforeIndex >= 0 {
            return self.pageControllers[beforeIndex]
        }

        if self.loopEnabled {
            return self.pageControllers.last
        }

        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pageControllers.firstIndex(of: viewController) else {
            return nil
        }

        let afterIndex = index + 1

        if afterIndex < self.pageControllers.count {
            return self.pageControllers[afterIndex]
        }

        if self.loopEnabled {
            return self.pageControllers.first
        }

        return nil
    }
}

extension PagerView: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        if completed,
            let presentedController = pageViewController.viewControllers?.first,
            let index = pageControllers.firstIndex(of: presentedController) {
            self.currentIndex = index
        }
    }
}
