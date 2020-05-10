import UIKit

protocol ShareRoute {
    func openShare(items: [Any])
}

extension ShareRoute where Self: RouterProtocol {
    func openShare(items: [Any]) {
        let module = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ModalRouter(target: module, parent: self.controller).move()
    }
}
