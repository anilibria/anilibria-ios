//
//  PagerView.swift
//
//  Created by Ivan Morozov on 04.05.2021.
//  Copyright © 2021 Whisk. All rights reserved.
//

import UIKit

public typealias PageDirection = UIPageViewController.NavigationDirection

public protocol PagerViewDelegate: AnyObject {
    func numberOfPages(for pagerView: PagerView) -> Int
    func pagerView(_ pagerView: PagerView, pageFor index: Int) -> UIViewController?
    func pagerView(_ pagerView: PagerView, willTransitionTo index: Int)
    func firstPage(_ pagerView: PagerView) -> UIViewController?
    func lastPage(_ pagerView: PagerView) -> UIViewController?
}

public extension PagerViewDelegate {
    func pagerView(_ pagerView: PagerView, willTransitionTo index: Int) {}
    func firstPage(_ pagerView: PagerView) -> UIViewController? { nil }
    func lastPage(_ pagerView: PagerView) -> UIViewController? { nil }
}

open class PagerView: UIView {
    @IBOutlet private weak var rootController: UIViewController? {
        didSet {
            rootController?.addChild(pageController)
            pageController.didMove(toParent: rootController)
        }
    }

    public var loopEnabled: Bool = false
    public weak var delegate: PagerViewDelegate?

    private var indexes = NSMapTable<UIViewController, NSNumber>(keyOptions: .weakMemory, valueOptions: .strongMemory)

    private var indexHandler: ((Int) -> Void)?

    public private(set) lazy var pageController: UIPageViewController = {
        let controller = PageViewController(transitionStyle: .scroll,
                                            navigationOrientation: .horizontal,
                                            options: nil)
        controller.dataSource = self
        controller.delegate = self
        controller.scrollDelegate = self
        self.addSubview(controller.view)
        return controller
    }()

    public private(set) var currentIndex: Int = -1 {
        didSet {
            if currentIndex != oldValue {
                indexHandler?(currentIndex)
            }
        }
    }

    public var currentViewController: UIViewController? {
        if currentIndex < 0 { return nil }
        return delegate?.pagerView(self, pageFor: currentIndex)
    }

    public var isScrollEnabled: Bool {
        get {
            var isEnabled: Bool = true
            pageController.view.subviews.forEach {
                if let subView = $0 as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            pageController.view.subviews.forEach {
                if let subview = $0 as? UIScrollView {
                    subview.isScrollEnabled = newValue
                }
            }
        }
    }

    public init(rootController: UIViewController?) {
        defer {
            self.rootController = rootController
            self.setup()
        }
        super.init(frame: .zero)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    private func setup() {
        pageController.view.constraintEdgesToSuperview()
       // requireGesture()
    }

    open func didIndexChanged(_ handler: @escaping (Int) -> Void) {
        self.indexHandler = handler
    }

    open func scrollTo(index: Int, direction: PageDirection? = nil, animated: Bool, completionHandler: (() -> Void)? = nil) {
        guard
            let delegate = delegate,
            0..<delegate.numberOfPages(for: self) ~= index,
            let controller = delegate.pagerView(self, pageFor: index),
            currentIndex != index
        else {
            return
        }

        let direction = direction ?? (currentIndex < index ? .forward : .reverse)

        setIndex(index, for: controller)

        DispatchQueue.main.async { [weak self, weak pageController] in
            pageController?.setViewControllers([controller],
                                               direction: direction,
                                               animated: animated) { _ in
                self?.currentIndex = index
                completionHandler?()
            }
        }
    }

    private func requireGesture() {
        let gesture = rootController?.navigationController?.view
            .gestureRecognizers?
            .first { $0 is UIScreenEdgePanGestureRecognizer } as? UIScreenEdgePanGestureRecognizer
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
        guard let index = index(of: viewController) else {
            return nil
        }

        let previousIndex = index - 1

        if previousIndex >= 0 {
            let controller = delegate?.pagerView(self, pageFor: previousIndex)
            setIndex(previousIndex, for: controller)
            return controller
        }

        if self.loopEnabled {
            return delegate?.lastPage(self)
        }

        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = index(of: viewController) else {
            return nil
        }

        let nextIndex = index + 1
        let count = delegate?.numberOfPages(for: self) ?? -1

        if nextIndex < count {
            let controller = delegate?.pagerView(self, pageFor: nextIndex)
            setIndex(nextIndex, for: controller)
            return controller
        }

        if self.loopEnabled {
            return delegate?.firstPage(self)
        }

        return nil
    }

    private func index(of viewController: UIViewController?) -> Int? {
        indexes.object(forKey: viewController)?.intValue
    }

    private func setIndex(_ index: Int, for viewController: UIViewController?) {
        indexes.setObject(NSNumber(value: index), forKey: viewController)
    }
}

extension PagerView: UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   willTransitionTo pendingViewControllers: [UIViewController]) {
        if let index = index(of: pendingViewControllers.first) {
            delegate?.pagerView(self, willTransitionTo: index)
        }
    }
}

extension PagerView: UIScrollViewDelegate {

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let result = pageController.children.compactMap { controller -> (position: CGFloat, controller: UIViewController?)? in
            guard let position = controller.view.superview?.convert(controller.view.center, to: self).x else {
                return nil
            }
            return (abs(position - self.center.x), controller)
        }
        .min(by: { first, second in first.position < second.position })

        if let index = index(of: result?.controller) {
            currentIndex = index
        }
    }
}

private final class PageViewController: UIPageViewController {

    public weak var scrollDelegate: UIScrollViewDelegate?

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let gesture = navigationController?.interactivePopGestureRecognizer
        view.subviews.forEach {
            guard let scrollView = $0 as? UIScrollView else { return }
            scrollView.delegate = scrollDelegate
            if let gesture = gesture {
                scrollView.gestureRecognizers?.forEach {
                    $0.require(toFail: gesture)
                }
            }
        }
    }
}
