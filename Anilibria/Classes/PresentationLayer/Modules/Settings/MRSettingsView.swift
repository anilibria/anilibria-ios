import UIKit
import Combine

// MARK: - View Controller

final class SettingsViewController: BaseViewController {
    @IBOutlet var commonTitleLabel: UILabel!

    @IBOutlet var commonStackView: UIStackView!
    @IBOutlet var aboutTitleLabel: UILabel!
    @IBOutlet var appNameLabel: UILabel!
    @IBOutlet var appVersionLabel: UILabel!

    var handler: SettingsEventHandler!

    // MARK: - Life cycle

    override func setupStrings() {
        super.setupStrings()
        self.handler.didLoad()
        self.navigationItem.title = L10n.Screen.Settings.title
        self.commonTitleLabel.text = L10n.Screen.Settings.common
        self.aboutTitleLabel.text = L10n.Screen.Settings.aboutApp
    }
}

extension SettingsViewController: SettingsViewBehavior {
    func set(name: String, version: String) {
        self.appNameLabel.text = name
        self.appVersionLabel.text = version
    }

    func set(common items: [SettingsControlItem]) {
        commonStackView.arrangedSubviews.forEach {
            commonStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        items.forEach {
            let view = SettingsControlView()
            view.configure(item: $0)
            commonStackView.addArrangedSubview(view)
        }
    }
}
