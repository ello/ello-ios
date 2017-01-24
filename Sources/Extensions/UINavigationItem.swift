////
///  UINavigationItem.swift
//

import Foundation

extension UINavigationItem {

    func fixNavBarItemPadding() {
        if let rightBarButtonItems = self.rightBarButtonItems {
            let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            negativeSpacer.width = -22

            self.rightBarButtonItems = [negativeSpacer] + rightBarButtonItems
        }

        if let leftBarButtonItems = self.leftBarButtonItems {
            let negativeSpacer = UIBarButtonItem.spacer(width: -17)
            self.leftBarButtonItems = [negativeSpacer] + leftBarButtonItems
        }
    }

    func areRightButtonsTheSame(_ newItems: [UIBarButtonItem]) -> Bool {
        guard let rightItems = self.rightBarButtonItems else { return false }
        guard newItems.count == rightItems.count else { return false }
        return newItems.enumerated().all { (index, item) in
            return item.action =?= rightItems[index].action
        }
    }

}
