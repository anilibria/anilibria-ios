//
//  EpisodesRouter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 28.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

protocol EpisodesRoutable: BaseRoutable,
                           BackRoute,
                           PlayerRoute {}

final class EpisodesRouter: BaseRouter, EpisodesRoutable {}
