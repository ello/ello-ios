////
///  Rate.swift
//

import StoreKit


class Rate: NSObject {
    static let shared = Rate()

    func prompt() {
        SKStoreReviewController.requestReview()
        Tracker.shared.ratePromptShown()
    }
}
