import UIKit

final class ScheduleSeriesCellAdapter: BaseCellAdapter<Series> {
    private var size: CGSize?
    private var selectAction: ((Series) -> Void)?

    init(viewModel: Series, seclect: ((Series) -> Void)?) {
        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

    override func sizeForItem(at index: IndexPath,
                              collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        if let size = size, size.width == collectionView.frame.width {
            return size
        }

        let width: CGFloat = collectionView.frame.width
        let size = ScheduleSeriesCell.size(with: width, gap: 16)
        self.size = size
        return size
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: ScheduleSeriesCell.self, for: index)
        cell.configure(viewModel)
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.selectAction?(viewModel)
    }
}

final class ScheduleSeriesSectionAdapter: SectionAdapter {
    override init(_ items: [any CellAdapterProtocol]) {
        super.init(items)
        self.insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        self.minimumInteritemSpacing = 16
        self.minimumLineSpacing = 8
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 insetForSectionAt section: Int) -> UIEdgeInsets {
        self.insets
    }
}
