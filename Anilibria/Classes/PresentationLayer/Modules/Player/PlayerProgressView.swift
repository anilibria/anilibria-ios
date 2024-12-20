//
//  PlayerProgressView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public final class PlayerProgressView: UIView {
    private let progressRangeView = UIView()
    private let bufferRangeView = UIView()
    private let backRangeView = UIView()
    private let containerView = UIView()

    private let lineHeight: CGFloat = 4
    private let thumbRadius: CGFloat = 8

    private(set) var duration: Double = 0
    private(set) var buffering: ClosedRange<Double>?
    private(set) var progress: Double = 0
    private(set) var isDragging: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override var intrinsicContentSize: CGSize {
        UIView.layoutFittingExpandedSize
    }

    var didSelectProgress: ((Double) -> Void)?
    var changeValue: ((Double, Double) -> Void)?

    func set(duration: Double) {
        self.duration = max(duration, 0)
        self.buffering = nil
        self.progress = 0
        updatePositions()
        changeValue?(0, duration)
    }

    func set(buffering: ClosedRange<Double>?) {
        if self.buffering == buffering { return }
        self.buffering = buffering
        updateBuffering()
    }

    func set(progress: Double) {
        let value = max(min(progress, duration), 0)
        if self.progress == value { return }
        if isDragging { return }
        self.progress = value
        updatePositions()
        changeValue?(self.progress, duration)
    }

    private func setup() {
        isUserInteractionEnabled = true
        containerView.clipsToBounds = false
        addSubview(containerView)
        containerView.addSubview(backRangeView)
        containerView.addSubview(bufferRangeView)
        containerView.addSubview(progressRangeView)

        containerView.layer.cornerRadius = lineHeight / 2
        containerView.clipsToBounds = true

        let pan = UIPanGestureRecognizer(target: self, action: #selector(recognize(gesture:)))
        addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(recognize(gesture:)))
        addGestureRecognizer(tap)

        bufferRangeView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        progressRangeView.backgroundColor = UIColor(resource: .Tint.active)
        backRangeView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        backRangeView.clipsToBounds = true

        progressRangeView.frame = CGRect(origin: .zero, size: .init(width: 0, height: lineHeight))
        bufferRangeView.frame = CGRect(origin: .zero, size: .init(width: 0, height: lineHeight))
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = CGRect(
            x: thumbRadius,
            y: (bounds.height - lineHeight) / 2,
            width: bounds.width - 2 * thumbRadius,
            height: lineHeight
        )
        backRangeView.frame = containerView.bounds
        updatePositions()
    }

    private func updatePositions() {
        updateProgress()
        updateBuffering()
    }

    private func updateProgress() {
        if duration > 0 {
            progressRangeView.frame.size.width = (progress / duration) * containerView.bounds.width
        } else {
            progressRangeView.frame.size.width = 0
        }
    }

    private func updateBuffering() {
        if let buffering, duration > 0 {
            let positionX = (buffering.lowerBound / duration) * containerView.bounds.width
            let bufferDuration = buffering.upperBound - buffering.lowerBound
            let width = (bufferDuration / duration) * containerView.bounds.width
            bufferRangeView.frame.origin.x = positionX
            bufferRangeView.frame.size.width = width
        } else {
            bufferRangeView.frame.size.width = 0
        }
    }

    @objc private func recognize(gesture: UIGestureRecognizer) {
        if duration <= 0 { return }
        let location = gesture.location(in: containerView)
        let positionX = min(max(location.x, 0), containerView.bounds.width)

        switch gesture.state {
        case .began:
            isDragging = true
            changeValue?(updateProgress(positionX: positionX), duration)
        case .changed:
            changeValue?(updateProgress(positionX: positionX), duration)
        case .ended, .cancelled:
            isDragging = false
            let target = updateProgress(positionX: positionX)
            didSelectProgress?(target)
            set(progress: target)
        default:
            break
        }
    }

    private func updateProgress(positionX: CGFloat) -> Double {
        progressRangeView.frame.size.width = positionX
        return (positionX / containerView.bounds.width) * duration
    }
}
