import UIKit
import Combine

final class SoonCell: BaseCollectionCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var leftButton: RippleButton!
    @IBOutlet var rightButton: RippleButton!

    private var langSubscriber: AnyCancellable?
    private var sizeSubscriber: AnyCancellable?
    private var offsetSubscriber: AnyCancellable?

    override func awakeFromNib() {
        super.awakeFromNib()
        let conf = UICollectionViewCompositionalLayoutConfiguration()
        conf.scrollDirection = .horizontal
        self.adapter.layout?.configuration = conf
        self.collectionView.contentInset.right = 16
        leftButton.cornerRadius = 8
        leftButton.clipsToBounds = true
        rightButton.cornerRadius = 8
        rightButton.clipsToBounds = true

        #if targetEnvironment(macCatalyst)
        leftButton.isHidden = false
        rightButton.isHidden = false
        #endif
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        langSubscriber = nil
        sizeSubscriber = nil
        offsetSubscriber = nil
    }

    func configure(_ item: Schedule, handler: ((Series) -> Void)?) {
        self.leftButton.alpha = 0
        self.leftButton.alpha = 0
        self.collectionView.contentOffset = .zero
        
        langSubscriber = Language.languageChanged.sink { [weak self] in
            self?.titleLabel.text = self?.generateTitle(item.day)
        }
        self.titleLabel.text = self.generateTitle(item.day)

        self.reload(sections: [
            SoonSectionAdapter(
                item.items.map { ScheduleSeriesCellAdapter(viewModel: $0, seclect: handler) }
            )
        ])
        
        sizeSubscriber = collectionView.publisher(for: \.contentSize).sink { [weak self] _ in
            self?.checkSize()
        }
        self.checkSize()
    }

    @IBAction func leftAction(_ sender: Any) {
        var newOffset = self.collectionView.contentOffset
        newOffset.x -= collectionView.frame.width
        if newOffset.x < 0 {
            newOffset.x = 0
        }
        self.collectionView.setContentOffset(newOffset, animated: true)
    }

    @IBAction func rightAction(_ sender: Any) {
        let frameWidth = self.collectionView.frame.width
        var newOffset = self.collectionView.contentOffset
        let endOffset = self.getEndOffset()
        newOffset.x += frameWidth
        if newOffset.x > endOffset {
            newOffset.x = endOffset
        }
        self.collectionView.setContentOffset(newOffset, animated: true)
    }

    private func getEndOffset() -> CGFloat {
        let width = self.collectionView.contentSize.width
            + self.collectionView.contentInset.right
            + self.collectionView.contentInset.left
        let frameWidth = self.collectionView.frame.width
        return width - frameWidth
    }

    private func checkSize() {
        if self.collectionView.contentSize.width > self.collectionView.frame.width {
            self.observeOffset()
        }
    }

    private func observeOffset() {
        offsetSubscriber = self.collectionView.publisher(for: \.contentOffset).sink { [weak self] _ in
            self?.handleOffset()
        }
        self.handleOffset()
    }

    private func handleOffset() {
        let offset = self.collectionView.contentOffset.x
        let endOffset = self.getEndOffset()
        if offset <= 0 {
            self.visible(view: self.leftButton, value: false)
            self.visible(view: self.rightButton, value: true)
        } else if floor(offset) >= floor(endOffset) {
            self.visible(view: self.leftButton, value: true)
            self.visible(view: self.rightButton, value: false)
        } else {
            self.visible(view: self.leftButton, value: true)
            self.visible(view: self.rightButton, value: true)
        }
    }

    private func visible(view: UIView, value: Bool) {
        let alpha: CGFloat = value ? 1 : 0
        if view.alpha == alpha {
            return
        }
        UIView.animate(withDuration: 0.2) {
            view.alpha = value ? 1 : 0
        }
    }

    private func generateTitle(_ weekDay: WeekDay?) -> String {
        guard let weekDay else { return "" }
        
        let current = WeekDay.getCurrent()
        let soonTitle = L10n.Screen.Feed.soonTitle

        if weekDay == current {
            return "\(soonTitle) \(L10n.Common.today.lowercased())"
        }
        let msk = L10n.Common.mskTimeZone
        return "\(soonTitle) \(weekDay.onDay) \(msk)"
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
