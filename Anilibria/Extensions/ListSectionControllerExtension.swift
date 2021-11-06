import IGListKit

extension ListSectionController {
    func dequeueReusableCell<T: UICollectionViewCell>(of type: T.Type, at index: Int) -> T {
        let cell = self.collectionContext?.dequeueReusableCell(withNibName: type.defaultNibName,
                                                               bundle: nil,
                                                               for: self,
                                                               at: index) as? T
        return cell!
    }
}
