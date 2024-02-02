import UIKit

// MARK: - View Controller

final class ChoiceSheetViewController: BaseCollectionViewController {
    @IBOutlet var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet var doneButton: UIButton!

    var handler: ChoiceSheetEventHandler!
    private var bag: Any?

    // MARK: - Life cycle

    override func viewDidLoad() {
        self.defaultBottomInset = 0
        super.viewDidLoad()
        self.handler.didLoad()

        self.bag = self.collectionView.observe(\UICollectionView.contentSize) { [weak self] _, _ in
            if let height = self?.collectionView.contentSize.height {
                self?.collectionHeightConstraint.constant = height
            }
        }
    }
    
    override func setupStrings() {
        super.setupStrings()
        doneButton.setTitle(L10n.Buttons.done, for: .normal)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return.portrait
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    // MARK: - Actions

    @IBAction func backAction(_ sender: Any) {
        self.handler.back()
    }
}

extension ChoiceSheetViewController: ChoiceSheetViewBehavior {
    func set(items: [ChoiceGroup]) {
        let sections = ChoiceCellAdapterSectionFactory.create(for: items)
        self.reload(sections: sections)
    }
}
