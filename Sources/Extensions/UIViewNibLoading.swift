////
///  UIViewNibLoading.swift
//

import UIKit

extension UIView {
    class func loadFromNib<T: UIView>() -> T {
        let nib = UINib(nibName: T.readableClassName(), bundle: Bundle(for: T.self))
        let vs = nib.instantiate(withOwner: .none, options: .none)
        return vs[0] as! T
    }

    func loadFromNib<T: UIView>() -> T {
        let nib = UINib(nibName: type(of: self).readableClassName(), bundle: Bundle(for: type(of: self)))
        let vs = nib.instantiate(withOwner: self, options: .none)
        return vs[0] as! T
    }
}
