import Combine
import UIKit
@preconcurrency import WebKit

// MARK: - View Controller

final class CommentsAuthViewController: BaseViewController {
    @IBOutlet var webView: WKWebView!

    var handler: CommentsAuthEventHandler!

    // MARK: - Life cycle

    private lazy var closeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(resource: .iconClose),
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(self.closeAction))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.webView.load(URLRequest(url: URL(string: "https://m.vk.com/login")!))
        self.webView.navigationDelegate = self
    }

    private func setupNavigationBar() {
        self.navigationItem.title = L10n.Screen.Auth.title
        self.navigationItem.setRightBarButtonItems([self.closeButton], animated: false)
    }

    @objc func closeAction() {
        self.handler.back()
    }
}

extension CommentsAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.absoluteString.hasSuffix("feed") == true {
            self.handler.success()
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.handler.pageStartLoading()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.handler.pageFinishLoading()
    }
}

extension CommentsAuthViewController: CommentsAuthViewBehavior {}

private final class CookieObserver: NSObject, WKHTTPCookieStoreObserver {
    private let handler: Action<WKHTTPCookieStore>

    init(handler: @escaping Action<WKHTTPCookieStore>) {
        self.handler = handler
    }

    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        self.handler(cookieStore)
    }
}
