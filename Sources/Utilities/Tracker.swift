////
///  Tracker.swift
//

import Analytics
import Keys
import Crashlytics

func logPresentingAlert(_ name: String) {
    Crashlytics.sharedInstance().setObjectValue(name, forKey: CrashlyticsKey.alertPresenter.rawValue)
}


enum ContentType: String {
    case post = "Post"
    case comment = "Comment"
    case user = "User"
}

protocol AnalyticsAgent {
    func identify(_ userId: String!, traits: [AnyHashable: Any]!)
    func track(_ event: String!)
    func track(_ event: String!, properties: [AnyHashable: Any]!)
    func screen(_ screenTitle: String!)
    func screen(_ screenTitle: String!, properties: [AnyHashable: Any]!)
}

struct NullAgent: AnalyticsAgent {
    func identify(_ userId: String!, traits: [AnyHashable: Any]!) { }
    func track(_ event: String!) { }
    func track(_ event: String!, properties: [AnyHashable: Any]!) { }
    func screen(_ screenTitle: String!) { }
    func screen(_ screenTitle: String!, properties: [AnyHashable: Any]!) { }
}

extension SEGAnalytics: AnalyticsAgent { }

class Tracker {
    static var responseHeaders: NSString = ""
    static var responseJSON: NSString = ""

    var overrideAgent: AnalyticsAgent?
    static let shared = Tracker()
    var settingChangedNotification: NotificationObserver?
    fileprivate var shouldTrackUser = true
    fileprivate var currentUser: User?
    fileprivate var agent: AnalyticsAgent {
        return overrideAgent ?? (shouldTrackUser ? SEGAnalytics.shared() : NullAgent())
    }

    init() {
        let configuration = SEGAnalyticsConfiguration(writeKey: ElloKeys().segmentKey())
         SEGAnalytics.setup(with: configuration)

        settingChangedNotification = NotificationObserver(notification: SettingChangedNotification) { user in
            self.shouldTrackUser = user.profile?.allowsAnalytics ?? true
            Crashlytics.sharedInstance().setUserIdentifier(self.shouldTrackUser ? user.id : "")
        }
    }
}

// MARK: Session Info
extension Tracker {

    func identify(_ user: User) {
        currentUser = user
        shouldTrackUser = user.profile?.allowsAnalytics ?? true
        Crashlytics.sharedInstance().setUserIdentifier(shouldTrackUser ? user.id : "")
        if let analyticsId = user.profile?.gaUniqueId {
            agent.identify(analyticsId, traits: [ "created_at": user.profile?.createdAt.toServerDateString() ?? "no-creation-date" ])
        }
    }

    func sessionStarted() {
        agent.track("Session Began")
    }

    func sessionEnded() {
        agent.track("Session Ended")
    }

    static func trackRequest(headers: String, statusCode: Int, responseJSON: String) {
        Tracker.responseHeaders = headers as NSString
        Crashlytics.sharedInstance().setObjectValue(headers, forKey: CrashlyticsKey.responseHeaders.rawValue)
        Crashlytics.sharedInstance().setObjectValue("\(statusCode)", forKey: CrashlyticsKey.responseStatusCode.rawValue)
        Tracker.responseJSON = responseJSON as NSString
        Crashlytics.sharedInstance().setObjectValue(Tracker.responseJSON, forKey: CrashlyticsKey.responseJSON.rawValue)
    }
}

// MARK: Signup and Login
extension Tracker {

    func tappedJoinFromStartup() {
        agent.track("tapped join from startup")
    }

    func tappedLoginFromStartup() {
        agent.track("tapped sign in from startup")
    }

    func tappedJoinFromLogin() {
        agent.track("tapped join from sign-in")
    }

    func tappedLoginFromJoin() {
        agent.track("tapped sign in from join")
    }

    func enteredEmail() {
        agent.track("entered email and pressed 'next'")
    }

    func enteredUsername() {
        agent.track("entered username and pressed 'next'")
    }

    func enteredPassword() {
        agent.track("entered password and pressed 'next'")
    }

