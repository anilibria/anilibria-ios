import Combine
import UIKit

// MARK: - View Controller

final class SignInViewController: BaseViewController {
    @IBOutlet var loginField: MRTextField!
    @IBOutlet var passwordField: MRTextField!
    @IBOutlet var authProvidersView: UIStackView!
    @IBOutlet var logInButton: RippleButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var resetButton: UIButton!

    private var providersBag: Set<AnyCancellable> = []

    var handler: SignInEventHandler!

    override var isNavigationBarVisible: Bool { false }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.didLoad()
        self.addKeyboardObservers()
        self.subscribes()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.handler.cancel()
    }

    override func setupStrings() {
        super.setupStrings()
        loginField.placeholder = L10n.Screen.Auth.login
        loginField.placeHolderColor = .Text.secondary
        passwordField.placeholder = L10n.Screen.Auth.password
        passwordField.placeHolderColor = .Text.secondary
        logInButton.setTitle(L10n.Buttons.signIn, for: .normal)

        logInButton.enabledColor = .Buttons.selected
        logInButton.disabledColor = .Buttons.unselected
        logInButton.cornerRadius = 6

        signUpButton.setTitle(L10n.Buttons.signUp, for: .normal)
        resetButton.setTitle(L10n.Buttons.resetPassword, for: .normal)
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

    @IBAction func closeAction(_ sender: Any) {
        self.handler.back()
    }

    @IBAction func loginAction(_ sender: Any) {
        self.handler.login(
            login: loginField.text ?? "",
            password: passwordField.text ?? ""
        )
        view.endEditing(true)
    }

    @IBAction func signUpAction() {
        handler.signUp()
    }

    @IBAction func resetAction() {
        handler.resetPassword()
    }
}

extension SignInViewController: SignInViewBehavior {
    func set(providers: [AuthProvider]) {
        providersBag.removeAll()
        authProvidersView.subviews.forEach {
            authProvidersView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        providers.forEach { provider in
            let button = makeAuthButton(provider: provider)
            authProvidersView.addArrangedSubview(button)
        }
    }

    private func makeAuthButton(provider: AuthProvider) -> UIButton {
        let button = RippleButton()
        button.backgroundColor = .Buttons.selected
        button.smoothCorners(with: 6)
        button.setImage(provider.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .Text.monoLight
        button.publisher(for: .touchUpInside).sink { [weak self] in
            self?.handler.login(with: provider)
        }.store(in: &providersBag)

        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }
}

private extension AuthProvider {
    var image: UIImage {
        switch self {
        case .vk: return .iconVk
        case .google: return .iconGoogle
        case .patreon: return .iconPatreon
        case .discord: return .iconDiscord
        }
    }
}
