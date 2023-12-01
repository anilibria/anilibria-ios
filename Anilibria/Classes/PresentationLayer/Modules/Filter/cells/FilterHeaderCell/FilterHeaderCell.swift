import UIKit

public final class FilterHeaderCell: UICollectionViewCell {
    @IBOutlet var filterTitleLabel: UILabel!
    @IBOutlet var releaseTitleLabel: UILabel!
    @IBOutlet var releaseSwitchView: UISwitch!
    @IBOutlet var sortTitleLabel: UILabel!
    @IBOutlet var segmentControl: UISegmentedControl!

    private var changeHandler: Action<SeriesFilter>?
    private var item: FilterHeaderItem?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        filterTitleLabel.text = L10n.Screen.Filter.title
        releaseTitleLabel.text = L10n.Screen.Filter.complete
        sortTitleLabel.text = L10n.Screen.Filter.sotring
        segmentControl.setTitle(L10n.Screen.Filter.Sotring.popularity, forSegmentAt: 0)
        segmentControl.setTitle(L10n.Screen.Filter.Sotring.newest, forSegmentAt: 1)
    }

    public func configure(_ item: FilterHeaderItem, handler: ((SeriesFilter) -> Void)?) {
        self.segmentControl.selectedSegmentIndex = item.filter.sorting == .mostPopularity ? 0 : 1
        self.changeHandler = handler
        self.releaseSwitchView.setOn(item.filter.isCompleted, animated: false)
        self.item = item
    }

    @IBAction func segmentAction(_ sender: Any) {
        let index = self.segmentControl.selectedSegmentIndex
        let value: SeriesSorting = index == 0 ? .mostPopularity : .newest
        self.item?.filter.sorting = value
        if let filter = self.item?.filter {
            self.changeHandler?(filter)
        }
    }

    @IBAction func switchAction(_ sender: Any) {
        self.item?.filter.isCompleted = self.releaseSwitchView.isOn
        if let filter = self.item?.filter {
            self.changeHandler?(filter)
        }
    }
}