    func tappedJoin() {
        agent.track("tapped join")
    }

    func tappedAbout() {
        agent.track("tapped about")
    }

    func tappedTsAndCs() {
        agent.track("tapped terms and conditions")
    }

    func joinValid() {
        agent.track("join valid")
    }

    func joinInvalid() {
        agent.track("join invalid")
    }

    func joinSuccessful() {
        agent.track("join successful")
    }

    func joinFailed() {
        agent.track("join failed")
    }

    func tappedLogin() {
        agent.track("tapped sign in")
    }

    func loginValid() {
        agent.track("sign-in valid")
    }

    func loginInvalid() {
        agent.track("sign-in invalid")
    }

    func loginSuccessful() {
        agent.track("sign-in successful")
    }

    func loginFailed() {
        agent.track("sign-in failed")
    }

    func tappedForgotPassword() {
        agent.track("forgot password tapped")
    }

    func tappedLogout() {
        agent.track("logout tapped")
    }

}

// MARK: iRate
extension Tracker {
    func ratePromptShown() {
        agent.track("rate prompt shown")
    }

    func ratePromptUserDeclinedToRateApp() {
        agent.track("rate prompt user declined to rate app")
    }

    func ratePromptRemindMeLater() {
        agent.track("rate prompt remind me later")
    }

    func ratePromptUserAttemptedToRateApp() {
        agent.track("rate prompt user attempted to rate app")
    }

    func ratePromptOpenedAppStore() {
        agent.track("rate prompt opened app store")
    }

    func ratePromptCouldNotConnectToAppStore() {
        agent.track("rate prompt could not connect to app store")
    }
}

// MARK: Hire Me
extension Tracker {
    func tappedCollaborate(_ user: User) {
        agent.track("open collaborate dialog profile", properties: ["id": user.id])
    }
    func collaboratedUser(_ user: User) {
        agent.track("send collaborate dialog profile", properties: ["id": user.id])
    }
    func tappedHire(_ user: User) {
        agent.track("open hire dialog profile", properties: ["id": user.id])
    }
    func hiredUser(_ user: User) {
        agent.track("send hire dialog profile", properties: ["id": user.id])
    }
}

// MARK: Share Extension
extension Tracker {
    func shareSuccessful() {
        agent.track("successfully shared from the share extension")
    }

    func shareFailed() {
        agent.track("failed to share from the share extension")
    }
}

// MARK: Onboarding
extension Tracker {
    func completedCategories() {
        agent.track("completed categories in onboarding")
    }

    func onboardingCategorySelected(_ category: Category) {
        agent.track("onboarding category chosen", properties: ["category": category.name])
    }

    func skippedCategories() {
        agent.track("skipped categories in onboarding")
    }

    func skippedNameBio() {
        agent.track("skipped name_bio")
    }

    func addedNameBio() {
        agent.track("added name_bio")
    }

    func skippedContactImport() {
        agent.track("skipped contact import")
    }

    func completedContactImport() {
        agent.track("completed contact import")
    }

    func enteredOnboardName() {
        agent.track("entered name during onboarding")
    }

    func enteredOnboardBio() {
        agent.track("entered bio during onboarding")
    }

    func enteredOnboardLinks() {
        agent.track("entered links during onboarding")
    }

    func uploadedOnboardAvatar() {
        agent.track("uploaded avatar during onboarding")
    }

    func uploadedOnboardCoverImage() {
        agent.track("uploaded coverImage during onboarding")
    }
}

extension UIViewController {
    // return 'nil' to disable tracking, e.g. in StreamViewController
    func trackerName() -> String? { return readableClassName() }
    func trackerProps() -> [String: AnyObject]? { return nil }
}

// MARK: View Appearance
extension Tracker {
    func screenAppeared(_ viewController: UIViewController) {
        if let name = viewController.trackerName() {
            let props = viewController.trackerProps()
            screenAppeared(name, properties: props)
        }
    }

    func screenAppeared(_ name: String, properties: [String: AnyObject]? = nil) {
        agent.screen("Screen \(name)", properties: properties)
    }

