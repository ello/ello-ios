////
///  Profile.swift
//

import SwiftyJSON


// version 1: initial
// version 2: added hasAutoWatchEnabled and moved in notifyOfWatch* settings
// version 3: added notifyOfAnnouncementsViaPush
// version 4: added hasAnnouncementsEnabled
// version 4: added isCommunity
let ProfileVersion: Int = 4

@objc(Profile)
final class Profile: JSONAble {

    // active record
    let id: String
    let createdAt: Date
    // required
    let shortBio: String
    let email: String
    let confirmedAt: Date
    var isPublic: Bool
    var isCommunity: Bool
    var mutedCount: Int
    var blockedCount: Int
    var hasSharingEnabled: Bool
    var hasAdNotificationsEnabled: Bool
    var hasAutoWatchEnabled: Bool
    let allowsAnalytics: Bool
    let notifyOfCommentsViaEmail: Bool
    let notifyOfLovesViaEmail: Bool
    let notifyOfInvitationAcceptancesViaEmail: Bool
    let notifyOfMentionsViaEmail: Bool
    let notifyOfNewFollowersViaEmail: Bool
    let notifyOfRepostsViaEmail: Bool
    let subscribeToUsersEmailList: Bool
    let subscribeToDailyEllo: Bool
    let subscribeToWeeklyEllo: Bool
    let subscribeToOnboardingDrip: Bool
    let notifyOfAnnouncementsViaPush: Bool
    let notifyOfCommentsViaPush: Bool
    let notifyOfLovesViaPush: Bool
    let notifyOfMentionsViaPush: Bool
    let notifyOfRepostsViaPush: Bool
    let notifyOfNewFollowersViaPush: Bool
    let notifyOfInvitationAcceptancesViaPush: Bool
    var notifyOfWatchesViaPush: Bool
    var notifyOfWatchesViaEmail: Bool
    var notifyOfCommentsOnPostWatchViaPush: Bool
    var notifyOfCommentsOnPostWatchViaEmail: Bool
    var hasAnnouncementsEnabled: Bool
    let discoverable: Bool
    // optional
    var gaUniqueId: String?

