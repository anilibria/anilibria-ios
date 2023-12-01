import UIKit

// MARK: - View Controller

final class ConfigurationViewController: BaseViewController {
    @IBOutlet var titleLabel: UILabel!
    
    var handler: ConfigurationEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.didLoad()
    }
    
    override func setupStrings() {
        super.setupStrings()
        titleLabel.text = L10n.Screen.Configuration.title
    }
}

extension ConfigurationViewController: ConfigurationViewBehavior {}
