import IGListKit
import UIKit

// MARK: - View Controller

final class ScheduleViewController: BaseCollectionViewController {
    var handler: ScheduleEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.didLoad()
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = L10n.Screen.Feed.schedule
    }

    override func adapterCreators() -> [AdapterCreator] {
        return [
            TitleCellAdapterCreator(),
            ScheduleSeriesCellAdapterCreator(.init(select: { [weak self] item in
                self?.handler.select(series: item)
            }))
        ]
    }
}

extension ScheduleViewController: ScheduleViewBehavior {
    func set(items: [ListDiffable]) {
        self.items = items
        self.update()
    }
}
