import Combine
import UIKit

class BaseViewController: UIViewController, WaitingBehavior, Loggable {
    var defaultLoggingTag: LogTag { .view }
    
    var subscribers = Set<AnyCancellable>()

    public private(set) var refreshControl: RefreshIndicator?
    private weak var refreshActivity: ActivityDisposable?

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
        view.backgroundColor = UIColor(resource: .Surfaces.base)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateRefreshControlRect()
    }

    func initialize() {
        Language.languageChanged.sink { [weak self] _ in
            self?.setupStrings()
            self?.languageDidChanged()
        }.store(in: &subscribers)
    }

    func setupStrings() {}
    
    func languageDidChanged() {}

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    func setupBackButton() {
        if #available(iOS 14.0, *) {
            self.navigationItem.backButtonDisplayMode = .minimal
        } else {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "",
                style: .plain,
                target: nil,
                action: nil
            )
        }
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

    // MARK: - Refresh

    public func addRefreshControl(scrollView: UIScrollView, color: UIColor? = nil) {
        if self.refreshControl != nil {
            return
        }
        scrollView.alwaysBounceVertical = true
        let refreshControl = RefreshIndicator(style: .prominent)
        refreshControl.indicator.lineColor = color ?? UIColor(resource: .Text.main)
        scrollView.addSubview(refreshControl)
        refreshControl.addTarget(
            self,
            action: #selector(self.refresh),
            for: .valueChanged
        )
        self.refreshControl = refreshControl
    }

    public func removeRefreshControl() {
        self.refreshControl?.removeFromSuperview()
        self.refreshControl = nil
    }

    public func updateRefreshControlRect() {
        guard let view = refreshControl?.superview else { return }
        self.refreshControl?.center.x = view.bounds.width / 2
    }

    public func isRefreshing() -> Bool {
        return self.refreshControl?.isRefreshing ?? false
    }

    @objc
    public func refresh() {
        // override me
    }
}

extension BaseViewController: RefreshBehavior {
    func showRefreshIndicator() -> ActivityDisposable? {
        if self.refreshActivity?.isDisposed == false {
            return self.refreshActivity
        }
        if self.isRefreshing() == false {
            self.refreshControl?.startRefreshing()
        }
        return self.createActivity()
    }

    private func createActivity() -> ActivityDisposable? {
        let activity = ActivityHolder { [weak self] in
            self?.refreshControl?.endRefreshing()
        }

        self.refreshActivity = activity
        return activity
    }
}
