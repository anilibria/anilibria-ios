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
}

extension ScheduleViewController: ScheduleViewBehavior {
    func set(items: [Schedule]) {
        let sections = items.reduce([any SectionAdapterProtocol]()) { result, item in
            result + [SectionAdapter([TitleCellAdapter(viewModel: item.title)]),
                      ScheduleSeriesSectionAdapter(
                        item.items.map { ScheduleSeriesCellAdapter(viewModel: $0, seclect: { [weak self] series in
                            self?.handler.select(series: series)
                        })}
                      )]
        }

        self.set(sections: sections)
    }
}
