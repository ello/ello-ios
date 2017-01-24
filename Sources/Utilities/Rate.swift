////
///  Rate.swift
//

import Foundation
import iRate

class Rate: NSObject {

    static let sharedRate = Rate()

    func setup() {
        iRate.sharedInstance().delegate = self
        iRate.sharedInstance().onlyPromptIfLatestVersion = true
        iRate.sharedInstance().previewMode = false
        iRate.sharedInstance().messageTitle = InterfaceString.Rate.Title
        iRate.sharedInstance().message = ""
        iRate.sharedInstance().updateMessage = ""
        iRate.sharedInstance().rateButtonLabel = InterfaceString.Rate.Continue
        iRate.sharedInstance().cancelButtonLabel = InterfaceString.Rate.Cancel
        iRate.sharedInstance().usesUntilPrompt = 3
        iRate.sharedInstance().eventsUntilPrompt = 3
        iRate.sharedInstance().daysUntilPrompt = 7
        iRate.sharedInstance().usesPerWeekForPrompt = 0
        iRate.sharedInstance().remindPeriod = 7
    }

    func prompt() {
        iRate.sharedInstance().promptForRating()
    }

    func logEvent() {
        iRate.sharedInstance().logEvent(false)
    }
}

extension Rate: iRateDelegate {
    func iRateCouldNotConnect(toAppStore error: Error!){
        Tracker.shared.ratePromptCouldNotConnectToAppStore()
    }

    func iRateDidPromptForRating(){
        Tracker.shared.ratePromptShown()
    }

    func iRateUserDidAttemptToRateApp(){
        Tracker.shared.ratePromptUserAttemptedToRateApp()
    }

    func iRateUserDidDeclineToRateApp(){
        Tracker.shared.ratePromptUserDeclinedToRateApp()
    }

    func iRateUserDidRequestReminderToRateApp(){
        Tracker.shared.ratePromptRemindMeLater()
    }

    func iRateDidOpenAppStore(){
        Tracker.shared.ratePromptOpenedAppStore()
    }
}
