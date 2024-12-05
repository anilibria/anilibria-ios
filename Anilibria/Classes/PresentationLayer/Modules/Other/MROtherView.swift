import UIKit

// MARK: - View Controller

final class OtherViewController: BaseViewController {
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var authButton: UIButton!
    @IBOutlet var linksStakView: UIStackView!

    @IBOutlet var linkDeviceLabel: UILabel!
    @IBOutlet var linkDeviceView: UIView!
    @IBOutlet var historyTitleLabel: UILabel!
    @IBOutlet var historyView: UIView!
    @IBOutlet var teamTitleLabel: UILabel!
    @IBOutlet var donateTitleLabel: UILabel!
    @IBOutlet var settingsTitleLabel: UILabel!

    var handler: OtherEventHandler!

    override var isNavigationBarVisible: Bool { false }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

		if UIDevice.current.userInterfaceIdiom == .pad {
			historyView.isHidden = true
		}
    }
    
    override func setupStrings() {
        super.setupStrings()
        handler.didLoad()
        linkDeviceLabel.text = L10n.Screen.LinkDevice.title
        historyTitleLabel.text = L10n.Screen.Feed.history
        teamTitleLabel.text = L10n.Screen.Other.team
        donateTitleLabel.text = L10n.Screen.Other.donate
        settingsTitleLabel.text = L10n.Screen.Settings.title
    }

    // MARK: - Actions

    @IBAction func loginLogOutAction(_ sender: Any) {
        self.handler.loginOrLogout()
    }

    @IBAction func historyAction(_ sender: Any) {
        self.handler.history()
    }

    @IBAction func teamAction(_ sender: Any) {
        self.handler.team()
    }

    @IBAction func donateAction(_ sender: Any) {
        self.handler.donate()
    }

    @IBAction func settingsAction(_ sender: Any) {
        self.handler.settings()
    }

    @IBAction func linkDeviceAction(_ sender: Any) {
        self.handler.linkDevice()
    }
}

extension OtherViewController: OtherViewBehavior {
    func set(user: User?, loading: Bool) {
        self.userNameLabel.isHidden = loading
        self.authButton.isHidden = loading
        self.userNameLabel.text = user?.name ?? L10n.Common.guest
        if user == nil {
            self.authButton.setTitle(L10n.Buttons.signIn, for: .normal)
            self.linksStakView.isHidden = true
        } else {
            self.authButton.setTitle(L10n.Buttons.signOut, for: .normal)
            self.linksStakView.isHidden = false
        }
    }

    func set(links: [LinkData]) {
        let views = links.lazy.compactMap { item -> LinkView? in
            let view = LinkView.fromNib()
            view?.configure(item)
            view?.setTap { [weak self] in
                self?.handler.tap(link: $0)
            }
            return view
        }
        self.linksStakView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        for view in views {
            self.linksStakView.addArrangedSubview(view)
        }
    }
}
