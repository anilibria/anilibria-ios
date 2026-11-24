protocol BackRoute {
    func back()
    func backToRoot()
}

extension BackRoute where Self: RouterProtocol {
    func back() {
        if let nc = self.controller.navigationController, nc.viewControllers.first != self.controller {
            nc.popViewController(animated: true)
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
