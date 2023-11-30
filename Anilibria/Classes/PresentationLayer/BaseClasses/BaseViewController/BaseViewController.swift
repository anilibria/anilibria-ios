import Combine
import UIKit

class BaseViewController: UIViewController, WaitingBehavior, LanguageBehavior, Loggable {
    var defaultLoggingTag: LogTag { .view }
    
    var subscribers = Set<AnyCancellable>()

    public var statusBarStyle: UIStatusBarStyle = .default

    deinit {
        log(.info, "[D] \(self) destroyed")
        NotificationCenter.default.removeObserver(self)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackButton()
        self.setupStrings()
    }

    func initialize() {
        self.observeLanguageChanges().store(in: &subscribers)
    }

    func setupStrings() {}

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    func setupBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
    }

    // MARK: - App Terminated

    func addTermenateAppObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillTerminate),
                                               name: UIApplication.willTerminateNotification, object: nil)
    }

    @objc func appWillTerminate() {}

    // MARK: - Keyboard

    private var addedValue: CGFloat = 0
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyBoardWillShow(keyboardHeight: keyboardRectangle.height)
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        self.keyBoardWillHide()
    }

    public func keyBoardWillShow(keyboardHeight: CGFloat) {}

    public func keyBoardWillHide() {}

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
}
