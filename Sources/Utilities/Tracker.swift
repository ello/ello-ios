////
///  Tracker.swift
//

import Analytics
import Keys


enum ContentType: String {
    case post = "Post"
    case comment = "Comment"
    case user = "User"
}

protocol AnalyticsAgent {
    func identify(_ userId: String?, traits: [String: Any]?)
    func track(_ event: String)
    func track(_ event: String, properties: [String: Any]?)
    func screen(_ screenTitle: String)
    func screen(_ screenTitle: String, properties: [String: Any]?)
    func reset()
}

struct NullAgent: AnalyticsAgent {
    func identify(_ userId: String?, traits: [String: Any]?) { }
    func track(_ event: String) { }
    func track(_ event: String, properties: [String: Any]?) { }
    func screen(_ screenTitle: String) { }
    func screen(_ screenTitle: String, properties: [String: Any]?) { }
    func reset() { }
}

extension SEGAnalytics: AnalyticsAgent { }

class Tracker {
    var overrideAgent: AnalyticsAgent?
    static let shared = Tracker()
    var settingChangedNotification: NotificationObserver?
    private var shouldTrackUser = true
    private var agent: AnalyticsAgent {
        return overrideAgent ?? (shouldTrackUser ? SEGAnalytics.shared() : NullAgent())
    }

    init() {
        let configuration = SEGAnalyticsConfiguration(writeKey: APIKeys.shared.segmentKey)
        SEGAnalytics.setup(with: configuration)

        settingChangedNotification = NotificationObserver(notification: SettingChangedNotification) { user in
            self.shouldTrackUser = user.profile?.allowsAnalytics ?? true
        }
    }
}

// MARK: Session Info
extension Tracker {

    func identify(user: User?) {
        guard let user = user else {
            shouldTrackUser = true
            agent.reset()
            return
        }

        shouldTrackUser = user.profile?.allowsAnalytics ?? true

        if let analyticsId = user.profile?.gaUniqueId {
            let authToken = AuthToken()
            agent.identify(analyticsId, traits: [
                // camelCase is correct, so we have parity w/ webapp
                "hasAccount": true,
                "agent": "ios",
                // leave these as snake_case since they are being used in reports
                "is_nabaroo": authToken.isNabaroo,
                "is_featured": user.isFeatured,
                "is_experimental": user.experimentalFeatures ?? false,
                "created_at": user.profile?.createdAt.toServerDateString() ?? "no-creation-date",
            ])
        }
        else {
            agent.reset()
        }
    }

    func track(_ event: String, properties customProps: [String: Any] = [:]) {
        let properties = customProps + ["agent": "ios"]
        agent.track(event, properties: properties)
    }

    func screen(_ name: String, properties customProps: [String: Any] = [:]) {
        let properties = customProps + ["agent": "ios"]
        agent.screen(name, properties: properties)
    }

    func sessionStarted() {
        track("Session Began")
    }

    func sessionEnded() {
        track("Session Ended")
    }
}

// MARK: Signup and Login
extension Tracker {

    func enteredEmail() {
        track("entered email and pressed 'next'")
    }

    func enteredUsername() {
        track("entered username and pressed 'next'")
    }

    func enteredPassword() {
        track("entered password and pressed 'next'")
    }

    func tappedRequestPassword() {
        track("tapped request reset password")
    }

    func tappedReset() {
        track("tapped reset password")
    }

    func tappedJoin() {
        track("tapped join")
    }

    func tappedAbout() {
        track("tapped about")
    }

    func tappedTsAndCs() {
        track("tapped terms and conditions")
    }

    func requestPasswordValid() {
        track("reset password valid email")
    }

    func resetPasswordValid() {
        track("reset password sent")
    }

    func resetPasswordSuccessful() {
        track("reset password successful")
    }

    func resetPasswordFailed() {
        track("reset password failed")
    }

    func joinButtonTapped() {
        track("join button tapped")
    }

    func joinValid() {
        track("join valid")
    }

    func joinInvalid() {
        track("join invalid")
    }

    func joinSuccessful() {
        track("join successful")
    }

    func joinFailed() {
        track("join failed")
    }

    func tappedLogin() {
        track("tapped sign in")
    }

    func loginButtonTapped() {
        track("login button tapped")
    }

    func loginValid() {
        track("sign-in valid")
    }

    func loginInvalid() {
        track("sign-in invalid")
    }

    func loginSuccessful() {
        track("sign-in successful")
    }

