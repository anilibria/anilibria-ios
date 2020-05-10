import RxSwift
import UIKit

// MARK: - View Controller

final class SignInViewController: BaseViewController {
    @IBOutlet var loginField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var codeField: UITextField!
    @IBOutlet var socialContainer: UIView!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!

    var handler: SignInEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.didLoad()
        self.addKeyboardObservers()
        self.subscribes()
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
        let sequence = Observable
            .combineLatest(self.loginField.rx.text.orEmpty,
                           self.passwordField.rx.text.orEmpty,
                           resultSelector: { ($0, $1) })

        sequence.subscribe(onNext: { [weak self] in
            self?.logInButton.isEnabled = !($0.isEmpty || $1.isEmpty)
        })
            .disposed(by: self.disposeBag)
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
