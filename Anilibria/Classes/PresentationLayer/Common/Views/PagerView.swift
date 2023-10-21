//
//  PagerView.swift
//
//  Created by Ivan Morozov on 04.05.2021.
//

import UIKit

public typealias PageDirection = UIPageViewController.NavigationDirection

public protocol PagerViewDelegate: AnyObject {
    func numberOfPages(for pagerView: PagerView) -> Int
    func pagerView(_ pagerView: PagerView, pageFor index: Int) -> UIViewController?
    func pagerView(_ pagerView: PagerView, willTransitionTo index: Int)
    func pagerView(_ pagerView: PagerView, didTransitionTo index: Int)
}

public extension PagerViewDelegate {
    func pagerView(_ pagerView: PagerView, willTransitionTo index: Int) {}
    func pagerView(_ pagerView: PagerView, didTransitionTo index: Int) {}
}

open class PagerView: UIView {
    @IBOutlet private weak var rootController: UIViewController? {
        didSet {
            rootController?.addChild(pageController)
            pageController.didMove(toParent: rootController)
        }
    }

    public weak var delegate: PagerViewDelegate?

    private var indexes = NSMapTable<UIViewController, NSNumber>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    private var indexHandler: ((Int) -> Void)?
    private var interPageSpacing: CGFloat = 0.0
    private weak var activeScrollView: UIScrollView?
    private var delayedScroll: (() -> Void)?

    public private(set) lazy var pageController: UIPageViewController = {
        let controller = PageViewController(transitionStyle: .scroll,
                                            navigationOrientation: .horizontal,
                                            options: [.interPageSpacing: interPageSpacing])
        controller.dataSource = self
        controller.delegate = self
        controller.scrollDelegate = self
        self.addSubview(controller.view)
        controller.view.constraintEdgesToSuperview()
        return controller
    }()
    
    private var nextIndex: Int = -1 {
        didSet {
            if nextIndex != oldValue {
                delegate?.pagerView(self, willTransitionTo: nextIndex)
            }
        }
    }
    
    public private(set) var currentIndex: Int = -1 {
        didSet {
            if currentIndex != oldValue {
                indexHandler?(currentIndex)
                delegate?.pagerView(self, didTransitionTo: currentIndex)
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

    public init(rootController: UIViewController?, interPageSpacing: CGFloat = 0.0) {
        self.interPageSpacing = interPageSpacing
        super.init(frame: .zero)
        defer { self.rootController = rootController }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        
        if activeScrollView?.isDecelerating == true {
            delayedScroll = { [weak self] in
                self?.scrollTo(index: index,
                               direction: direction,
                               animated: animated,
                               completionHandler: completionHandler)
            }
            return
        }
        
        nextIndex = index

        if isScrollEnabled {
            // to cancel user touch interactions
            isScrollEnabled = false
            isScrollEnabled = true
        }
        let direction = direction ?? (currentIndex < index ? .forward : .reverse)

        setIndex(index, for: controller)
        
        pageController.setViewControllers([controller],
                                          direction: direction,
                                          animated: false)
        if animated { transition(direction: direction) }
        currentIndex = index
        completionHandler?()
    }
    
    func transition(direction: PageDirection)  {
        let transition = CATransition()
        transition.type = .push
        transition.subtype =  direction == .forward ? .fromRight : .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.fillMode = .forwards
        transition.duration = 0.2
        pageController.view.layer.add(transition, forKey: "trsansition")
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
            nextIndex = index
        }
    }
}

extension PagerView: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        activeScrollView = scrollView
    }
    
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !scrollView.isTracking { return }
        
        let result = extractController(
            for: targetContentOffset.pointee,
            with: scrollView
        )
        
        if let index = index(of: result) {
            nextIndex = index
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let result = extractController(
            for: scrollView.contentOffset,
            with: scrollView
        )
        
        if let index = index(of: result) {
            currentIndex = index
        }
        
        delayedScroll?()
        delayedScroll = nil
    }
    
    private func extractController(for point: CGPoint,
                                   with scrollView: UIScrollView) -> UIViewController? {
        return pageController
            .children
            .first(where: {
                let origin = $0.view.superview?.convert($0.view.frame.origin, to: scrollView)
                if let x = origin?.x {
                    return abs(x - point.x) <= interPageSpacing
                }
                return false
            })
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
