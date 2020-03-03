////
///  Onboarding.swift
//

import SwiftyUserDefaults


class Onboarding {
    static let currentVersion = 3
    static let minCreatorTypeVersion = 1
    static let shared = Onboarding()

    func updateVersionToLatest() {
        ProfileService().updateUserProfile([.webOnboardingVersion: Onboarding.currentVersion])
            .ignoreErrors()
    }

    // only show if onboardingVersion is nil
    func shouldShowOnboarding(_ user: User) -> Bool {
        return user.onboardingVersion == nil
    }

    // only show if onboardingVersion is set and < 3
    // (if it isn't set, we will show the entire onboarding flow)
    func shouldShowCreatorType(_ user: User) -> Bool {
        if let onboardingVersion = user.onboardingVersion {
            return onboardingVersion < 3
        }
        return false
    }

}
