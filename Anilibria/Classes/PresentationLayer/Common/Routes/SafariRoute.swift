import SafariServices

protocol SafariRoute {
    func open(url: URL?)
}

extension SafariRoute where Self: RouterProtocol {
    func open(url: URL?) {
        if let value = url, value.scheme?.hasPrefix("http") == true {
            let safari = SFSafariViewController(url: value)
            ModalRouter(target: safari, parent: self.controller).move()
        }
    }
}
