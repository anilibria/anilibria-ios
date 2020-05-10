import UIKit

public typealias AlertButton = (text: String, style: UIAlertAction.Style)

public class MRAppAlertController {
    private static let manager: MRAlertManager = .init()
    private static var alertFactory: AlertViewFactory = DefaultAlertViewFactory()

    @discardableResult
    public static func set(alertFactory: AlertViewFactory) -> MRAppAlertController.Type {
        self.alertFactory = alertFactory
        return self
    }

    @discardableResult
    public static func set(alertPresent: AlertPresentProtocol) -> MRAppAlertController.Type {
        self.manager.set(alertPresent: alertPresent)
        return self
    }

    public static func alert(_ title: String,
                             message: String = "",
                             acceptMessage: String = "OK",
                             userData: Any? = nil,
                             acceptBlock: (() -> Void)? = nil) {
        let buttons = [AlertButton(acceptMessage, .default)]
        let alert = self.alertFactory.create(title,
                                             message: message,
                                             buttons: buttons,
                                             userData: userData) { _ in
            acceptBlock?()
            self.manager.presentNextIfNeeded()
        }
        self.manager.presentIfCan(alert)
    }

    public static func alert(_ title: String,
                             message: String,
                             buttons: [String],
                             userData: Any? = nil,
                             tapBlock: ((Int) -> Void)? = nil) {
        let alertButtons = buttons.map { AlertButton($0, .default) }
        let alert = self.alertFactory.create(title,
                                             message: message,
                                             buttons: alertButtons,
                                             userData: userData) {
            tapBlock?($0)
            self.manager.presentNextIfNeeded()
        }
        self.manager.presentIfCan(alert)
    }

    public static func alert(_ title: String,
                             message: String,
                             buttons: [AlertButton],
                             userData: Any? = nil,
                             tapBlock: ((Int) -> Void)? = nil) {
        let alert = self.alertFactory.create(title,
                                             message: message,
                                             buttons: buttons,
                                             userData: userData) {
            tapBlock?($0)
            self.manager.presentNextIfNeeded()
        }
        self.manager.presentIfCan(alert)
    }
}

// MARK: - Alert manager

private final class MRAlertManager {
    private var alertsBuffer: [UIViewController] = []
    private var presented: UIViewController?
    private var alertPresent: AlertPresentProtocol = DefaultAlertPresent()

    public func set(alertPresent: AlertPresentProtocol) {
        self.alertPresent = alertPresent
    }

    func presentIfCan(_ alert: UIViewController) {
        if self.presented != nil {
            self.alertsBuffer.append(alert)
            return
        }
        self.presented = alert
        self.alertPresent.show(alert)
    }

    func presentNextIfNeeded() {
        self.presented = nil
        if self.alertsBuffer.isEmpty {
            return
        }
        let alert = self.alertsBuffer.removeFirst()
        self.presented = alert
        self.alertPresent.show(alert)
    }
}

// MARK: - Alert Present

public protocol AlertPresentProtocol {
    func show(_ alert: UIViewController)
}

public struct DefaultAlertPresent: AlertPresentProtocol {
    public func show(_ alert: UIViewController) {
        ModalRouter(target: alert, parent: nil).move()
    }
}

// MARK: - Alert Factory

public protocol AlertViewFactory {
    func create(_ title: String,
                message: String,
                buttons: [AlertButton],
                userData: Any?,
                tapBlock: ((Int) -> Void)?) -> UIViewController
}

private struct DefaultAlertViewFactory: AlertViewFactory {
    public func create(_ title: String,
                       message: String,
                       buttons: [AlertButton],
                       userData: Any?,
                       tapBlock: ((Int) -> Void)?) -> UIViewController {
        let alert = MRAlertController(title: title, message: message, preferredStyle: .alert)
        for (offset, item) in buttons.enumerated() {
            alert.addAction(UIAlertAction(title: item.text, style: item.style, handler: { _ in
                tapBlock?(offset)
            }))
        }
        return alert
    }
}

private final class MRAlertController: UIAlertController {
    // MARK: - Orientation

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    deinit {
        MacOSHelper.shared.fullscreenButtonEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MacOSHelper.shared.fullscreenButtonEnabled = false
    }
}

// MARK: - Support extensions

private extension UIAlertAction {
    convenience init(title: String?,
                     preferredStyle: UIAlertAction.Style,
                     buttonIndex: Int,
                     tapBlock: ((UIAlertAction, Int) -> Void)?) {
        self.init(title: title, style: preferredStyle) { action in
            if let block = tapBlock {
                block(action, buttonIndex)
            }
        }
    }
}
