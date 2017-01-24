////
///  AlertViewControllerKeyboardExtension.swift
//

import Foundation

extension AlertViewController {

    func keyboardUpdateFrame(_ keyboard: Keyboard) {
        let availHeight = UIWindow.mainWindow.frame.height - (Keyboard.shared.active ? Keyboard.shared.endFrame.height : 0)
        let top = max(15, (availHeight - view.frame.height) / 2)
        animateWithKeyboard {
            self.view.frame.origin.y = top

            let bottomInset = Keyboard.shared.keyboardBottomInset(inView: self.tableView)
            self.tableView.contentInset.bottom = bottomInset
            self.tableView.scrollIndicatorInsets.bottom = bottomInset
            self.tableView.isScrollEnabled = (bottomInset > 0 || self.view.frame.height == MaxHeight)
        }
    }
}
