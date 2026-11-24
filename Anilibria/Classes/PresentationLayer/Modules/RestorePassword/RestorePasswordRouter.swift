//
//  RestorePasswordRoutable.swift
//  Anilibria
//
//  Created by Ivan Morozov on 11.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

protocol RestorePasswordRoutable: BaseRoutable, BackRoute, AlertRoute {}

final class RestorePasswordRouter: BaseRouter, RestorePasswordRoutable {}
