//
//  UserCollectionRouter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

// MARK: - Router

protocol UserCollectionRoutable: BaseRoutable, SeriesRoute, FilterRoute {}

final class UserCollectionRouter: BaseRouter, UserCollectionRoutable {}
