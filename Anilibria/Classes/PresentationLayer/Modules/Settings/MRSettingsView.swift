import UIKit

// MARK: - View Controller

final class SettingsViewController: BaseViewController {
    @IBOutlet var selectedQualityLabel: UILabel!
    @IBOutlet var appNameLabel: UILabel!
    @IBOutlet var appVersionLabel: UILabel!
    @IBOutlet var globalNotifySwitch: UISwitch!

    var handler: SettingsEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.didLoad()
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Settings.title
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

    func set(global: Bool, animated: Bool) {
        self.globalNotifySwitch.setOn(global, animated: animated)
    }
}
