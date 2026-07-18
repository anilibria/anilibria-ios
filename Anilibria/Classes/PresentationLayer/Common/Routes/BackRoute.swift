protocol BackRoute {
    func back()
    func backToRoot()
    func dismissPresentedStack()
}

extension BackRoute where Self: RouterProtocol {
    func back() {
        if let nc = self.controller.navigationController, nc.viewControllers.first != self.controller {
            nc.popViewController(animated: true)
        } else {
            self.controller.dismiss(animated: true)
        }
    }

    /// Dismisses this controller together with anything presented on top of it
    /// (e.g. a modally presented screen presenting another modal screen),
    /// in a single dismiss call to avoid double-dismiss race conditions.
    func dismissPresentedStack() {
        if let nc = self.controller.navigationController, nc.viewControllers.first != self.controller {
            nc.popViewController(animated: true)
        } else if let presenting = self.controller.presentingViewController {
            presenting.dismiss(animated: true)
        } else {
            self.controller.dismiss(animated: true)
        }
    }

    func backToRoot() {
        if let nc = self.controller.navigationController, nc.viewControllers.first != self.controller {
            nc.popToRootViewController(animated: true)
        } else if let controller = self.controller.presentingViewController {
            controller.dismiss(animated: true)
        } else {
            controller.dismiss(animated: true)
        }
    }

    func dissmiss() {
        self.controller.dismiss(animated: true)
    }
}
