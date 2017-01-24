////
///  OnboardingSpec.swift
//

import Quick
import Nimble
import SwiftyUserDefaults
@testable import Ello


class OnboardingSpec: QuickSpec {
    override func spec() {
        describe("Onboarding") {
            let expectations: [(localIsCurrent: Bool, webIsCurrent: Bool?, showOnboarding: Bool)] = [
                (localIsCurrent: true, webIsCurrent: nil, showOnboarding: true),
                (localIsCurrent: true, webIsCurrent: false, showOnboarding: false),
                (localIsCurrent: true, webIsCurrent: true, showOnboarding: false),
                (localIsCurrent: false, webIsCurrent: nil, showOnboarding: true),
                (localIsCurrent: false, webIsCurrent: false, showOnboarding: false),
                (localIsCurrent: false, webIsCurrent: true, showOnboarding: false),
            ]
            for (localIsCurrent, webIsCurrent, showOnboarding) in expectations {
                let title1: String
                if localIsCurrent { title1 = "localVersion is currentVersion" }
                else { title1 = "localVersion less than currentVersion" }
                let title2: String
                switch webIsCurrent {
                case .none:        title2 = "webVersion is nil"
                case .some(true):  title2 = "webVersion is currentVersion"
                case .some(false): title2 = "webVersion less than currentVersion"
                }
                describe("\(title1) and \(title2)") {
                    it("showOnboarding should be \(showOnboarding)") {
                        if localIsCurrent {
                            GroupDefaults["ViewedOnboardingVersion"] = 1
                        }
                        else {
                            GroupDefaults["ViewedOnboardingVersion"] = 0
                        }
                        let onboarding = Onboarding()

                        var props: [String: AnyObject] = [:]
                        if case let .some(webIsCurrent) = webIsCurrent {
                            props["onboardingVersion"] = (webIsCurrent ? 1 : 0) as AnyObject
                        }
                        let user: User = stub(props)

                        if let webIsCurrent = webIsCurrent {
                            expect(user.onboardingVersion ?? -1) == (webIsCurrent ? 1 : 0)
                        }
                        else {
                            expect(user.onboardingVersion).to(beNil())
                        }
                        expect(onboarding.showOnboarding(user)) == showOnboarding
                    }
                }
            }
        }
    }
}