    init(
        id: String,
        createdAt: Date,
        shortBio: String,
        email: String,
        confirmedAt: Date,
        isPublic: Bool,
        isCommunity: Bool,
        mutedCount: Int,
        blockedCount: Int,
        hasSharingEnabled: Bool,
        hasAdNotificationsEnabled: Bool,
        hasAutoWatchEnabled: Bool,
        allowsAnalytics: Bool,
        notifyOfCommentsViaEmail: Bool,
        notifyOfLovesViaEmail: Bool,
        notifyOfInvitationAcceptancesViaEmail: Bool,
        notifyOfMentionsViaEmail: Bool,
        notifyOfNewFollowersViaEmail: Bool,
        notifyOfRepostsViaEmail: Bool,
        subscribeToUsersEmailList: Bool,
        subscribeToDailyEllo: Bool,
        subscribeToWeeklyEllo: Bool,
        subscribeToOnboardingDrip: Bool,
        notifyOfAnnouncementsViaPush: Bool,
        notifyOfCommentsViaPush: Bool,
        notifyOfLovesViaPush: Bool,
        notifyOfMentionsViaPush: Bool,
        notifyOfRepostsViaPush: Bool,
        notifyOfNewFollowersViaPush: Bool,
        notifyOfInvitationAcceptancesViaPush: Bool,
        notifyOfWatchesViaPush: Bool,
        notifyOfWatchesViaEmail: Bool,
        notifyOfCommentsOnPostWatchViaPush: Bool,
        notifyOfCommentsOnPostWatchViaEmail: Bool,
        hasAnnouncementsEnabled: Bool,
        discoverable: Bool)
    {
        self.id = id
        self.createdAt = createdAt
        self.shortBio = shortBio
        self.email = email
        self.confirmedAt = confirmedAt
        self.isPublic = isPublic
        self.isCommunity = isCommunity
        self.mutedCount = mutedCount
        self.blockedCount = blockedCount
        self.hasSharingEnabled = hasSharingEnabled
        self.hasAdNotificationsEnabled = hasAdNotificationsEnabled
        self.hasAutoWatchEnabled = hasAutoWatchEnabled
        self.allowsAnalytics = allowsAnalytics
        self.notifyOfCommentsViaEmail = notifyOfCommentsViaEmail
        self.notifyOfLovesViaEmail = notifyOfLovesViaEmail
        self.notifyOfInvitationAcceptancesViaEmail = notifyOfInvitationAcceptancesViaEmail
        self.notifyOfMentionsViaEmail = notifyOfMentionsViaEmail
        self.notifyOfNewFollowersViaEmail = notifyOfNewFollowersViaEmail
        self.notifyOfRepostsViaEmail = notifyOfRepostsViaEmail
        self.subscribeToUsersEmailList = subscribeToUsersEmailList
        self.subscribeToDailyEllo = subscribeToDailyEllo
        self.subscribeToWeeklyEllo = subscribeToWeeklyEllo
        self.subscribeToOnboardingDrip = subscribeToOnboardingDrip
        self.notifyOfAnnouncementsViaPush = notifyOfAnnouncementsViaPush
        self.notifyOfCommentsViaPush = notifyOfCommentsViaPush
        self.notifyOfLovesViaPush = notifyOfLovesViaPush
        self.notifyOfMentionsViaPush = notifyOfMentionsViaPush
        self.notifyOfRepostsViaPush = notifyOfRepostsViaPush
        self.notifyOfNewFollowersViaPush = notifyOfNewFollowersViaPush
        self.notifyOfInvitationAcceptancesViaPush = notifyOfInvitationAcceptancesViaPush
        self.notifyOfWatchesViaPush = notifyOfWatchesViaPush
        self.notifyOfWatchesViaEmail = notifyOfWatchesViaEmail
        self.notifyOfCommentsOnPostWatchViaPush = notifyOfCommentsOnPostWatchViaPush
        self.notifyOfCommentsOnPostWatchViaEmail = notifyOfCommentsOnPostWatchViaEmail
        self.hasAnnouncementsEnabled = hasAnnouncementsEnabled
        self.discoverable = discoverable
        super.init(version: ProfileVersion)
    }

// MARK: NSCoding

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // active record
        self.id = decoder.decodeOptionalKey("id") ?? ""
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.shortBio = decoder.decodeKey("shortBio")
        self.email = decoder.decodeKey("email")
        self.confirmedAt = decoder.decodeKey("confirmedAt")
        self.isPublic = decoder.decodeKey("isPublic")
        self.mutedCount = decoder.decodeKey("mutedCount")
        self.blockedCount = decoder.decodeKey("blockedCount")
        self.hasSharingEnabled = decoder.decodeKey("hasSharingEnabled")
        self.hasAdNotificationsEnabled = decoder.decodeKey("hasAdNotificationsEnabled")
        let version: Int = decoder.decodeKey("version")

        if version < 5 {
            self.isCommunity = false
        }
        else {
            self.isCommunity = decoder.decodeKey("isCommunity")
        }

        if version < 4 {
            self.hasAnnouncementsEnabled = true
        }
        else {
            self.hasAnnouncementsEnabled = decoder.decodeKey("hasAnnouncementsEnabled")
        }

        if version < 3 {
            self.notifyOfAnnouncementsViaPush = true
        }
        else {
            self.notifyOfAnnouncementsViaPush = decoder.decodeKey("notifyOfAnnouncementsViaPush")
        }

