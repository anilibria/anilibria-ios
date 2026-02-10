//
//  SceneDelegate.swift
//  Anilibria
//
//  Created by Ivan Morozov on 09.02.2026.
//  Copyright © 2026 Иван Морозов. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }


        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .black

        #if targetEnvironment(macCatalyst)
        windowScene.titlebar?.titleVisibility = .hidden
        windowScene.sizeRestrictions?.minimumSize = Sizes.minSize
        windowScene.sizeRestrictions?.maximumSize = Sizes.minSize
        MacOSHelper.shared.removeMenuItems()
        MacOSHelper.shared.fullscreenButtonEnabled = false
        #endif

        self.window = window
        MainAppCoordinator.shared.start(on: window)
    }
}
