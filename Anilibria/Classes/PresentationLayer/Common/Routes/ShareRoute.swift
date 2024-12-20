import UIKit

protocol ShareRoute {
    func openShare(items: [Any])
}

extension ShareRoute where Self: RouterProtocol {
    func openShare(items: [Any]) {
        let module = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {

            module.popoverPresentationController?.sourceView = controller.view
            let frame = CGRect(
                x: (controller.view.bounds.width - module.preferredContentSize.width) / 2,
                y: controller.view.safeAreaInsets.top,
                width: module.preferredContentSize.width,
                height: module.preferredContentSize.height
            )

            module.popoverPresentationController?.sourceRect = frame
            module.popoverPresentationController?.permittedArrowDirections = []

        }
        ModalRouter(target: module, parent: self.controller).move()
    }
}
