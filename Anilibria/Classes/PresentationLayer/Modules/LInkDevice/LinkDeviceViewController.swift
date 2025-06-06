//
//  LinkDeviceViewController 2.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class LinkDeviceViewController: BaseViewController {
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var codeField: MRTextField!
    @IBOutlet var doneButton: RippleButton!
    @IBOutlet var keyboardConstraint: NSLayoutConstraint!

    var handler: LinkDeviceHandler!

    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardObservers()
        view.backgroundColor = .clear
        contentView.smoothCorners(with: 12)

        doneButton.enabledColor = .Buttons.selected
        doneButton.disabledColor = .Buttons.unselected
        doneButton.cornerRadius = 6

        codeField.textPublisher.map { $0?.trim() ?? "" }.sink(onNext: { [weak self] in
            self?.doneButton.isEnabled = !$0.isEmpty
        })
        .store(in: &subscribers)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        codeField.becomeFirstResponder()
    }

    override func setupStrings() {
        super.setupStrings()
        titleLabel.text = L10n.Screen.LinkDevice.title
        doneButton.setTitle(L10n.Buttons.done, for: .normal)
        codeField.placeholder = L10n.Screen.LinkDevice.codePlaceholder
    }

    override func keyBoardWillShow(keyboardHeight: CGFloat) {
        super.keyBoardWillShow(keyboardHeight: keyboardHeight)
        self.keyboardConstraint.constant = keyboardHeight - view.safeAreaInsets.bottom
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    override func keyBoardWillHide() {
        super.keyBoardWillHide()
        self.keyboardConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func doneAction() {
        if let text = codeField.text?.trim() {
            view.endEditing(true)
            handler.accept(code: text)
        }
    }

    @IBAction func closeAction() {
        handler.close()
    }
}

extension LinkDeviceViewController: LinkDeviceBehavior {

}
