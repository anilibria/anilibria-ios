import UIKit

public class AppRouter {
    private(set) var window: UIWindow!

    init() {}

    public func openDefaultScene(on window: UIWindow) {
        self.window = window
        InterfaceAppearance.current.apply()
        let module = MainContainerAssembly.createModule()
        SetWindowRouter(target: module,
                        window: window).move()
    }
}
