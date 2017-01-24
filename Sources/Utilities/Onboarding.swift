////
///  Onboarding.swift
//

import SwiftyUserDefaults


private let _sharedInstance = Onboarding()
private let _currentVersion = 2

class Onboarding {
    static var currentVersion: Int {
        return _currentVersion
    }

    func updateVersionToLatest() {
        ProfileService().updateUserProfile(["web_onboarding_version": _currentVersion as AnyObject], success: { _ in }, failure: { _ in })
    }

    class func shared() -> Onboarding {
        return _sharedInstance
    }

    init() {
    }

    // only show if webVersion is nil
    func showOnboarding(_ user: User) -> Bool {
        return user.onboardingVersion == nil
    }

}
