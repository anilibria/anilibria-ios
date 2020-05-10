import UIKit

public protocol ErrorHandling {
    func handle(error: Error) -> Bool
}

protocol ErrorHandlingRoute {
    func show(error: Error)
}

extension ErrorHandlingRoute where Self: RouterProtocol {
    func show(error: Error) {
        if let handler = self.controller as? ErrorHandling {
            if handler.handle(error: error) {
                return
            }
        }
        MRAppAlertController.alert(L10n.Alert.Title.error,
                                   message: error.message)
    }
}
