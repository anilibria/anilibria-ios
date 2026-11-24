//
//  LinkDeviceRouter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

// MARK: - Router

protocol LinkDeviceRoutable: BaseRoutable, BackRoute, AlertRoute {}

final class LinkDeviceRouter: BaseRouter, LinkDeviceRoutable {}
