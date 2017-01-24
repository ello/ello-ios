////
///  UICollectionViewExtensions.swift
//

import Foundation

extension UICollectionView {
    func lastIndexPathForSection(_ section: Int) -> IndexPath? {
        if self.numberOfItems(inSection: section) > 0 {
            return IndexPath(item: self.numberOfItems(inSection: section) - 1, section: section)
        }
        return nil
    }
}

extension UICollectionViewCell {
    var indexPath: IndexPath? {
        var superview: UIView? = self.superview
        while superview != nil {
            if superview is UICollectionView { break }
            superview = superview?.superview
        }

        guard let collectionView = superview as? UICollectionView else { return nil }

        for path in collectionView.indexPathsForVisibleItems {
            guard
                let cell = collectionView.cellForItem(at: path), cell == self
            else { continue }

            return path
        }
        return nil
    }
}