        if version < 2 {
            self.hasAutoWatchEnabled = true
            self.notifyOfWatchesViaPush = true
            self.notifyOfWatchesViaEmail = true
            self.notifyOfCommentsOnPostWatchViaPush = true
            self.notifyOfCommentsOnPostWatchViaEmail = true
        }
        else {
            self.hasAutoWatchEnabled = decoder.decodeKey("hasAutoWatchEnabled")
            self.notifyOfWatchesViaPush = decoder.decodeKey("notifyOfWatchesViaPush")
            self.notifyOfWatchesViaEmail = decoder.decodeKey("notifyOfWatchesViaEmail")
            self.notifyOfCommentsOnPostWatchViaPush = decoder.decodeKey("notifyOfCommentsOnPostWatchViaPush")
            self.notifyOfCommentsOnPostWatchViaEmail = decoder.decodeKey("notifyOfCommentsOnPostWatchViaEmail")
        }
        self.allowsAnalytics = decoder.decodeKey("allowsAnalytics")
        self.notifyOfCommentsViaEmail = decoder.decodeKey("notifyOfCommentsViaEmail")
        self.notifyOfLovesViaEmail = decoder.decodeKey("notifyOfLovesViaEmail")
        self.notifyOfInvitationAcceptancesViaEmail = decoder.decodeKey("notifyOfInvitationAcceptancesViaEmail")
        self.notifyOfMentionsViaEmail = decoder.decodeKey("notifyOfMentionsViaEmail")
        self.notifyOfNewFollowersViaEmail = decoder.decodeKey("notifyOfNewFollowersViaEmail")
        self.notifyOfRepostsViaEmail = decoder.decodeKey("notifyOfRepostsViaEmail")
        self.subscribeToUsersEmailList = decoder.decodeKey("subscribeToUsersEmailList")
        self.subscribeToDailyEllo = decoder.decodeKey("subscribeToDailyEllo")
        self.subscribeToWeeklyEllo = decoder.decodeKey("subscribeToWeeklyEllo")
        self.subscribeToOnboardingDrip = decoder.decodeKey("subscribeToOnboardingDrip")
        self.notifyOfCommentsViaPush = decoder.decodeKey("notifyOfCommentsViaPush")
        self.notifyOfLovesViaPush = decoder.decodeKey("notifyOfLovesViaPush")
        self.notifyOfMentionsViaPush = decoder.decodeKey("notifyOfMentionsViaPush")
        self.notifyOfRepostsViaPush = decoder.decodeKey("notifyOfRepostsViaPush")
        self.notifyOfNewFollowersViaPush = decoder.decodeKey("notifyOfNewFollowersViaPush")
        self.notifyOfInvitationAcceptancesViaPush = decoder.decodeKey("notifyOfInvitationAcceptancesViaPush")
        self.discoverable = decoder.decodeKey("discoverable")
        super.init(coder: decoder.coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        // required
        coder.encodeObject(shortBio, forKey: "shortBio")
        coder.encodeObject(email, forKey: "email")
        coder.encodeObject(confirmedAt, forKey: "confirmedAt")
        coder.encodeObject(isPublic, forKey: "isPublic")
        coder.encodeObject(isCommunity, forKey: "isCommunity")
        coder.encodeObject(mutedCount, forKey: "mutedCount")
        coder.encodeObject(blockedCount, forKey: "blockedCount")
        coder.encodeObject(hasSharingEnabled, forKey: "hasSharingEnabled")
        coder.encodeObject(hasAdNotificationsEnabled, forKey: "hasAdNotificationsEnabled")
        coder.encodeObject(hasAutoWatchEnabled, forKey: "hasAutoWatchEnabled")
        coder.encodeObject(allowsAnalytics, forKey: "allowsAnalytics")
        coder.encodeObject(notifyOfCommentsViaEmail, forKey: "notifyOfCommentsViaEmail")
        coder.encodeObject(notifyOfLovesViaEmail, forKey: "notifyOfLovesViaEmail")
        coder.encodeObject(notifyOfInvitationAcceptancesViaEmail, forKey: "notifyOfInvitationAcceptancesViaEmail")
        coder.encodeObject(notifyOfMentionsViaEmail, forKey: "notifyOfMentionsViaEmail")
        coder.encodeObject(notifyOfNewFollowersViaEmail, forKey: "notifyOfNewFollowersViaEmail")
        coder.encodeObject(notifyOfRepostsViaEmail, forKey: "notifyOfRepostsViaEmail")
        coder.encodeObject(subscribeToUsersEmailList, forKey: "subscribeToUsersEmailList")
        coder.encodeObject(subscribeToDailyEllo, forKey: "subscribeToDailyEllo")
        coder.encodeObject(subscribeToWeeklyEllo, forKey: "subscribeToWeeklyEllo")
        coder.encodeObject(subscribeToOnboardingDrip, forKey: "subscribeToOnboardingDrip")
        coder.encodeObject(notifyOfAnnouncementsViaPush, forKey: "notifyOfAnnouncementsViaPush")
        coder.encodeObject(notifyOfCommentsViaPush, forKey: "notifyOfCommentsViaPush")
        coder.encodeObject(notifyOfLovesViaPush, forKey: "notifyOfLovesViaPush")
        coder.encodeObject(notifyOfMentionsViaPush, forKey: "notifyOfMentionsViaPush")
        coder.encodeObject(notifyOfRepostsViaPush, forKey: "notifyOfRepostsViaPush")
        coder.encodeObject(notifyOfNewFollowersViaPush, forKey: "notifyOfNewFollowersViaPush")
        coder.encodeObject(notifyOfInvitationAcceptancesViaPush, forKey: "notifyOfInvitationAcceptancesViaPush")
        coder.encodeObject(notifyOfWatchesViaPush, forKey: "notifyOfWatchesViaPush")
        coder.encodeObject(notifyOfWatchesViaEmail, forKey: "notifyOfWatchesViaEmail")
        coder.encodeObject(notifyOfCommentsOnPostWatchViaPush, forKey: "notifyOfCommentsOnPostWatchViaPush")
        coder.encodeObject(notifyOfCommentsOnPostWatchViaEmail, forKey: "notifyOfCommentsOnPostWatchViaEmail")
        coder.encodeObject(hasAnnouncementsEnabled, forKey: "hasAnnouncementsEnabled")
        coder.encodeObject(discoverable, forKey: "discoverable")
        super.encode(with: coder.coder)
    }

// MARK: JSONAble

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        // create profile
        let profile = Profile(
            id: json["id"].string ?? "",
            createdAt: (json["created_at"].stringValue.toDate() ?? Date()),
            shortBio: json["short_bio"].stringValue,
            email: json["email"].stringValue,
            confirmedAt: (json["confirmed_at"].stringValue.toDate() ?? Date()),
            isPublic: json["is_public"].boolValue,
            isCommunity: json["is_community"].boolValue,
            mutedCount: json["muted_count"].intValue,
            blockedCount: json["blocked_count"].intValue,
            hasSharingEnabled: json["has_sharing_enabled"].boolValue,
            hasAdNotificationsEnabled: json["has_ad_notifications_enabled"].boolValue,
            hasAutoWatchEnabled: json["has_auto_watch_enabled"].boolValue,
            allowsAnalytics: json["allows_analytics"].boolValue,
            notifyOfCommentsViaEmail: json["notify_of_comments_via_email"].boolValue,
            notifyOfLovesViaEmail: json["notify_of_loves_via_email"].boolValue,
            notifyOfInvitationAcceptancesViaEmail: json["notify_of_invitation_acceptances_via_email"].boolValue,
            notifyOfMentionsViaEmail: json["notify_of_mentions_via_email"].boolValue,
            notifyOfNewFollowersViaEmail: json["notify_of_new_followers_via_email"].boolValue,
            notifyOfRepostsViaEmail: json["notify_of_reposts_via_email"].boolValue,
            subscribeToUsersEmailList: json["subscribe_to_users_email_list"].boolValue,
            subscribeToDailyEllo: json["subscribe_to_daily_ello"].boolValue,
            subscribeToWeeklyEllo: json["subscribe_to_weekly_ello"].boolValue,
            subscribeToOnboardingDrip: json["subscribe_to_onboarding_drip"].boolValue,
            notifyOfAnnouncementsViaPush: json["notify_of_announcements_via_push"].boolValue,
            notifyOfCommentsViaPush: json["notify_of_comments_via_push"].boolValue,
            notifyOfLovesViaPush : json["notify_of_loves_via_push"].boolValue,
            notifyOfMentionsViaPush: json["notify_of_mentions_via_push"].boolValue,
            notifyOfRepostsViaPush: json["notify_of_reposts_via_push"].boolValue,
            notifyOfNewFollowersViaPush: json["notify_of_new_followers_via_push"].boolValue,
            notifyOfInvitationAcceptancesViaPush: json["notify_of_invitation_acceptances_via_push"].boolValue,
            notifyOfWatchesViaPush: json["notify_of_watches_via_push"].boolValue,
            notifyOfWatchesViaEmail: json["notify_of_watches_via_email"].boolValue,
            notifyOfCommentsOnPostWatchViaPush: json["notify_of_comments_on_post_watch_via_push"].boolValue,
            notifyOfCommentsOnPostWatchViaEmail: json["notify_of_comments_on_post_watch_via_email"].boolValue,
            hasAnnouncementsEnabled: json["has_announcements_enabled"].boolValue,
            discoverable: json["discoverable"].boolValue
        )
        profile.gaUniqueId = json["ga_unique_id"].string
        return profile
    }
}

extension Profile: JSONSaveable {
    var uniqueId: String? { return "Profile-\(id)" }
    var tableId: String? { return id }

}
