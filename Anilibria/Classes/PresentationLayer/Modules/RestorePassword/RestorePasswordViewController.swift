//
//  RestorePasswordViewController.swift
//  Anilibria
//
//  Created by Ivan Morozov on 11.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class RestorePasswordViewController: BaseViewController {
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var emailModeContainerView: UIView!
    @IBOutlet var restoreModeContainerView: UIView!
    @IBOutlet var emailField: MRTextField!
    @IBOutlet var tokenField: MRTextField!
    @IBOutlet var passwordField: SecureTextField!
    @IBOutlet var repeatPasswordField: SecureTextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var continueButton: RippleButton!
    @IBOutlet var changeModeButton: UIButton!

    private var providersBag: Set<AnyCancellable> = []

    var viewModel: RestorePasswordViewModel!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeyboardObservers()
        self.subscribes()
    }

    override func setupStrings() {
        super.setupStrings()
        navigationItem.title = L10n.Screen.RestorePassword.title
        emailField.placeholder = L10n.Screen.RestorePassword.email
        emailField.placeHolderColor = UIColor(resource: .Text.secondary)

        tokenField.placeholder = L10n.Screen.RestorePassword.token
        tokenField.placeHolderColor = UIColor(resource: .Text.secondary)

        passwordField.placeholder = L10n.Screen.RestorePassword.newPassword
        passwordField.placeHolderColor = UIColor(resource: .Text.secondary)

        repeatPasswordField.placeholder = L10n.Screen.RestorePassword.repeatPassword
        repeatPasswordField.placeHolderColor = UIColor(resource: .Text.secondary)

        continueButton.setTitle(L10n.Buttons.continue, for: .normal)
        continueButton.enabledColor = UIColor(resource: .Buttons.selected)
        continueButton.disabledColor = UIColor(resource: .Buttons.unselected)
        continueButton.cornerRadius = 6

        changeModeButton.setTitle(L10n.Buttons.signUp, for: .normal)
        apply(mode: viewModel.mode.value)
    }

    private func subscribes() {
        let fields = Publishers.CombineLatest4(
            emailField.textPublisher.map { $0 ?? "" },
            tokenField.textPublisher.map { $0 ?? "" },
            passwordField.$secureText,
            repeatPasswordField.$secureText
        )

        viewModel.mode.dropFirst().sink { [weak self] in
            self?.apply(mode: $0)
            self?.animate()
        }.store(in: &subscribers)

        Publishers.CombineLatest(
            viewModel.mode,
            fields
        ).sink { [weak self] mode, fields in
            guard let self else { return }
            switch mode {
            case .sendEmail:
                continueButton.isEnabled = fields.0.match(pattern: Regexp.email)
            case .resetPassword:
                if fields.2.isEmpty || fields.3.isEmpty {
                    continueButton.isEnabled = false
                    updatePasswordLine(color: UIColor(resource: .Tint.main))
                } else if fields.2 == fields.3 {
                    continueButton.isEnabled = !fields.1.isEmpty
                    updatePasswordLine(color: UIColor(resource: .Tint.main))
                } else {
                    continueButton.isEnabled = false
                    updatePasswordLine(color: UIColor(resource: .Tint.active))
                }
            }
        }.store(in: &subscribers)
    }

    private func updatePasswordLine(color: UIColor) {
        passwordField.targetView?.backgroundColor = color
        repeatPasswordField.targetView?.backgroundColor = color
    }

    private func apply(mode: RestorePasswordViewModel.Mode) {
        switch mode {
        case .sendEmail:
            infoLabel.text = L10n.Screen.RestorePassword.sendEmailInfo
            changeModeButton.setTitle(L10n.Screen.RestorePassword.Buttons.recovery, for: .normal)
            emailModeContainerView.isHidden = false
            restoreModeContainerView.isHidden = true
        case .resetPassword:
            infoLabel.text = L10n.Screen.RestorePassword.newPasswordInfo
            changeModeButton.setTitle(L10n.Screen.RestorePassword.Buttons.resendEmail, for: .normal)
            emailModeContainerView.isHidden = true
            restoreModeContainerView.isHidden = false
        }
    }

    private func animate() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromRight
        transition.timingFunction = .init(name: .easeInEaseOut)
        scrollView.layer.add(transition, forKey: "transition")
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        self.scrollView.contentInset.bottom = keyboardHeight
    }

    override func keyBoardWillHide() {
        self.scrollView.contentInset.bottom = 0
    }

    // MARK: - Actions

    @IBAction func continueAction() {
        view.endEditing(true)
        switch viewModel.mode.value {
        case .sendEmail:
            if let email = emailField.text {
                viewModel.send(email: email, with: self)
            }
        case .resetPassword:
            if let token = tokenField.text, let password = passwordField.text {
                viewModel.reset(password: password, token: token, with: self)
            }
        }
    }

    @IBAction func changeModeAction() {
        view.endEditing(true)
        viewModel.changeMode()
    }
}
