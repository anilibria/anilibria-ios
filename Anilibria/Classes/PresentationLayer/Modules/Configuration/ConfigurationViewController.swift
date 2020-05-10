import UIKit

// MARK: - View Controller

final class ConfigurationViewController: BaseViewController {
    var handler: ConfigurationEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.didLoad()
    }
}

extension ConfigurationViewController: ConfigurationViewBehavior {}