    func loginFailed() {
        track("sign-in failed")
    }

    func tappedForgotPassword() {
        track("forgot password tapped")
    }

    func tappedLogout() {
        track("logout tapped")
    }

    func tappedDrawer(_ item: String) {
        track("tapped \(item) drawer")
    }

}

// MARK: iRate
extension Tracker {
    func ratePromptShown() {
        track("rate prompt shown")
    }

    func ratePromptUserDeclinedToRateApp() {
        track("rate prompt user declined to rate app")
    }

    func ratePromptRemindMeLater() {
        track("rate prompt remind me later")
    }

    func ratePromptUserAttemptedToRateApp() {
        track("rate prompt user attempted to rate app")
    }

    func ratePromptOpenedAppStore() {
        track("rate prompt opened app store")
    }

    func ratePromptCouldNotConnectToAppStore() {
        track("rate prompt could not connect to app store")
    }
}

// MARK: Hire Me
extension Tracker {
    func tappedCollaborate(_ user: User) {
        track("open collaborate dialog profile", properties: ["id": user.id])
    }
    func collaboratedUser(_ user: User) {
        track("send collaborate dialog profile", properties: ["id": user.id])
    }
    func tappedHire(_ user: User) {
        track("open hire dialog profile", properties: ["id": user.id])
    }
    func hiredUser(_ user: User) {
        track("send hire dialog profile", properties: ["id": user.id])
    }
}

// MARK: Share Extension
extension Tracker {
    func shareSuccessful() {
        track("successfully shared from the share extension")
    }

    func shareFailed() {
        track("failed to share from the share extension")
    }
}

// MARK: Onboarding
extension Tracker {
    func completedCategories() {
        track("completed categories in onboarding")
    }

    func onboardingCategorySelected(_ category: Category) {
        track("onboarding category chosen", properties: ["category": category.name])
    }

    func skippedCategories() {
        track("skipped categories in onboarding")
    }

    func skippedNameBio() {
        track("skipped name_bio")
    }

    func addedNameBio() {
        track("added name_bio")
    }

    func skippedContactImport() {
        track("skipped contact import")
    }

    func completedContactImport() {
        track("completed contact import")
    }

    func enteredOnboardName() {
        track("entered name during onboarding")
    }

    func enteredOnboardBio() {
        track("entered bio during onboarding")
    }

    func enteredOnboardLinks() {
        track("entered links during onboarding")
    }

    func uploadedOnboardAvatar() {
        track("uploaded avatar during onboarding")
    }

    func uploadedOnboardCoverImage() {
        track("uploaded coverImage during onboarding")
    }
}

extension UIViewController {
    // return 'nil' to disable tracking, e.g. in StreamViewController
    @objc func trackerName() -> String? { return readableClassName() }
    @objc func trackerProps() -> [String: Any]? { return nil }

    @objc
    func trackScreenAppeared() {
        Tracker.shared.screenAppeared(self)
    }
}

// MARK: View Appearance
extension Tracker {
    func screenAppeared(_ viewController: UIViewController) {
        guard let name = viewController.trackerName() else { return }
        let props = viewController.trackerProps()
        screenAppeared(name, properties: props)
    }

    func loggedOutScreenAppeared(_ viewController: UIViewController) {
        guard let name = viewController.trackerName() else { return }
        track("logged out screen viewed", properties: ["screen": name])
    }

    func screenAppeared(_ name: String, properties: [String: Any]? = nil) {
        if let properties = properties {
            screen("Screen \(name)", properties: properties)
        }
        else {
            screen("Screen \(name)")
        }
    }

    func webViewAppeared(_ url: String) {
        screen("Web View", properties: ["url": url])
    }

    func categoryOpened(_ categorySlug: String) {
        track("category opened", properties: ["category": categorySlug])
    }

    func categoryHeaderPostedBy(_ categoryTitle: String) {
        track("promoByline clicked", properties: ["category": categoryTitle])
    }

    func categoryHeaderCallToAction(_ categoryTitle: String) {
        track("promoCTA clicked", properties: ["category": categoryTitle])
    }

    func badgeOpened(_ badgeSlug: String) {
        track("badge opened", properties: ["badge": badgeSlug])
    }

    func badgeLearnMore(_ badgeSlug: String) {
        track("badge learn more clicked", properties: ["badge": badgeSlug])
    }

    func badgeScreenLink(_ badgeSlug: String) {
        track("badges screen link tapped", properties: ["badge": badgeSlug])
    }

