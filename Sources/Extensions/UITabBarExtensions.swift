////
///  UITabBarExtensions.swift
//

extension UITabBar {

    var itemViews: [UIView] {
        return subviews.filter { $0 is UIControl }
    }

    func itemPositionsIn(_ view: UIView) -> [CGRect] {
        return itemViews.map { self.convert($0.frame, to: view) }
    }

}
