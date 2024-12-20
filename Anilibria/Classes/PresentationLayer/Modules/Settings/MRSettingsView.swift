import UIKit

// MARK: - View Controller

final class SettingsViewController: BaseViewController {
    @IBOutlet var commonTitleLabel: UILabel!
    @IBOutlet var languageTitleLabel: UILabel!
    @IBOutlet var selectedLanguageLabel: UILabel!
    @IBOutlet var qaualityTitleLabel: UILabel!
    @IBOutlet var selectedQualityLabel: UILabel!
    @IBOutlet var appearanceTitleLabel: UILabel!
    @IBOutlet var selectedAppearanceLabel: UILabel!
    @IBOutlet var orientationContainerView: UIView!
    @IBOutlet var orientationTitleLabel: UILabel!
    @IBOutlet var selectedOrientationLabel: UILabel!

    @IBOutlet var aboutTitleLabel: UILabel!
    @IBOutlet var appNameLabel: UILabel!
    @IBOutlet var appVersionLabel: UILabel!

    var handler: SettingsEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad {
            orientationContainerView.isHidden = true
        }
        self.handler.didLoad()
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Settings.title
        self.commonTitleLabel.text = L10n.Screen.Settings.common
        self.languageTitleLabel.text = L10n.Screen.Settings.language
        self.qaualityTitleLabel.text = L10n.Screen.Settings.videoQuality
        self.aboutTitleLabel.text = L10n.Screen.Settings.aboutApp
        self.appearanceTitleLabel.text = L10n.Common.appearance
        self.orientationTitleLabel.text = L10n.Common.orientation
    }

    @IBAction func qualityAction(_ sender: Any) {
        self.handler.selectQuality()
    }
    
    @IBAction func languageAction(_ sender: Any) {
        self.handler.selectLanguage()
    }

    @IBAction func appearanceAction(_ sender: Any) {
        self.handler.selectAppearance()
    }

    @IBAction func orientationAction(_ sender: Any) {
        self.handler.selectOrientation()
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

    func set(appearance: InterfaceAppearance) {
        self.selectedAppearanceLabel.text = appearance.title
    }

    func set(orientation: InterfaceOrientation) {
        self.selectedOrientationLabel.text = orientation.title
    }
}
