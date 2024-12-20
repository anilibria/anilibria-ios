//
//  ShimmerView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 21.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public final class ShimmerView: UIView {
    private static let now = CACurrentMediaTime()
    private let gradientView = GradientView()

    public var duration: Double = 2 {
        didSet {
            run()
        }
    }

    public var shimmerColor: UIColor = .white {
        didSet {
            updateColor()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        addSubview(gradientView)
        gradientView.gradientLayer.gradient = .leftRight
        updateColor()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateSize()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColor()
    }

    public func run() {
        gradientView.layer.add(self.makeAnimation(), forKey: "shimmer")
    }

    public func stop() {
        gradientView.layer.removeAnimation(forKey: "shimmer")
    }

    private func updateColor() {
        let clearColor = shimmerColor.withAlphaComponent(0)
        gradientView.gradientLayer.colors = [
            clearColor.cgColor,
            shimmerColor.cgColor,
            clearColor.cgColor
        ]
    }

    private func updateSize() {
        if gradientView.frame.size == bounds.size {
            return
        }
        gradientView.frame.size = bounds.size
        gradientView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        run()
    }

    private func makeAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fillMode = .forwards
        animation.fromValue = -bounds.size.width
        animation.toValue = bounds.size.width
        animation.repeatCount = .infinity
        animation.duration = duration
        animation.beginTime = Self.now
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        return animation
    }
}
