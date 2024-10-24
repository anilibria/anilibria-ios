import UIKit

// MARK: - View Controller

final class FilterViewController: BaseCollectionViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet var buttonsContainer: ShadowView!
    @IBOutlet var resetButton: RippleButton!
    @IBOutlet var applyButton: RippleButton!

    var handler: FilterEventHandler!

    private var bag: Any?
    private let dismissManager: PseudoInteractiveDismissManager = .init()

    // MARK: - Life cycle

    override func viewDidLoad() {
        self.defaultBottomInset = 0
        super.viewDidLoad()
        self.collectionView.frame = UIApplication.getWindow()?.frame ?? .zero
        self.handler.didLoad()

        self.dismissManager.attchTo(scroll: self.scrollView) { [weak self] in
            self?.handler.back()
        }

        self.collectionView.layer.cornerRadius = 5
        self.collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.bag = self.collectionView.observe(\UICollectionView.contentSize) { [weak self] _, _ in
            if let height = self?.collectionView.contentSize.height {
                self?.collectionHeightConstraint.constant = height + 80
            }
        }
    }
    
    override func setupStrings() {
        super.setupStrings()
        resetButton.setTitle(L10n.Buttons.reset, for: .normal)
        applyButton.setTitle(L10n.Buttons.apply, for: .normal)
    }

    @IBAction func backAction(_ sender: Any) {
        self.handler.back()
    }

    @IBAction func resetAction(_ sender: Any) {
        self.handler.reset()
    }

    @IBAction func applyAction(_ sender: Any) {
        self.handler.apply()
    }
}

extension FilterViewController: FilterViewBehavior {
    func set(sorting: FilterSingleItem?, years: FilterRangeItem?, items: [FilterTagsItem]) {
        var sections: [any SectionAdapterProtocol] = [
            SectionAdapter([
                FilterHeaderAdapter()
            ])
        ]
        if let sorting {
            sections.append(SectionAdapter([
                FilterSingleItemAdapter(viewModel: sorting)
            ]))
        }

        if let years {
            sections.append(SectionAdapter([
                FilterRangeItemAdapter(viewModel: years)
            ]))
        }

        sections += items.map { FilterTagsSectionAdapter(item: $0) }

        reload(sections: sections, animated: false)
    }
}
