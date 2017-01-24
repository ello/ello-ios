////
///  RateSpec.swift
//

@testable import Ello
import Quick
import Nimble
import iRate

class RateSpec: QuickSpec {
    override func spec() {
        describe("Rate") {

            let agent = SpecsTrackingAgent()

            beforeEach {
                Tracker.shared.overrideAgent = agent
            }

            afterEach {
                Tracker.shared.overrideAgent = nil
            }

            it("is the iRate delegate") {
                expect(iRate.sharedInstance().delegate) === Rate.sharedRate
            }

            it("requires 3 uses until prompt") {
                expect(iRate.sharedInstance().usesUntilPrompt) == 3
            }

            it("requires 3 custom events until prompt") {
                expect(iRate.sharedInstance().eventsUntilPrompt) == 3
            }

            it("requires 7 days until prompt") {
                expect(iRate.sharedInstance().daysUntilPrompt) == 7
            }

            it("has a reminder period of 7 days") {
                expect(iRate.sharedInstance().remindPeriod) == 7
            }

            it("requires 0 uses per week for prompt") {
                expect(iRate.sharedInstance().usesPerWeekForPrompt) == 0
            }

            it("is not in preview mode") {
                expect(iRate.sharedInstance().previewMode) == false
            }

            it("is not in preview mode") {
                expect(iRate.sharedInstance().previewMode) == false
            }


            it("has the correct labels") {
                expect(iRate.sharedInstance().messageTitle) == "Love Ello?"
                expect(iRate.sharedInstance().message) == ""
                expect(iRate.sharedInstance().updateMessage) == ""
                expect(iRate.sharedInstance().rateButtonLabel) == "Rate us: ⭐️⭐️⭐️⭐️⭐️"
                expect(iRate.sharedInstance().cancelButtonLabel) == "No Thanks"
            }

            context("analytics") {
                it("tracks when it cannot connect to the app store") {
                    let error = NSError(domain: "test", code: 0, userInfo: nil)
                    Rate.sharedRate.iRateCouldNotConnect(toAppStore: error)

                    expect(agent.lastEvent) == "rate prompt could not connect to app store"
                }

                it("tracks when it prompts for a rating") {
                    Rate.sharedRate.iRateDidPromptForRating()

                    expect(agent.lastEvent) == "rate prompt shown"
                }

                it("tracks when the user attempts to rate the app") {
                    Rate.sharedRate.iRateUserDidAttemptToRateApp()

                    expect(agent.lastEvent) == "rate prompt user attempted to rate app"
                }

                it("tracks when it user declines to rate the app") {
                    Rate.sharedRate.iRateUserDidDeclineToRateApp()

                    expect(agent.lastEvent) == "rate prompt user declined to rate app"
                }

                it("tracks when it user requests to be reminded later") {
                    Rate.sharedRate.iRateUserDidRequestReminderToRateApp()

                    expect(agent.lastEvent) == "rate prompt remind me later"
                }

                it("tracks when the app store is opened") {
                    Rate.sharedRate.iRateDidOpenAppStore()

                    expect(agent.lastEvent) == "rate prompt opened app store"
                }
            }
        }
    }
}
