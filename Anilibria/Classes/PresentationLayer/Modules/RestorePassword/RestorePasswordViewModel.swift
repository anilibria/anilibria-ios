//
//  RestorePasswordViewModel.swift
//  Anilibria
//
//  Created by Ivan Morozov on 11.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation
import Combine
import DITranquillity

final class RestorePasswordPart: DIPart {
    static func load(container: DIContainer) {
        container.register(RestorePasswordViewModel.init)
            .lifetime(.objectGraph)
    }
}

final class RestorePasswordViewModel {
    enum Mode {
        case sendEmail
        case resetPassword

        fileprivate var next: Mode {
            switch self {
            case .sendEmail: .resetPassword
            case .resetPassword: .sendEmail
            }
        }
    }

    private var router: RestorePasswordRoutable?
    private var cancellables: Set<AnyCancellable> = []
    private let service: SessionService

    let mode = CurrentValueSubject<Mode, Never>(.sendEmail)

    init(service: SessionService) {
        self.service = service
    }

    func set(router: RestorePasswordRoutable) {
        self.router = router
    }

    func send(email: String, with waiting: WaitingBehavior) {
        service.forgetPassword(email: email)
            .manageActivity(waiting.showLoading(fullscreen: false))
            .sink { [weak self] in
                self?.changeMode()
            } onError: { [weak self] error in
                self?.router?.show(error: error)
            }
            .store(in: &cancellables)
    }

    func reset(password: String, token: String, with waiting: WaitingBehavior) {
        service.resetPassword(token: token, password: password)
            .manageActivity(waiting.showLoading(fullscreen: false))
            .sink { [weak self] in
                self?.showSuccess()
            } onError: { [weak self] error in
                self?.handle(error)
            }
            .store(in: &cancellables)
    }

    func changeMode() {
        mode.send(mode.value.next)
    }

    private func handle(_ error: Error) {
        switch (error as? AppError) {
        case .network(404):
            router?.show(error: AppError.plain(message: L10n.Error.recoveryTokenNotFound))
        default:
            router?.show(error: error)
        }
    }

    private func showSuccess() {
        self.router?.openAlert(
            title: L10n.Screen.RestorePassword.Success.title,
            message: L10n.Screen.RestorePassword.Success.message,
            buttons: [L10n.Buttons.ok],
            tapBlock: { [weak self] _ in
                self?.router?.back()
            })
    }
}
