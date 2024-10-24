import UIKit
@preconcurrency import WebKit

// MARK: - View Controller

final class SocialAuthViewController: BaseViewController {
    @IBOutlet var webView: WKWebView!

    var handler: SocialAuthEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        self.setupNavigationBar()
        self.handler.didLoad()
    }

    private func setupNavigationBar() {
        self.navigationItem.title = L10n.Screen.Auth.title
    }

    @objc func closeAction() {
        self.handler.back()
    }
}

extension SocialAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var policy: WKNavigationActionPolicy = .allow
        if let url = navigationAction.request.url {
            if self.handler.redirect(url: url) {
                policy = .cancel
            }
        }
        decisionHandler(policy)
    }
}

extension SocialAuthViewController: SocialAuthViewBehavior {
    func set(url: URL) {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { [weak self] records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                 for: records.filter { $0.displayName.contains("vk") },
                                 completionHandler: { self?.webView.load(URLRequest(url: url)) })
        }
    }
}
