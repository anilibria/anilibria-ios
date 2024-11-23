import UIKit

public class AppRouter {
    private(set) var window: UIWindow!

    init() {}

    private func createWindow() -> UIWindow {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.backgroundColor = .black
        #if targetEnvironment(macCatalyst)
        window.windowScene?.titlebar?.titleVisibility = .hidden
        #endif

        defer {
            InterfaceAppearance.current.apply()
        }
        return self.window
    }

    public func openDefaultScene() {
        let module = MainContainerAssembly.createModule()
        ShowWindowRouter(target: module,
                         window: self.createWindow()).move()
    }
}
