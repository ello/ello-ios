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
            let expectations:
                [(currentValue: Int?, shouldShowOnboarding: Bool, shouldShowCreatorType: Bool)] = [
                    (currentValue: nil, shouldShowOnboarding: true, shouldShowCreatorType: false),
                    (
                        currentValue: Onboarding.currentVersion - 1, shouldShowOnboarding: false,
                        shouldShowCreatorType: true
                    ),
                    (
                        currentValue: Onboarding.currentVersion, shouldShowOnboarding: false,
                        shouldShowCreatorType: false
                    ),
                ]
            for (currentValue, shouldShowOnboarding, shouldShowCreatorType) in expectations {
                let value = currentValue.map { String($0) } ?? "nil"
                let user: User
                if let currentValue = currentValue {
                    user = User.stub(["onboardingVersion": currentValue])
                }
                else {
                    user = User.stub([:])
                }

                describe("Onboarding.shouldShowOnboarding(\(value))") {
                    it("should be \(shouldShowOnboarding)") {
                        expect(Onboarding.shared.shouldShowOnboarding(user)) == shouldShowOnboarding
                    }
                }

                describe("Onboarding.shouldShowCreatorType(\(value))") {
                    it("should be \(shouldShowCreatorType)") {
                        expect(Onboarding.shared.shouldShowCreatorType(user))
                            == shouldShowCreatorType
                    }
                }
            }
        }
    }
}
