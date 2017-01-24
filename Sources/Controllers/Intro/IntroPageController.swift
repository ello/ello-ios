////
///  IntroPageController.swift
//

import Foundation
import Crashlytics

class IntroPageController: UIViewController {

    var pageIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isKind(of: WelcomePageController.self) {
            Crashlytics.sharedInstance().setObjectValue("IntroWelcome", forKey: CrashlyticsKey.streamName.rawValue)
        }
        else if self.isKind(of: InspiredPageController.self) {
            Crashlytics.sharedInstance().setObjectValue("IntroInspired", forKey: CrashlyticsKey.streamName.rawValue)
        }
        else if self.isKind(of: FriendsPageController.self) {
            Crashlytics.sharedInstance().setObjectValue("IntroFriends", forKey: CrashlyticsKey.streamName.rawValue)
        }
        else if self.isKind(of: LovesPageController.self) {
            Crashlytics.sharedInstance().setObjectValue("IntroLoves", forKey: CrashlyticsKey.streamName.rawValue)
        }
    }
}
