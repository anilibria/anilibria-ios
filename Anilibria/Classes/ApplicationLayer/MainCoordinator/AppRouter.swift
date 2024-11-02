import UIKit

public class AppRouter {
    private var window: UIWindow!

    init() {}

    private func createWindow() -> UIWindow {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.backgroundColor = .black
        window.windowScene?.titlebar?.titleVisibility = .hidden

        return self.window
    }

    public func openDefaultScene() {
        let module = MainContainerAssembly.createModule()
        ShowWindowRouter(target: module,
                         window: self.createWindow()).move()
    }
}
