import UIKit

class BaseCollectionCell: UICollectionViewCell {
    // MARK: - Outlets

    @IBOutlet var collectionView: UICollectionView!

    // MARK: - Properties

    public lazy var adapter = CollectionViewAdapter(collectionView: collectionView)

    public var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return self.adapter.scrollViewDelegate
        }
        set {
            self.adapter.scrollViewDelegate = newValue
        }
    }

    // MARK: - Setup

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    func setup() {}

    // MARK: - Methods

    public func set(sections: [any SectionAdapterProtocol]) {
        self.adapter.set(sections: .init(sections))
    }
}
