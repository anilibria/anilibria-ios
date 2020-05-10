import UIKit

public class AppRouter {
    private var window: UIWindow!

    init() {}

    private func createWindow() -> UIWindow {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.backgroundColor = .black

        return self.window
    }

    public func openDefaultScene() {
        let module = MainContainerAssembly.createModule()
        ShowWindowRouter(target: module,
                         window: self.createWindow()).move()
    }

    public func openLoadingScene() {
        let window = self.createWindow()
        window.backgroundColor = .white
        let module = ConfigurationAssembly.createModule()
        ShowWindowRouter(target: module,
                         window: window).move()
    }
}
