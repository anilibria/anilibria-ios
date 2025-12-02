//
//  TimeCodesService.swift
//  Anilibria
//
//  Created by Ivan Morozov on 01.12.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import DITranquillity
import Combine

final class TimeCodesServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(TimeCodesServiceImp.init)
            .as(TimeCodesService.self)
            .lifetime(.single)
    }
}

protocol TimeCodesService: AnyObject {
}

final class TimeCodesServiceImp: TimeCodesService, Loggable {
    var defaultLoggingTag: LogTag { .service }

    private let backendRepository: BackendRepository

    private var sessionSubscriber: AnyCancellable?
    private var synchSusbscriber: AnyCancellable?
    private var activeSusbscriber: AnyCancellable?
    private var lastSynchTime: Date?

    init(backendRepository: BackendRepository,
         sessionService: SessionService) {
        self.backendRepository = backendRepository

        sessionSubscriber = sessionService.fetchState().removeDuplicates().sink { [weak self] state in
            switch state {
            case .user: self?.runSynch()
            default: self?.cancelSynch()
            }
        }
    }

    private func runSynch() {
        synchTimes()
        activeSusbscriber = NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.synchTimes()
            }
    }

    private func synchTimes() {
        synchSusbscriber = backendRepository.request(GetTimecodesRequest(since: lastSynchTime))
            .sink { [weak self] result in
                self?.lastSynchTime = Date()
            }
    }

    private func cancelSynch() {
        synchSusbscriber = nil
        activeSusbscriber = nil
        lastSynchTime = nil
    }

    private func fetchTimeCodes() -> AnyPublisher<[TimeCodeData], any Error> {
        return backendRepository.request(GetTimecodesRequest(since: nil))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}
