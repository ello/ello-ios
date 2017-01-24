////
///  ShareAlertViewControllerOverrides.swift
//

import Foundation

extension AlertViewController {
    // do not reference anything in the Keyboard
    // App Extensions are prohibited from using
    // some APIs
    func keyboardUpdateFrame(_ keyboard: Keyboard) {
    }
}
