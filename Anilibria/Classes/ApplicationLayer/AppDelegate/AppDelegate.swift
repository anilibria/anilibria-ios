import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        print("HOME DIRECTORY: \(NSHomeDirectory())")
        #endif
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        MainAppCoordinator.shared.start()
        #if targetEnvironment(macCatalyst)
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                    windowScene.sizeRestrictions?.minimumSize = Sizes.minSize
                    windowScene.sizeRestrictions?.maximumSize = Sizes.minSize
                }
                MacOSHelper.shared.removeMenuItems()
                MacOSHelper.shared.fullscreenButtonEnabled = false
            }
        #endif
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let trash = directory.appendingPathComponent(".Trash")
            if FileManager.default.fileExists(atPath: trash.path) {
                try? FileManager.default.removeItem(at: trash)
            }
        }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
}
