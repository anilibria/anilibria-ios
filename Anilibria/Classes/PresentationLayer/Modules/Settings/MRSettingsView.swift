import UIKit

// MARK: - View Controller

final class SettingsViewController: BaseViewController {
    @IBOutlet var commonTitleLabel: UILabel!
    @IBOutlet var languageTitleLabel: UILabel!
    @IBOutlet var selectedLanguageLabel: UILabel!
    @IBOutlet var qaualityTitleLabel: UILabel!
    @IBOutlet var selectedQualityLabel: UILabel!
    
    @IBOutlet var aboutTitleLabel: UILabel!
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
        self.languageTitleLabel.text = L10n.Screen.Settings.language
        self.qaualityTitleLabel.text = L10n.Screen.Settings.videoQuality
        self.aboutTitleLabel.text = L10n.Screen.Settings.aboutApp
    }

    @IBAction func qualityAction(_ sender: Any) {
        self.handler.selectQuality()
    }
    
    @IBAction func languageAction(_ sender: Any) {
        self.handler.selectLanguage()
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
    
    func set(language: Language) {
        self.selectedLanguageLabel.text = language.name
    }
}
