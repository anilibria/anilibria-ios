//
//  RangeView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public final class RangeView: UIView {
    private final class Thumb: UIView {
        var value: Int = 0 {
            didSet {
                if value != oldValue {
                    valueUpdated?(value)
                }
            }
        }

        var valueUpdated: ((Int) -> Void)?

        public override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        func setup() {
            clipsToBounds = true
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = bounds.height / 2
        }
    }

    private let minThumbView = Thumb()
    private let maxThumbView = Thumb()
    private let lineRangeView = UIView()
    private let selectedRangeView = UIView()
    private let containerView = UIView()

    private let lineHeight: CGFloat = 4
    private let thumbRadius: CGFloat = 8
    private var distance: CGFloat?
    private var activeThumb: Thumb?

    @Published private(set) var selectedMin: Int = 0
    @Published private(set) var selectedMax: Int = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private var maxIndex: Int = 0

    func set(maxIndex: Int, selectedMin: Int?, selectedMax: Int?) {
        guard maxIndex >= 1 else { return }
        let selectedMin = selectedMin ?? 0
        let selectedMax = selectedMax ?? maxIndex
        self.maxIndex = maxIndex
        minThumbView.value = min(max(selectedMin, 0), max(selectedMax, 0))
        maxThumbView.value = min(max(selectedMax, minThumbView.value), maxIndex)
        updateThumbsPosition()
    }

    private func setup() {
        isUserInteractionEnabled = true
        containerView.clipsToBounds = false
        addSubview(containerView)
        containerView.addSubview(lineRangeView)
        containerView.addSubview(selectedRangeView)
        containerView.addSubview(minThumbView)
        containerView.addSubview(maxThumbView)

        let size = CGSize(
            width: thumbRadius * 2,
            height: thumbRadius * 2
        )
        minThumbView.frame = CGRect(origin: .zero, size: size)
        maxThumbView.frame = CGRect(origin: .zero, size: size)
        minThumbView.center = CGPoint(x: 0, y: lineHeight / 2)
        maxThumbView.center = CGPoint(x: 0, y: lineHeight / 2)
        selectedRangeView.frame = CGRect(x: 0, y: 0, width: 0, height: lineHeight)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(recognize(gesture:)))
        addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(recognize(gesture:)))
        addGestureRecognizer(tap)

        lineRangeView.backgroundColor = UIColor(resource: .Buttons.unselected)
        lineRangeView.clipsToBounds = true
        lineRangeView.layer.cornerRadius = lineHeight / 2
        selectedRangeView.backgroundColor = UIColor(resource: .Buttons.selected)
        maxThumbView.backgroundColor = UIColor(resource: .Buttons.selected)
        minThumbView.backgroundColor = UIColor(resource: .Buttons.selected)

        maxThumbView.valueUpdated = { [weak self] value in
            self?.selectedMax = value
        }

        minThumbView.valueUpdated = { [weak self] value in
            self?.selectedMin = value
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = CGRect(
            x: thumbRadius,
            y: (bounds.height - lineHeight) / 2,
            width: bounds.width - 2 * thumbRadius,
            height: lineHeight
        )

        lineRangeView.frame = containerView.bounds

        if maxIndex >= 1 {
            distance = containerView.frame.width / CGFloat(maxIndex)
        } else {
            distance = nil
        }

        if activeThumb == nil {
            updateThumbsPosition()
        }
    }

    private func updateThumbsPosition() {
        guard let distance else { return }
        minThumbView.center.x = CGFloat(minThumbView.value) * distance
        maxThumbView.center.x = CGFloat(maxThumbView.value) * distance
        updateSelectedRange()
    }

    private func updateSelectedRange() {
        selectedRangeView.frame = CGRect(
            x: minThumbView.center.x,
            y: 0,
            width: maxThumbView.center.x - minThumbView.center.x,
            height: lineHeight
        )
    }

    @objc private func recognize(gesture: UIGestureRecognizer) {
        let location = gesture.location(in: containerView)
        let positionX = min(max(location.x, 0), containerView.bounds.width)

        switch gesture.state {
        case .began:
            setActiveThumbIfNeeded(positionX: positionX)
            updateActiveThumb(positionX: positionX)
        case .changed:
            updateActiveThumb(positionX: positionX)
        case .ended, .cancelled:
            setActiveThumbIfNeeded(positionX: positionX)
            activeThumb = nil
            UIView.animate(withDuration: 0.2) {
                self.updateThumbsPosition()
            }
        default:
            break
        }
    }

    private func updateActiveThumb(positionX: CGFloat) {
        activeThumb?.center.x = positionX
        let thumbsDistance = maxThumbView.center.x - minThumbView.center.x
        if thumbsDistance < 0 {
            if activeThumb === maxThumbView {
                maxThumbView.center.x = minThumbView.center.x
                activeThumb = minThumbView
            } else {
                minThumbView.center.x = maxThumbView.center.x
                activeThumb = maxThumbView
            }
        }
        activeThumb?.center.x = positionX
        updateIndexOfActiveThumb(positionX: positionX)
        updateSelectedRange()
    }

    private func setActiveThumbIfNeeded(positionX: CGFloat) {
        if activeThumb == nil {
            let minDistance = abs(minThumbView.center.x - positionX)
            let maxDitance = abs(maxThumbView.center.x - positionX)
            if minDistance < maxDitance {
                activeThumb = minThumbView
            } else {
                activeThumb = maxThumbView
            }
        }
        updateIndexOfActiveThumb(positionX: positionX)
    }

    private func updateIndexOfActiveThumb(positionX: CGFloat) {
        if let distance {
            let index = Int(round(positionX / distance))
            activeThumb?.value = index
        }
    }
}
