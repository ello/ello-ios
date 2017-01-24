////
///  AvailabilityServiceSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class AvailabilityServiceSpec: QuickSpec {
    override func spec() {
        describe("availability") {
            it("succeeds") {
                var expectedAvailability: Availability? = .none
                let content = ["username": "somename"]
                AvailabilityService().availability(content, success: { availability in
                    expectedAvailability = availability
                }, failure: { _ in })
                expect(expectedAvailability).toNot(beNil())
            }

            it("fails") {
                ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                var failed = false
                let content = ["username": "somename"]
                AvailabilityService().availability(content, success: { _ in }, failure: { _, _ in
                    failed = true
                })
                expect(failed) == true
            }
        }
    }
}
