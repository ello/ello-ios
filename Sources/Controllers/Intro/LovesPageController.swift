////
///  LovesPageController.swift
//

import Foundation

class LovesPageController: IntroPageController {
    @IBAction func didTouchGetStarted(_ sender: AnyObject) {
        parent?.dismiss(animated: false, completion: nil)
    }
}
