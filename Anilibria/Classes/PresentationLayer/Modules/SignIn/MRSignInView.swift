import Combine
import UIKit

// MARK: - View Controller

final class SignInViewController: BaseViewController {
    @IBOutlet var loginField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var codeField: UITextField!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var socialContainer: UIView!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!

    var handler: SignInEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.didLoad()
        self.addKeyboardObservers()
        self.subscribes()
    }
    
    override func setupStrings() {
        super.setupStrings()
        loginField.placeholder = L10n.Screen.Auth.login
        passwordField.placeholder = L10n.Screen.Auth.password
        codeField.placeholder = L10n.Screen.Auth.code
        codeLabel.text = L10n.Screen.Auth.Code.description
        logInButton.setTitle(L10n.Buttons.signIn, for: .normal)
        skipButton.setTitle(L10n.Buttons.skip, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func subscribes() {
        Publishers.ThreadSafeCombineLatest(
            self.loginField.textPublisher.map { $0 ?? "" },
            self.passwordField.textPublisher.map { $0 ?? "" }
        )
        .sink(onNext: { [weak self] in
            self?.logInButton.isEnabled = !($0.isEmpty || $1.isEmpty)
        })
        .store(in: &subscribers)
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        self.scrollView.contentInset.bottom = keyboardHeight
    }

    override func keyBoardWillHide() {
        self.scrollView.contentInset.bottom = 0
    }

    // MARK: - Actions

    @IBAction func skipAction(_ sender: Any) {
        self.handler.back()
    }

    @IBAction func registerAction(_ sender: Any) {
        self.handler.register()
    }

    @IBAction func socialLoginAction(_ sender: Any) {
        self.handler.socialLogin()
    }

    @IBAction func loginAction(_ sender: Any) {
        self.handler.login(login: self.loginField.text ?? "",
                           password: self.passwordField.text ?? "",
                           code: self.codeField.text ?? "")
    }
}

extension SignInViewController: SignInViewBehavior {
    func set(socialLogin avaible: Bool) {
        self.socialContainer.isHidden = !avaible
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
