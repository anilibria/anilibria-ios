import UIKit

// MARK: - View Controller

final class SettingsViewController: BaseViewController {
    @IBOutlet var commonTitleLabel: UILabel!
    @IBOutlet var selectedQualityTitleLabel: UILabel!
    @IBOutlet var selectedQualityLabel: UILabel!
    @IBOutlet var aboutAppTitleLabel: UILabel!
    @IBOutlet var appNameLabel: UILabel!
    @IBOutlet var appVersionLabel: UILabel!

    var handler: SettingsEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.didLoad()
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Settings.title
        self.commonTitleLabel.text = L10n.Screen.Settings.common
        self.selectedQualityTitleLabel.text = L10n.Common.quality
        self.aboutAppTitleLabel.text = L10n.Screen.Settings.aboutApp
    }

    @IBAction func qualityAction(_ sender: Any) {
        self.handler.selectQuality()
    }
}

extension SettingsViewController: SettingsViewBehavior {
    func set(name: String, version: String) {
        self.appNameLabel.text = name
        self.appVersionLabel.text = version
    }

    func set(quality: VideoQuality) {
        self.selectedQualityLabel.text = quality.name
    }
}
