import UIKit

final class SoonCell: BaseCollectionCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var leftView: UIView!
    @IBOutlet var rightView: UIView!

    private var handler: SoonCellAdapterHandler?
    private var bag: Any?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.contentInset.right = 16
    }

    func configure(_ item: Schedule, handler: SoonCellAdapterHandler?) {
        self.leftView.alpha = 0
        self.rightView.alpha = 0
        self.collectionView.contentOffset = .zero

        if let day = item.day {
            self.titleLabel.text = self.generateTitle(day)
        } else {
            self.titleLabel.text = ""
        }
        self.handler = handler
        self.items = item.items
        self.reload()

        self.bag = self.collectionView.observe(\.contentSize) { [weak self] (_, _) in
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
        self.bag = self.collectionView.observe(\.contentOffset) { [weak self] (_, _) in
            self?.handleOffset()
        }
        self.handleOffset()
    }

    private func handleOffset() {
        let offset = self.collectionView.contentOffset.x
        let endOffset = self.getEndOffset()
        if offset <= 0 {
            self.visible(view: self.leftView, value: false)
            self.visible(view: self.rightView, value: true)
        } else if floor(offset) >= floor(endOffset) {
            self.visible(view: self.leftView, value: true)
            self.visible(view: self.rightView, value: false)
        } else {
            self.visible(view: self.leftView, value: true)
            self.visible(view: self.rightView, value: true)
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

    private func generateTitle(_ weekDay: WeekDay) -> String {
        let current = WeekDay.getCurrent()
        let soonTitle = L10n.Screen.Feed.soonTitle

        if weekDay == current {
            return "\(soonTitle) \(L10n.Common.today.lowercased())"
        }
        let msk = L10n.Common.mskTimeZone
        return "\(soonTitle) \(weekDay.onDay) \(msk)"
    }

    static func height(with width: CGFloat) -> CGFloat {
        let width = Sizes.adapt(width)
        let height = (((width - 64)/3) * 10) / 7
        return height + 70
    }

    override func adapterCreators() -> [AdapterCreator] {
        return [
            ScheduleSeriesCellAdapterCreator(.init(select: { [weak self] item in
                self?.handler?.select?(item)
            }))
        ]
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
