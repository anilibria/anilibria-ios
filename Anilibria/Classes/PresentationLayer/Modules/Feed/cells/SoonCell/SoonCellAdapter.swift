import UIKit

final class SoonCellAdapter: BaseCellAdapter<Schedule> {
    private var size: CGSize?
    private var selectAction: ((Series) -> Void)?

    init(viewModel: Schedule, seclect: ((Series) -> Void)?) {
        self.selectAction = seclect
        super.init(viewModel: viewModel)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: SoonCell.self, for: index)
        cell.configure(viewModel, handler: selectAction)
        return cell
    }
}
