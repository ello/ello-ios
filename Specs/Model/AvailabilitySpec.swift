////
///  AvailabilitySpec.swift
//

@testable import Ello
import Quick
import Nimble


class AvailabilitySpec: QuickSpec {
    override func spec() {
        it("converts from JSON") {
            let parsedAvailability = stubbedJSONData("availability", "availability")
            let availability = Availability.fromJSON(parsedAvailability) as! Availability

            expect(availability.isUsernameAvailable).to(beTrue())
            expect(availability.isEmailAvailable).to(beTrue())
            expect(availability.isInvitationCodeAvailable).to(beTrue())
            expect(availability.usernameSuggestions.count) == 3
            expect(availability.emailSuggestion) == "lana@gmail.com"
        }
    }
}