    func viewedImage(_ asset: Asset, post: Post) {
        track("Viewed Image", properties: ["asset_id": asset.id, "post_id": post.id])
    }

    func postBarVisibilityChanged(_ visible: Bool) {
        let visibility = visible ? "shown" : "hidden"
        track("Post bar \(visibility)")
    }

    func commentBarVisibilityChanged(_ visible: Bool) {
        let visibility = visible ? "shown" : "hidden"
        track("Comment bar \(visibility)")
    }

    func drawerClosed() {
        track("Drawer closed")
    }

    func viewsButtonTapped(post: Post) {
        track("Views button tapped", properties: ["post_id": post.id])
    }

    func buyButtonLinkVisited(_ path: String) {
        track("Buy Button Link Visited", properties: ["link": path])
    }

}

// MARK: Content Actions
extension Tracker {
    private func regionDetails(_ regions: [Regionable]?) -> [String: Any] {
        guard let regions = regions else {
            return [:]
        }

        var imageCount = 0
        var textLength = 0
        for region in regions {
            if region.kind == RegionKind.image {
                imageCount += 1
            }
            else if let region = region as? TextRegion {
                textLength += region.content.count
            }
        }

        return [
            "total_regions": regions.count,
            "image_regions": imageCount,
            "text_length": textLength
        ]
    }

    func relatedPostTapped(_ post: Post) {
        let properties = ["post_id": post.id]
        track("related post tapped", properties: properties)
    }

    func postCreated(_ post: Post) {
        let properties = regionDetails(post.content)
        track("Post created", properties: properties)
    }

    func postEdited(_ post: Post) {
        let properties = regionDetails(post.content)
        track("Post edited", properties: properties)
    }

    func postDeleted(_ post: Post) {
        let properties = regionDetails(post.content)
        track("Post deleted", properties: properties)
    }

    func commentCreated(_ comment: ElloComment) {
        let properties = regionDetails(comment.content)
        track("Comment created", properties: properties)
    }

    func commentEdited(_ comment: ElloComment) {
        let properties = regionDetails(comment.content)
        track("Comment edited", properties: properties)
    }

    func commentDeleted(_ comment: ElloComment) {
        let properties = regionDetails(comment.content)
        track("Comment deleted", properties: properties)
    }

    func contentCreationCanceled(_ type: ContentType) {
        track("\(type.rawValue) creation canceled")
    }

    func contentEditingCanceled(_ type: ContentType) {
        track("\(type.rawValue) editing canceled")
    }

    func contentCreationFailed(_ type: ContentType, message: String) {
        track("\(type.rawValue) creation failed", properties: ["message": message])
    }

    func contentFlagged(_ type: ContentType, flag: UserFlag, contentId: String) {
        track("\(type.rawValue) flagged", properties: ["content_id": contentId, "flag": flag.rawValue])
    }

    func contentFlaggingCanceled(_ type: ContentType, contentId: String) {
        track("\(type.rawValue) flagging canceled", properties: ["content_id": contentId])
    }

    func contentFlaggingFailed(_ type: ContentType, message: String, contentId: String) {
        track("\(type.rawValue) flagging failed", properties: ["content_id": contentId, "message": message])
    }

    func userShared(_ user: User) {
        track("User shared", properties: ["user_id": user.id])
    }

}

extension Tracker {
    private func postProps(_ post: Post, additional: [String: Any] = [:]) -> [String: Any] {
        var props: [String: Any] = ["post_id": post.id]
        if let artistInviteId = post.artistInviteId {
            props["artistInviteId"] = artistInviteId
        }
        return props + additional
    }

    func postReposted(_ post: Post) {
        track("Post reposted", properties: postProps(post))
    }

    func postShared(_ post: Post) {
        track("Post shared", properties: postProps(post))
    }

    func postLoved(_ post: Post, via: String) {
        var props: [String: Any] = ["post_id": post.id, "via": via]
        if let artistInviteId = post.artistInviteId {
            props["artistInviteId"] = artistInviteId
        }
        track("Post loved", properties: postProps(post, additional: ["via": via]))
    }

    func postUnloved(_ post: Post) {
        track("Post unloved", properties: postProps(post))
    }

    func postWatched(_ post: Post) {
        track("Post watched", properties: postProps(post))
    }