    func webViewAppeared(_ url: String) {
        agent.screen("Web View", properties: ["url": url])
    }

    func categoryOpened(_ categorySlug: String) {
        agent.track("category opened", properties: ["category": categorySlug])
    }

    func categoryHeaderPostedBy(_ categoryTitle: String) {
        agent.track("promoByline clicked", properties: ["category": categoryTitle])
    }

    func categoryHeaderCallToAction(_ categoryTitle: String) {
        agent.track("promoCTA clicked", properties: ["category": categoryTitle])
    }

    func viewedImage(_ asset: Asset, post: Post) {
        agent.track("Viewed Image", properties: ["asset_id": asset.id, "post_id": post.id])
    }

    func postBarVisibilityChanged(_ visible: Bool) {
        let visibility = visible ? "shown" : "hidden"
        agent.track("Post bar \(visibility)")
    }

    func commentBarVisibilityChanged(_ visible: Bool) {
        let visibility = visible ? "shown" : "hidden"
        agent.track("Comment bar \(visibility)")
    }

    func drawerClosed() {
        agent.track("Drawer closed")
    }

    func viewsButtonTapped(post: Post) {
        agent.track("Views button tapped", properties: ["post_id": post.id])
    }

    func deepLinkVisited(_ path: String) {
        agent.track("Deep Link Visited", properties: ["path": path])
    }

    func buyButtonLinkVisited(_ path: String) {
        agent.track("Buy Button Link Visited", properties: ["link": path])
    }

}

// MARK: Content Actions
extension Tracker {
    fileprivate func regionDetails(_ regions: [Regionable]?) -> [String: AnyObject] {
        guard let regions = regions else {
            return [:]
        }

        var imageCount = 0
        var textLength = 0
        for region in regions {
            if region.kind == RegionKind.image.rawValue {
                imageCount += 1
            }
            else if let region = region as? TextRegion {
                textLength += region.content.characters.count
            }
        }

        return [
            "total_regions": regions.count as AnyObject,
            "image_regions": imageCount as AnyObject,
            "text_length": textLength as AnyObject
        ]
    }

    func postCreated(_ post: Post) {
        let properties = regionDetails(post.content)
        agent.track("Post created", properties: properties)
    }

    func postEdited(_ post: Post) {
        let properties = regionDetails(post.content)
        agent.track("Post edited", properties: properties)
    }

    func postDeleted(_ post: Post) {
        let properties = regionDetails(post.content)
        agent.track("Post deleted", properties: properties)
    }

    func commentCreated(_ comment: ElloComment) {
        let properties = regionDetails(comment.content)
        agent.track("Comment created", properties: properties)
    }

    func commentEdited(_ comment: ElloComment) {
        let properties = regionDetails(comment.content)
        agent.track("Comment edited", properties: properties)
    }

    func commentDeleted(_ comment: ElloComment) {
        let properties = regionDetails(comment.content)
        agent.track("Comment deleted", properties: properties)
    }

    func contentCreationCanceled(_ type: ContentType) {
        agent.track("\(type.rawValue) creation canceled")
    }

    func contentEditingCanceled(_ type: ContentType) {
        agent.track("\(type.rawValue) editing canceled")
    }

    func contentCreationFailed(_ type: ContentType, message: String) {
        agent.track("\(type.rawValue) creation failed", properties: ["message": message])
    }

    func contentFlagged(_ type: ContentType, flag: ContentFlagger.AlertOption, contentId: String) {
        agent.track("\(type.rawValue) flagged", properties: ["content_id": contentId, "flag": flag.rawValue])
    }

    func contentFlaggingCanceled(_ type: ContentType, contentId: String) {
        agent.track("\(type.rawValue) flagging canceled", properties: ["content_id": contentId])
    }

    func contentFlaggingFailed(_ type: ContentType, message: String, contentId: String) {
        agent.track("\(type.rawValue) flagging failed", properties: ["content_id": contentId, "message": message])
    }

    func userShared(_ user: User) {
        agent.track("User shared", properties: ["user_id": user.id])
    }

