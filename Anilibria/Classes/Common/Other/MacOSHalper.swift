//
//  MacOSHalper.swift
//  Anilibria
//
//  Created by Иван Морозов on 24.01.2020.
//  Copyright © 2020 Иван Морозов. All rights reserved.
//

import Foundation

public final class MacOSHelper {
    private let macApp: NSObject.Type!

    private init() {
        Bundle(path: Bundle.main.builtInPlugInsPath?.appending("/MacBundle.bundle") ?? "")?.load()
        self.macApp = NSClassFromString("MacApp") as? NSObject.Type
    }

    static let shared: MacOSHelper = MacOSHelper()

    func toggleFullScreen() {
        self.macApp?.perform(NSSelectorFromString("toggleFullScreen"))
    }

    func removeMenuItems() {
        self.macApp?.perform(NSSelectorFromString("removeMenuItems"))
    }

    var fullscreenButtonEnabled: Bool = true {
        didSet {
            if fullscreenButtonEnabled {
                self.macApp?.perform(NSSelectorFromString("enableZoom"))
            } else {
                self.macApp?.perform(NSSelectorFromString("disableZoom"))
            }
        }
    }
}
