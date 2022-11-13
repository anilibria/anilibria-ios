//
//  MRTorrentListRouter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

// MARK: - Router

protocol TorrentListRoutable: BaseRoutable, PlayerRoute {}

final class TorrentListRouter: BaseRouter, TorrentListRoutable {}
