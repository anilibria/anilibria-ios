//
//  SkipViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 19.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

final class SkipViewModel {
    private enum CreditsType {
        case opening
        case ending
    }

    private let autoSkipTime: Int = 5
    private var mode: SkipCreditsMode = .disabled
    private var ranges: [CreditsType?: Range<Int>] = [:]
    private var currentTime: Int = 0
    private var timerSubscriber: AnyCancellable?

    private var currentRangeType: CreditsType? {
        didSet {
            if currentRangeType != oldValue, mode != .disabled {
                canSkip = currentRange != nil
            }
        }
    }

    private var currentRange: Range<Int>? {
        get { ranges[currentRangeType] }
        set { ranges[currentRangeType] = newValue }
    }

    @Published private(set) var autoSkipTimeLeft: Int = 0
    @Published private(set) var canSkip: Bool = false {
        didSet {
            if canSkip && canSkip != oldValue {
                runAutoSkipTimer()
            } else {
                timerSubscriber = nil
            }
        }
    }

    var isActive: Bool = false
    var skipHandler: ((Double) -> Void)?

    func set(item: PlayItem?) {
        ranges[.opening] = item?.value.openingRange
        ranges[.ending] = item?.value.endingRange
        canSkip = false
    }

    func set(mode: SkipCreditsMode) {
        self.mode = mode
        if mode != .disabled {
            canSkip = currentRange != nil
        } else {
            canSkip = false
        }
    }

    func update(time: Double) {
        currentTime = Int(time)
        if ranges[.opening]?.contains(currentTime) == true {
            currentRangeType = .opening
        } else if ranges[.ending]?.contains(currentTime) == true {
            currentRangeType = .ending
        } else {
            currentRangeType = nil
        }
    }

    func skip() {
        guard
            let endTime = currentRange?.upperBound,
            endTime > currentTime
        else {
            return
        }
        let time = Double(endTime - currentTime)
        skipHandler?(time)
    }

    func watch() {
        currentRange = nil
        currentRangeType = nil
        timerSubscriber = nil
    }

    private func runAutoSkipTimer() {
        timerSubscriber = nil
        guard mode == .automatic else { return }
        autoSkipTimeLeft = autoSkipTime
        timerSubscriber = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                guard let self, isActive else { return }
                autoSkipTimeLeft -= 1
                if autoSkipTimeLeft <= 0 {
                    timerSubscriber = nil
                    skip()
                }
            })
    }
}
