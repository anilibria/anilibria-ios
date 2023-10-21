//
//  RefreshIndicator.swift
//  SpringIndicator
//
//  Created by Kyohei Ito on 2017/09/22.
//  Copyright © 2017年 kyohei_ito. All rights reserved.
//

import UIKit

public class RefreshIndicator: UIControl {
    deinit {
        stopIndicatorAnimation()
    }
    
    private let defaultContentHeight: CGFloat = 60
    private var refreshContext = UInt8()
    private var initialInsetTop: CGFloat = 0
    private weak var target: AnyObject?
    private var targetView: UIScrollView? {
        willSet {
            removeObserver()
        }
        didSet {
            addObserver()
        }
    }
    
    public var shift: CGFloat = 0
    public let indicator = SpringIndicator(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    public private(set) var isRefreshing: Bool = false
    private var isSpinning: Bool = false
    
    public convenience init(style: UIBlurEffect.Style) {
        self.init(frame: CGRect.zero)
        setupBlurBack(style: style)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupIndicator()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupIndicator()
    }
    
    private func setupIndicator() {
        indicator.lineWidth = 2
        indicator.rotationDuration = 1
        indicator.alpha = 0
        indicator.center = center
        indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        addSubview(indicator)
        self.layer.zPosition = CGFloat.greatestFiniteMagnitude
    }
    
    private func setupBlurBack(style: UIBlurEffect.Style) {
        let back: UIView!
        if #available(iOS 10.0, *) {
            back = UIVisualEffectView(effect: UIBlurEffect(style: style))
        } else {
            back = UIView()
            back.backgroundColor = .white
        }
        
        back.frame = CGRect(x: -8, y: -8, width: 36, height: 36)
        back.layer.cornerRadius = 18
        back.layer.masksToBounds = true
        back.layer.zPosition = -1
        indicator.insertSubview(back, at: 0)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
        
        if let scrollView = superview as? UIScrollView {
            autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            frame.size.height = defaultContentHeight
            frame.size.width = scrollView.bounds.width
            center.x = scrollView.center.x
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView!) {
        super.willMove(toSuperview: newSuperview)
        
        targetView = newSuperview as? UIScrollView
        
        if let scrollView = targetView {
            initialInsetTop = scrollView.contentInset.top
        }
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        layoutIfNeeded()
    }
    
    open override func removeFromSuperview() {
        if targetView == superview {
            targetView = nil
        }
        super.removeFromSuperview()
    }
    
    open override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        super.addTarget(target, action: action, for: controlEvents)
        
        self.target = target as AnyObject?
    }
    
    open override func removeTarget(_ target: Any?, action: Selector?, for controlEvents: UIControl.Event) {
        super.removeTarget(target, action: action, for: controlEvents)
        
        self.target = nil
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = object as? UIScrollView, context == &refreshContext else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
        if target == nil {
            targetView = nil
            return
        }
        
        if bounds.height <= 0 {
            return
        }
        
        if superview == scrollView {
            frame.origin.y = scrollView.contentOffset.y + shift
        }
        
        if isSpinning {
            if isRefreshing == false {
                indicator.stop()
                isSpinning = false
            }
            return
        }
        
        if isRefreshing && scrollView.isDragging == false && scrollView.isScrollEnabled {
            beginRefreshing()
            return
        }
        
        let ratio = scrollRatio(scrollView)
        if scrollView.isDragging {
            isRefreshing = ratio >= 1
        }
        if scrollView.isDecelerating || scrollView.isTracking {
            indicator.alpha = ratio
            indicator.strokeRatio(ratio)
            rotationRatio(ratio)
        }
    }
    
    private func addObserver() {
        targetView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &refreshContext)
    }
    
    private func removeObserver() {
        targetView?.removeObserver(self, forKeyPath: "contentOffset", context: &refreshContext)
    }
    
    private func withoutObserve(_ block: (() -> Void)) {
        removeObserver()
        block()
        addObserver()
    }
    
    private func scrollOffset(_ scrollView: UIScrollView) -> CGFloat {
        var offsetY = scrollView.contentOffset.y
        if #available(iOS 11.0, tvOS 11.0, *) {
            offsetY += initialInsetTop + scrollView.safeAreaInsets.top
        } else {
            offsetY += initialInsetTop
        }
        
        return offsetY
    }
    
    private func scrollRatio(_ scrollView: UIScrollView) -> CGFloat {
        var offsetY = scrollOffset(scrollView) + self.shift
        
        offsetY += frame.size.height - indicator.frame.size.height
        if offsetY > 0 {
            offsetY = 0
        }
        
        return abs(offsetY / bounds.height)
    }
    
    private func rotationRatio(_ ratio: CGFloat) {
        let value = max(min(ratio, 1), 0)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        indicator.indicatorView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi - Double.pi_4) * value, 0, 0, 1)
        CATransaction.commit()
    }
}

// MARK: - Refresh
extension RefreshIndicator {
    // MARK: begin
    private func beginRefreshing() {
        isSpinning = true
        indicator.layer.add(beginAnimation(), for: .scale)
        startIndicatorAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.isSpinning && self.isRefreshing {
                self.sendActions(for: .valueChanged)
            }
        }
    }
    
    // MARK:
    public func startRefreshing() {
        indicator.layer.add(beginAnimation(), for: .scale)
        isRefreshing = true
        isSpinning = true
        startIndicatorAnimation()
        UIView.animate(withDuration: 0.2) {
            self.indicator.alpha = 1
        }
    }
    
    // MARK: end
    /// Must be explicitly called when the refreshing has completed
    public func endRefreshing() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.indicator.alpha = 0
            }, completion: { [weak self] _ in
                self?.indicator.stop()
                self?.isRefreshing = false
                self?.isSpinning = false
        })
    }
}

// MARK: - Animation
extension RefreshIndicator {
    // MARK: for Begin
    private func beginAnimation() -> CAPropertyAnimation {
        let anim = CABasicAnimation(key: .scale)
        anim.duration = 0.1
        anim.repeatCount = 1
        anim.autoreverses = true
        anim.fromValue = 1
        anim.toValue = 1.3
        anim.timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        return anim
    }
    
    // MARK: for End
    private func endAnimation() -> CAPropertyAnimation {
        let anim = CABasicAnimation(key: .scale)
        anim.duration = 0.3
        anim.repeatCount = 1
        anim.fromValue = 1
        anim.toValue = 0
        anim.timingFunction = CAMediaTimingFunction(name: .easeIn)
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        
        return anim
    }
}
