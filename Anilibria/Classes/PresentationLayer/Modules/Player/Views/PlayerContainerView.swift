//
//  PlayerContainerView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 15.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class PlayerContainerView: UIView {
    @IBOutlet var rewindView: RewindView!
    @IBOutlet var headerContainer: UIView!
    @IBOutlet var controlsContainer: UIView!
    @IBOutlet var bottomContainer: UIView!
    @IBOutlet var bottomStackView: UIStackView!

    var didRequestRewind: ((Double) -> Void)?

    private var tapsCount: Int = 0
    private var rewindTime: Double = 0
    private var rewindStepTime: Double = 10
    private var tapTimerSubscriber: AnyCancellable?

    private var rewindIsVisible: Bool = false {
        didSet {
            if rewindIsVisible != oldValue {
                setRewind(visible: rewindIsVisible)
            }
        }
    }

    var uiIsVisible: Bool = true {
        didSet {
            setUI(visible: uiIsVisible)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(with:)))
        tap.numberOfTouchesRequired = 1
        addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(with:)))
        self.addGestureRecognizer(pan)
    }

    @objc private func tap(with gesture: UITapGestureRecognizer) {
        tapsCount += 1
        if tapsCount > 1 {
            let location = gesture.location(in: self)
            let sign: Double = location.x > bounds.midX ? 1 : -1
            rewindTime = rewindTime + rewindStepTime * sign
            rewindIsVisible = rewindTime != 0
            rewindView.set(time: rewindTime)
        }
        tapTimerSubscriber = Timer.publish(every: 0.3, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                if tapsCount > 1 {
                    rewindIsVisible = false
                    didRequestRewind?(rewindTime)
                } else {
                    uiIsVisible.toggle()
                }
                rewindTime = 0
                tapsCount = 0
        })
    }

    @objc private func pan(with pan: UIPanGestureRecognizer) {
        let translationX = pan.translation(in: self).x
        let time = round(translationX / 2)
        switch pan.state {
        case .changed:
            if rewindIsVisible {
                rewindView.set(time: time)
            } else if abs(translationX) > 60 {
                rewindIsVisible = true
                pan.setTranslation(.zero, in: self)
            }
        case .ended:
            if rewindIsVisible {
                rewindIsVisible = false
                didRequestRewind?(time)
            }
        case .cancelled:
            rewindIsVisible = false
        default: break
        }
    }

    private func setUI(visible: Bool) {
        let alpha: CGFloat = visible ? 1 : 0
        self.bottomStackView.subviews.first?.isHidden = !visible
        self.bottomContainer.fadeTransition(0.3)

        UIView.animate(withDuration: 0.3) {
            self.headerContainer.alpha = alpha
            self.bottomContainer.alpha = alpha
            if !self.rewindIsVisible {
                self.controlsContainer.alpha = alpha
            }
            self.superview?.layoutIfNeeded()
        }
    }

    private func setRewind(visible: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.rewindView.alpha = visible ? 1 : 0
            if self.uiIsVisible {
                self.controlsContainer.alpha = visible ? 0 : 1
            }
        }
    }

}
