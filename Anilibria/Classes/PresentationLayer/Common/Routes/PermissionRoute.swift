import UserNotifications

public enum PermissionType {
    case push

    fileprivate var value: Permission! {
        return PermissionType.permissions[self]
    }

    private static let permissions: [PermissionType: Permission] = [
        .push: PushPermission()
    ]
}

protocol PermissionRoute: AlertRoute, AppUrlRoute {
    func request(permission: PermissionType, authorizedHandler: ActionFunc?)
    func request(permission: PermissionType, completion: Action<Bool>?)
}

extension PermissionRoute where Self: RouterProtocol {
    func request(permission: PermissionType, authorizedHandler: ActionFunc?) {
        permission.value.manage { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    authorizedHandler?()
                case .denied:
                    self?.openAlertFor(permission: permission.value)
                default:
                    break
                }
            }
        }
    }

    func request(permission: PermissionType, completion: Action<Bool>?) {
        permission.value.manage { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    completion?(true)
                case .denied:
                    completion?(false)
                    self?.openAlertFor(permission: permission.value)
                default:
                    break
                }
            }
        }
    }

    private func openAlertFor(permission: Permission) {
        let action: Action<Int> = { [weak self] index in
            if index == 0 {
                return
            }
            self?.open(url: .settings)
        }

        let data = permission.data
        let buttons: [AlertButton] = [
            (data.denyText, .default),
            (data.allowText, .destructive)
        ]

        self.openAlert(title: data.title,
                       message: data.message,
                       buttons: buttons,
                       tapBlock: action)
    }
}

public enum PermissionStatus {
    case notDetermined, denied, authorized, notAvailable
}

public struct PermissionData {
    let title: String
    let message: String
    let allowText: String
    let denyText: String
}

public protocol Permission {
    var data: PermissionData { get }
    func manage(completion: @escaping (PermissionStatus) -> Void)
    func checkStatus(completion: @escaping (PermissionStatus) -> Void)
    func askForPermission(completion: @escaping (PermissionStatus) -> Void)
}

extension Permission {
    public func manage(completion: @escaping (PermissionStatus) -> Void) {
        self.checkStatus { status in
            self.managePermission(status: status, completion: completion)
        }
    }

    private func managePermission(status: PermissionStatus, completion: @escaping (PermissionStatus) -> Void) {
        switch status {
        case .notDetermined:
            self.askForPermission(completion: completion)
        case .denied:
            return completion(.denied)
        case .authorized:
            return completion(.authorized)
        case .notAvailable:
            break
        }
    }
}

public final class PushPermission: Permission {
    public private(set) var data: PermissionData = {
        PermissionData(title: L10n.Permission.title,
                       message: L10n.Permission.push,
                       allowText: L10n.Buttons.settings,
                       denyText: L10n.Buttons.cancel)
    }()

    public func checkStatus(completion: @escaping (PermissionStatus) -> Void) {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    return completion(.notDetermined)
                case .denied:
                    return completion(.denied)
                default:
                    return completion(.authorized)
                }
            }
    }

    public func askForPermission(completion: @escaping (PermissionStatus) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert, .badge]) { value, _ in
            DispatchQueue.main.async {
                if value {
                    completion(.authorized)
                } else {
                    completion(.denied)
                }
            }
        }
    }
}