    func postUnwatched(_ post: Post) {
        var props: [String: Any] = ["post_id": post.id]
        if let artistInviteId = post.artistInviteId {
            props["artistInviteId"] = artistInviteId
        }
        track("Post unwatched", properties: props)
    }
}

// MARK: User Actions
extension Tracker {
    func userBlocked(_ userId: String) {
        track("User blocked", properties: ["blocked_user_id": userId])
    }

    func userMuted(_ userId: String) {
        track("User muted", properties: ["muted_user_id": userId])
    }

    func userUnblocked(_ userId: String) {
        track("User UN-blocked", properties: ["blocked_user_id": userId])
    }

    func userUnmuted(_ userId: String) {
        track("User UN-muted", properties: ["muted_user_id": userId])
    }

    func userBlockCanceled(_ userId: String) {
        track("User block canceled", properties: ["blocked_user_id": userId])
    }

    func relationshipStatusUpdated(_ relationshipPriority: RelationshipPriority, userId: String) {
        track("Relationship Priority changed", properties: ["new_value": relationshipPriority.rawValue, "user_id": userId])
    }

    func relationshipStatusUpdateFailed(_ relationshipPriority: RelationshipPriority, userId: String) {
        track("Relationship Priority failed", properties: ["new_value": relationshipPriority.rawValue, "user_id": userId])
    }

    func relationshipButtonTapped(_ relationshipPriority: RelationshipPriority, userId: String) {
        track("Relationship button tapped", properties: ["button": relationshipPriority.buttonName, "user_id": userId])
    }

    func friendInvited() {
        track("User invited")
    }

    func onboardingFriendInvited() {
        track("Onboarding User invited")
    }

    func userDeletedAccount() {
        track("User deleted account")
    }
}

// MARK: Image Actions
extension Tracker {
    func imageAddedFromCamera() {
        track("Image added from camera")
    }

    func imageAddedFromLibrary() {
        track("Image added from library")
    }

    func addImageCanceled() {
        track("Image addition canceled")
    }
}

// MARK: Import Friend Actions
extension Tracker {
    func inviteFriendsTapped() {
        track("Invite Friends tapped")
    }

    func importContactsInitiated() {
        track("Import Contacts initiated")
    }

    func importContactsDenied() {
        track("Import Contacts denied")
    }

    func addressBookAccessed() {
        track("Address book accessed")
    }
}

// MARK: Preferences
extension Tracker {
    func pushNotificationPreferenceChanged(_ granted: Bool) {
        let accessLevel = granted ? "granted" : "denied"
        track("Push notification access \(accessLevel)")
    }

    func contactAccessPreferenceChanged(_ granted: Bool) {
        let accessLevel = granted ? "granted" : "denied"
        track("Address book access \(accessLevel)")
    }
}

// MARK: Errors
extension Tracker {
    func encounteredNetworkError(_ path: String, error: NSError, statusCode: Int?) {
        track("Encountered network error", properties: ["path": path, "message": error.description, "statusCode": statusCode ?? 0])
    }
}

// MARK: Search
extension Tracker {
    func searchFor(_ searchType: String, _ text: String) {
        track("Search", properties: ["for": searchType, "text": text])
    }
}

// MARK: Announcements
extension Tracker {

    func announcementViewed(_ announcement: Announcement) {
        track("Announcement Viewed", properties: ["announcement": announcement.id])
    }

    func announcementOpened(_ announcement: Announcement) {
        track("Announcement Clicked", properties: ["announcement": announcement.id])
    }

    func announcementDismissed(_ announcement: Announcement) {
        track("Announcement Closed", properties: ["announcement": announcement.id])
    }

}

// MARK: ArtistInvites
extension Tracker {

    func artistInvitesBrowsed() {
        track("Clocked Artist Invites")
    }

    func artistInviteOpened(slug: String) {
        track("Clicked Artist Invite", properties: ["artistInvite": slug])
    }

    func artistInviteSubmitted(slug: String) {
        track("Submitted Artist Invite", properties: ["artistInvite": slug])
    }

    func artistInviteShared(slug: String) {
        track("Artist Invite shared", properties: ["artistInvite": slug])
    }

}

// MARK: LoggedOut
extension Tracker {
    func loggedOutScreenViewed() {
        track("logged out screen viewed")
    }

    func loggedOutRelationshipAction() {
        track("logged out follow button")
    }

    func loggedOutPostTool() {
        track("logged out post tool")
    }

    func loggedOutArtistInviteSubmit() {
        track("logged out artist invite submit")
    }
}
