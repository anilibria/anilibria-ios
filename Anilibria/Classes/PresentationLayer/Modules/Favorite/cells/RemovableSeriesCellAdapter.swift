import UIKit

struct RemovableSeriesCellAdapterHandler {
    let select: ((Series) -> Void)?
    let delete: ((Series) -> Void)?
}

final class RemovableSeriesCellAdapter: BaseCellAdapter<Series> {
    private let handler: RemovableSeriesCellAdapterHandler

    init(viewModel: Series, handler: RemovableSeriesCellAdapterHandler) {
        self.handler = handler
        super.init(viewModel: viewModel)
    }

    override func sizeForItem(at index: IndexPath,
                              collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 140)
    }

    override func cellForItem(at index: IndexPath, context: CollectionContext) -> UICollectionViewCell? {
        let cell = context.dequeueReusableNibCell(type: RemovableSeriesCell.self, for: index)
        cell.configure(viewModel)
        cell.setDelete { [handler, viewModel] in
            handler.delete?(viewModel)
        }
        return cell
    }

    override func didSelect(at index: IndexPath) {
        self.handler.select?(viewModel)
    }
}
