////
///  AppViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AppViewControllerSpec: QuickSpec {
    override func spec() {
        describe("AppViewController") {
            var subject: AppViewController!

            beforeEach {
                subject = AppViewController()
                let _ = subject.view
            }

            describe("navigateToDeeplink(:)") {

                let agent = SpecsTrackingAgent()

                beforeEach {
                    Tracker.shared.overrideAgent = agent
                }

                afterEach {
                    Tracker.shared.overrideAgent = nil
                }

                it("tracks deep link") {
                    subject.navigateToDeepLink("http://ello.co/deeplink")

                    expect(agent.lastEvent) == "Deep Link Visited"
                    expect(agent.lastProperties["path"] as? String) == "http://ello.co/deeplink"
                }
            }
        }
    }
}
