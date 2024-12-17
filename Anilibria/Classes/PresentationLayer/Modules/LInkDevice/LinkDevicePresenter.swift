//
//  LinkDevicePresenter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation
import Combine
import DITranquillity

final class LinkDevicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(LinkDevicePresenter.init)
            .as(LinkDeviceHandler.self)
            .lifetime(.objectGraph)
    }
}

final class LinkDevicePresenter {
    private var router: (any LinkDeviceRoutable)!
    private weak var view: (any LinkDeviceBehavior)!
    private let service: any SessionService
    private var cancellables: Set<AnyCancellable> = []

    init(service: any SessionService) {
        self.service = service
    }
}


extension LinkDevicePresenter: LinkDeviceHandler {
    func bind(view: any LinkDeviceBehavior, router: any LinkDeviceRoutable) {
        self.view = view
        self.router = router
    }

    func accept(code: String) {
        service.accept(otp: code)
            .manageActivity(view.showLoading(fullscreen: false))
            .sink { [weak self] in
                self?.showSuccess()
            } onError: { [weak self] error in
                self?.handle(error: error)
            }
            .store(in: &cancellables)
    }

    private func handle(error: Error) {
        switch (error as? AppError) {
        case .network(404):
            router?.show(error: AppError.plain(message: L10n.Error.otpNotFound))
        default:
            router?.show(error: error)
        }
    }

    private func showSuccess() {
        self.router.openAlert(
            title: L10n.Screen.LinkDevice.deviceLinked,
            message: "",
            buttons: [L10n.Buttons.ok],
            tapBlock: { [weak self] _ in
                self?.close()
            })
    }

    func close() {
        router?.back()
    }
}
