import UIKit

public protocol AppTheme {
    func apply()

    // MARK: - Colors

    var defaultFont: AppFont? { get }
}

public struct MainTheme: AppTheme {
    public static var shared: AppTheme = MainTheme()

    private init() {}

    public func apply() {
        self.configureNavBar()
        self.configureTextView()
        self.configureCollectionView()
    }

    func configureNavBar() {
        let navbar = UINavigationBar.appearance()
        navbar.isTranslucent = true
        navbar.isOpaque = false
        navbar.titleTextAttributes = [
            .foregroundColor: UIColor(resource: .Text.main),
            .font: UIFont.font(ofSize: 17, weight: .medium)
        ]
        navbar.barTintColor = UIColor(resource: .Surfaces.background)
        navbar.tintColor = UIColor(resource: .Tint.main)
        navbar.shadowImage = UIImage()
    }

    func configureTextView() {
        UITextView.appearance().tintColor = UIColor(resource: .Tint.main)
        UITextField.appearance().tintColor = UIColor(resource: .Tint.main)
    }

    func configureCollectionView() {
        UICollectionView.appearance().isPrefetchingEnabled = false
    }

    // MARK: - Font

    public var defaultFont: AppFont?
}
