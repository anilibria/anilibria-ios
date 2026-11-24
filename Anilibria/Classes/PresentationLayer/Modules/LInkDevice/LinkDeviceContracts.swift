//
//  LinkDeviceContracts.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

// MARK: - Contracts

protocol LinkDeviceBehavior: WaitingBehavior {
}

protocol LinkDeviceHandler: ViewControllerEventHandler {
    func bind(view: LinkDeviceBehavior, router: LinkDeviceRoutable)
    func accept(code: String)
    func close()
}
