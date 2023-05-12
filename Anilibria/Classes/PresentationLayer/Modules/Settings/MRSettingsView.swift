import UIKit

// MARK: - View Controller

final class SettingsViewController: BaseViewController {
    @IBOutlet var prefferedTitleLabel: UILabel!
    @IBOutlet var qualityTitleLabel: UILabel!
    @IBOutlet var qualityLabel: UILabel!
    @IBOutlet var audioTitleLabel: UILabel!
    @IBOutlet var audioLabel: UILabel!
    @IBOutlet var subtitleTrackTitleLabel: UILabel!
    @IBOutlet var subtitleTrackLabel: UILabel!
    
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
        self.prefferedTitleLabel.text = L10n.Screen.Settings.preffered
        self.qualityTitleLabel.text = L10n.Common.quality
        self.audioTitleLabel.text = L10n.Common.audioTrack
        self.subtitleTrackTitleLabel.text = L10n.Common.sublitleTrack
        self.aboutAppTitleLabel.text = L10n.Screen.Settings.aboutApp
    }

    @IBAction func qualityAction(_ sender: Any) {
        self.handler.selectQuality()
    }
    
    @IBAction func audioAction(_ sender: Any) {
        self.handler.selectAudio()
    }
    
    @IBAction func subtitleAction(_ sender: Any) {
        self.handler.selectSubtitle()
    }
}

extension SettingsViewController: SettingsViewBehavior {
    func set(name: String, version: String) {
        self.appNameLabel.text = name
        self.appVersionLabel.text = version
    }

    func set(quality: VideoQuality) {
        self.qualityLabel.text = quality.name
    }
    
    func set(audio track: String) {
        self.audioLabel.text = track
    }
    
    func set(subtitle track: String) {
        self.subtitleTrackLabel.text = track
    }
}
