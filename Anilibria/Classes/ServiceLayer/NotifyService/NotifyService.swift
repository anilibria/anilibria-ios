import DITranquillity
import FirebaseMessaging
import FirebaseInstanceID
import RxCocoa
import RxSwift
import UserNotifications

class NotifyServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(NotifyServiceImp.init)
            .as(NotifyService.self)
            .lifetime(.single)
    }
}

protocol NotifyService {
    func registerForRemoteNotification()
    func fetchDataSequence() -> Observable<PushData>

    func getSettings() -> NotifySettings
    func set(settings: NotifySettings)
}

final class NotifyServiceImp: NSObject, NotifyService, Loggable {
    var defaultLoggingTag: LogTag {
        return .service
    }

    let schedulers: SchedulerProvider
    let backendRepository: BackendRepository
    let notifyRepository: NotifySettingsRepository

    private let dataSequence: BehaviorRelay<PushData?> = BehaviorRelay(value: nil)

    private let bag: DisposeBag = DisposeBag()
    private let allTopic = "all"
    private let iosTopic = "ios_all"

    init(schedulers: SchedulerProvider,
         backendRepository: BackendRepository,
         notifyRepository: NotifySettingsRepository) {
        self.schedulers = schedulers
        self.backendRepository = backendRepository
        self.notifyRepository = notifyRepository
    }

    func registerForRemoteNotification() {
        Messaging.messaging().delegate = self

        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { _, error in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        self.updateGlobalSettings()
    }

    func fetchDataSequence() -> Observable<PushData> {
        return self.dataSequence
            .compactMap { $0 }
    }

    func getSettings() -> NotifySettings {
        return self.notifyRepository.getItem()
    }

    func set(settings: NotifySettings) {
        let old = self.getSettings()
        self.notifyRepository.set(item: settings)
        if settings.global != old.global {
            self.updateGlobalSettings()
        }
    }

    private func updateGlobalSettings() {
        let settings = self.getSettings()
        let fcm = Messaging.messaging()

        if settings.global {
            fcm.subscribe(toTopic: self.allTopic)
            fcm.subscribe(toTopic: self.iosTopic)
        } else {
            fcm.unsubscribe(fromTopic: self.allTopic)
            fcm.unsubscribe(fromTopic: self.iosTopic)
        }
    }

    private func handle(push: [String : Any]) {
        self.dataSequence.accept(PushData(push))
        self.log(.debug, "\(push)")
    }
}

extension NotifyServiceImp: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        self.log(.debug, "Firebase registration token: \(fcmToken)")
        self.updateGlobalSettings()
    }
}

extension NotifyServiceImp: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String : Any] {
            self.handle(push: userInfo)
        }
        completionHandler()
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
