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
        navbar.tintColor = .Tint.main
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .Surfaces.background
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.Text.main,
            .font: UIFont.font(ofSize: 17, weight: .medium)
        ]
        appearance.shadowColor = .clear

        navbar.standardAppearance = appearance
        navbar.scrollEdgeAppearance = appearance
    }

    func configureTextView() {
        UITextView.appearance().tintColor = .Tint.main
        UITextField.appearance().tintColor = .Tint.main
        UICollectionView.appearance().backgroundColor = .clear
    }

    func configureCollectionView() {
        UICollectionView.appearance().isPrefetchingEnabled = false
    }

    // MARK: - Font

    public var defaultFont: AppFont?
}