    func postReposted(_ post: Post) {
        agent.track("Post reposted", properties: ["post_id": post.id])
    }

    func postShared(_ post: Post) {
        agent.track("Post shared", properties: ["post_id": post.id])
    }

    func postLoved(_ post: Post) {
        agent.track("Post loved", properties: ["post_id": post.id])
    }

    func postUnloved(_ post: Post) {
        agent.track("Post unloved", properties: ["post_id": post.id])
    }
}

// MARK: User Actions
extension Tracker {
    func userBlocked(_ userId: String) {
        agent.track("User blocked", properties: ["blocked_user_id": userId])
    }

    func userMuted(_ userId: String) {
        agent.track("User muted", properties: ["muted_user_id": userId])
    }

    func userUnblocked(_ userId: String) {
        agent.track("User UN-blocked", properties: ["blocked_user_id": userId])
    }

    func userUnmuted(_ userId: String) {
        agent.track("User UN-muted", properties: ["muted_user_id": userId])
    }

    func userBlockCanceled(_ userId: String) {
        agent.track("User block canceled", properties: ["blocked_user_id": userId])
    }

    func relationshipStatusUpdated(_ relationshipPriority: RelationshipPriority, userId: String) {
        agent.track("Relationship Priority changed", properties: ["new_value": relationshipPriority.rawValue, "user_id": userId])
    }

    func relationshipStatusUpdateFailed(_ relationshipPriority: RelationshipPriority, userId: String) {
        agent.track("Relationship Priority failed", properties: ["new_value": relationshipPriority.rawValue, "user_id": userId])
    }

    func relationshipButtonTapped(_ relationshipPriority: RelationshipPriority, userId: String) {
        agent.track("Relationship button tapped", properties: ["button": relationshipPriority.buttonName, "user_id": userId])
    }

    func friendInvited() {
        agent.track("User invited")
    }

    func onboardingFriendInvited() {
        agent.track("Onboarding User invited")
    }

    func userDeletedAccount() {
        agent.track("User deleted account")
    }
}

// MARK: Image Actions
extension Tracker {
    func imageAddedFromCamera() {
        agent.track("Image added from camera")
    }

    func imageAddedFromLibrary() {
        agent.track("Image added from library")
    }

    func addImageCanceled() {
        agent.track("Image addition canceled")
    }
}

// MARK: Import Friend Actions
extension Tracker {
    func inviteFriendsTapped() {
        agent.track("Invite Friends tapped")
    }

    func importContactsInitiated() {
        agent.track("Import Contacts initiated")
    }

    func importContactsDenied() {
        agent.track("Import Contacts denied")
    }

    func addressBookAccessed() {
        agent.track("Address book accessed")
    }
}

// MARK:  Preferences
extension Tracker {
    func pushNotificationPreferenceChanged(_ granted: Bool) {
        let accessLevel = granted ? "granted" : "denied"
        agent.track("Push notification access \(accessLevel)")
    }

    func contactAccessPreferenceChanged(_ granted: Bool) {
        let accessLevel = granted ? "granted" : "denied"
        agent.track("Address book access \(accessLevel)")
    }
}

// MARK: Errors
extension Tracker {
    func encounteredNetworkError(_ path: String, error: NSError, statusCode: Int?) {
        agent.track("Encountered network error", properties: ["path": path, "message": error.description, "statusCode": statusCode ?? 0])
    }
}

// MARK: Search
extension Tracker {
    func searchFor(_ searchType: String, _ text: String) {
        agent.track("Search", properties: ["for": searchType, "text": text])
    }
}

// MARK: Announcements
extension Tracker {

    func announcementViewed(_ announcement: Announcement) {
        agent.track("Announcement Viewed", properties: ["announcement": announcement.id])
    }

    func announcementOpened(_ announcement: Announcement) {
        agent.track("Announcement Clicked", properties: ["announcement": announcement.id])
    }

    func announcementDismissed(_ announcement: Announcement) {
        agent.track("Announcement Closed", properties: ["announcement": announcement.id])
    }

}
