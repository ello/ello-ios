////
///  Profile.swift
//

import SwiftyJSON


// version 1: initial
// version 2: added hasAutoWatchEnabled and moved in notifyOfWatch* settings
// version 3: added notifyOfAnnouncementsViaPush
// version 4: added hasAnnouncementsEnabled
// version 5: added isCommunity
// version 6: added creatorTypeCategoryIds
// version 7: added notifyOfApprovedSubmissionsViaPush
// version 8: added notifyOfApprovedSubmissionsFromFollowingViaPush
// version 9: added notifyOfWhatYouMissedViaEmail
let ProfileVersion: Int = 9

@objc(Profile)
final class Profile: JSONAble {
    enum CreatorType {
        case none
        case fan
        case artist([Category])

        var isValid: Bool {
            switch self {
            case .none:
                return false
            case .fan:
                return true
            case let .artist(selections):
                return selections.count > 0
            }
        }
    }

    enum ImageProperty: String {
        case avatar
        case coverImage

        var toProperty: Property {
            switch self {
            case .avatar: return .avatarURL
            case .coverImage: return .coverImageURL
            }
        }
    }

    enum Property: String {
        case name
        case bio = "unsanitized_short_bio"
        case links = "external_links"
        case location
        case avatarURL = "remote_avatar_url"
        case coverImageURL = "remote_cover_image_url"
        case webOnboardingVersion = "web_onboarding_version"
        case creatorTypeCategoryIds = "creator_type_category_ids"
        case isHireable = "is_hireable"
        case isCollaborateable = "is_collaborateable"

        case username
        case email
        case currentPassword = "current_password"
        case password
        case passwordConfirmation = "password_confirmation"

        case hasSharingEnabled = "has_sharing_enabled"
        case hasAdNotificationsEnabled = "has_ad_notifications_enabled"
        case hasAutoWatchEnabled = "has_auto_watch_enabled"
        case hasRepostingEnabled = "has_reposting_enabled"
        case allowsAnalytics = "allows_analytics"
        case notifyOfCommentsViaEmail = "notify_of_comments_via_email"
        case notifyOfLovesViaEmail = "notify_of_loves_via_email"
        case notifyOfInvitationAcceptancesViaEmail = "notify_of_invitation_acceptances_via_email"
        case notifyOfMentionsViaEmail = "notify_of_mentions_via_email"
        case notifyOfNewFollowersViaEmail = "notify_of_new_followers_via_email"
        case notifyOfRepostsViaEmail = "notify_of_reposts_via_email"
        case notifyOfWhatYouMissedViaEmail = "notify_of_what_you_missed_via_email"
        case subscribeToUsersEmailList = "subscribe_to_users_email_list"
        case subscribeToDailyEllo = "subscribe_to_daily_ello"
        case subscribeToWeeklyEllo = "subscribe_to_weekly_ello"
        case subscribeToOnboardingDrip = "subscribe_to_onboarding_drip"
        case notifyOfAnnouncementsViaPush = "notify_of_announcements_via_push"
        case notifyOfApprovedSubmissionsViaPush = "notify_of_approved_submissions_via_push"
        case notifyOfCommentsViaPush = "notify_of_comments_via_push"
        case notifyOfLovesViaPush = "notify_of_loves_via_push"
        case notifyOfMentionsViaPush = "notify_of_mentions_via_push"
        case notifyOfRepostsViaPush = "notify_of_reposts_via_push"
        case notifyOfNewFollowersViaPush = "notify_of_new_followers_via_push"
        case notifyOfInvitationAcceptancesViaPush = "notify_of_invitation_acceptances_via_push"
        case notifyOfWatchesViaPush = "notify_of_watches_via_push"
        case notifyOfWatchesViaEmail = "notify_of_watches_via_email"
        case notifyOfCommentsOnPostWatchViaPush = "notify_of_comments_on_post_watch_via_push"
        case notifyOfCommentsOnPostWatchViaEmail = "notify_of_comments_on_post_watch_via_email"
        case notifyOfApprovedSubmissionsFromFollowingViaPush = "notify_of_approved_submissions_from_following_via_push"
        case hasAnnouncementsEnabled = "has_announcements_enabled"
        case discoverable
    }

    let id: String
    let createdAt: Date
    let shortBio: String
    let email: String
    let confirmedAt: Date
    var mutedCount: Int
    var blockedCount: Int
    var creatorTypeCategoryIds: [String]

    // dynamic settings
    @objc var isPublic: Bool
    @objc var isCommunity: Bool
    @objc var hasSharingEnabled: Bool
    @objc var hasAdNotificationsEnabled: Bool
    @objc var hasAutoWatchEnabled: Bool
    @objc let allowsAnalytics: Bool
    @objc let notifyOfCommentsViaEmail: Bool
    @objc let notifyOfLovesViaEmail: Bool
    @objc let notifyOfInvitationAcceptancesViaEmail: Bool
    @objc let notifyOfMentionsViaEmail: Bool
    @objc let notifyOfNewFollowersViaEmail: Bool
    @objc let notifyOfRepostsViaEmail: Bool
    @objc let notifyOfWhatYouMissedViaEmail: Bool
    @objc let subscribeToUsersEmailList: Bool
    @objc let subscribeToDailyEllo: Bool
    @objc let subscribeToWeeklyEllo: Bool
    @objc let subscribeToOnboardingDrip: Bool
    @objc let notifyOfAnnouncementsViaPush: Bool
    @objc let notifyOfApprovedSubmissionsViaPush: Bool
    @objc let notifyOfCommentsViaPush: Bool
    @objc let notifyOfLovesViaPush: Bool
    @objc let notifyOfMentionsViaPush: Bool
    @objc let notifyOfRepostsViaPush: Bool
    @objc let notifyOfNewFollowersViaPush: Bool
    @objc let notifyOfInvitationAcceptancesViaPush: Bool
    @objc var notifyOfWatchesViaPush: Bool
    @objc var notifyOfWatchesViaEmail: Bool
    @objc var notifyOfCommentsOnPostWatchViaPush: Bool
    @objc var notifyOfCommentsOnPostWatchViaEmail: Bool
    @objc var notifyOfApprovedSubmissionsFromFollowingViaPush: Bool
    @objc var hasAnnouncementsEnabled: Bool
    @objc let discoverable: Bool

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
        creatorTypeCategoryIds: [String],
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
        notifyOfWhatYouMissedViaEmail: Bool,
        subscribeToUsersEmailList: Bool,
        subscribeToDailyEllo: Bool,
        subscribeToWeeklyEllo: Bool,
        subscribeToOnboardingDrip: Bool,
        notifyOfAnnouncementsViaPush: Bool,
        notifyOfApprovedSubmissionsViaPush: Bool,
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
        notifyOfApprovedSubmissionsFromFollowingViaPush: Bool,
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
        self.creatorTypeCategoryIds = creatorTypeCategoryIds
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
        self.notifyOfWhatYouMissedViaEmail = notifyOfWhatYouMissedViaEmail
        self.subscribeToUsersEmailList = subscribeToUsersEmailList
        self.subscribeToDailyEllo = subscribeToDailyEllo
        self.subscribeToWeeklyEllo = subscribeToWeeklyEllo
        self.subscribeToOnboardingDrip = subscribeToOnboardingDrip
        self.notifyOfAnnouncementsViaPush = notifyOfAnnouncementsViaPush
        self.notifyOfApprovedSubmissionsViaPush = notifyOfApprovedSubmissionsViaPush
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
        self.notifyOfApprovedSubmissionsFromFollowingViaPush = notifyOfApprovedSubmissionsFromFollowingViaPush
        self.hasAnnouncementsEnabled = hasAnnouncementsEnabled
        self.discoverable = discoverable
        super.init(version: ProfileVersion)
    }

// MARK: NSCoding

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeOptionalKey("id") ?? ""
        self.createdAt = decoder.decodeKey("createdAt")
        self.shortBio = decoder.decodeKey("shortBio")
        self.email = decoder.decodeKey("email")
        self.confirmedAt = decoder.decodeKey("confirmedAt")
        self.isPublic = decoder.decodeKey("isPublic")
        self.mutedCount = decoder.decodeKey("mutedCount")
        self.blockedCount = decoder.decodeKey("blockedCount")

        let version: Int = decoder.decodeKey("version")
        if version < 8 {
            self.notifyOfWhatYouMissedViaEmail = true
        }
        else {
            self.notifyOfWhatYouMissedViaEmail = decoder.decodeKey("notifyOfWhatYouMissedViaEmail")
        }

        if version < 8 {
            self.notifyOfApprovedSubmissionsFromFollowingViaPush = true
        }
        else {
            self.notifyOfApprovedSubmissionsFromFollowingViaPush = decoder.decodeKey("notifyOfApprovedSubmissionsFromFollowingViaPush")
        }

        if version < 7 {
            self.notifyOfApprovedSubmissionsViaPush = true
        }
        else {
            self.notifyOfApprovedSubmissionsViaPush = decoder.decodeKey("notifyOfApprovedSubmissionsViaPush")
        }

        if version < 6 {
            self.creatorTypeCategoryIds = []
        }
        else {
            self.creatorTypeCategoryIds = decoder.decodeKey("creatorTypeCategoryIds")
        }

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

        self.hasSharingEnabled = decoder.decodeKey("hasSharingEnabled")
        self.hasAdNotificationsEnabled = decoder.decodeKey("hasAdNotificationsEnabled")
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
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        coder.encodeObject(shortBio, forKey: "shortBio")
        coder.encodeObject(email, forKey: "email")
        coder.encodeObject(confirmedAt, forKey: "confirmedAt")
        coder.encodeObject(isPublic, forKey: "isPublic")
        coder.encodeObject(isCommunity, forKey: "isCommunity")
        coder.encodeObject(mutedCount, forKey: "mutedCount")
        coder.encodeObject(blockedCount, forKey: "blockedCount")
        coder.encodeObject(creatorTypeCategoryIds, forKey: "creatorTypeCategoryIds")
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
        coder.encodeObject(notifyOfWhatYouMissedViaEmail, forKey: "notifyOfWhatYouMissedViaEmail")
        coder.encodeObject(subscribeToUsersEmailList, forKey: "subscribeToUsersEmailList")
        coder.encodeObject(subscribeToDailyEllo, forKey: "subscribeToDailyEllo")
        coder.encodeObject(subscribeToWeeklyEllo, forKey: "subscribeToWeeklyEllo")
        coder.encodeObject(subscribeToOnboardingDrip, forKey: "subscribeToOnboardingDrip")
        coder.encodeObject(notifyOfAnnouncementsViaPush, forKey: "notifyOfAnnouncementsViaPush")
        coder.encodeObject(notifyOfApprovedSubmissionsViaPush, forKey: "notifyOfApprovedSubmissionsViaPush")
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
        coder.encodeObject(notifyOfApprovedSubmissionsFromFollowingViaPush, forKey: "notifyOfApprovedSubmissionsFromFollowingViaPush")
        coder.encodeObject(hasAnnouncementsEnabled, forKey: "hasAnnouncementsEnabled")
        coder.encodeObject(discoverable, forKey: "discoverable")
        super.encode(with: coder.coder)
    }

// MARK: JSONAble

    class func fromJSON(_ data: [String: Any]) -> Profile {
        let json = JSON(data)
        let creatorTypeCategoryIds: [String] = json["creator_type_category_ids"].arrayValue.flatMap { $0.stringValue }
        // create profile
        let profile = Profile(
            id: json["id"].string ?? "",
            createdAt: (json["created_at"].stringValue.toDate() ?? Globals.now),
            shortBio: json["short_bio"].stringValue,
            email: json["email"].stringValue,
            confirmedAt: (json["confirmed_at"].stringValue.toDate() ?? Globals.now),
            isPublic: json["is_public"].boolValue,
            isCommunity: json["is_community"].boolValue,
            mutedCount: json["muted_count"].intValue,
            blockedCount: json["blocked_count"].intValue,
            creatorTypeCategoryIds: creatorTypeCategoryIds,
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
            notifyOfWhatYouMissedViaEmail: json["notify_of_what_you_missed_via_email"].boolValue,
            subscribeToUsersEmailList: json["subscribe_to_users_email_list"].boolValue,
            subscribeToDailyEllo: json["subscribe_to_daily_ello"].boolValue,
            subscribeToWeeklyEllo: json["subscribe_to_weekly_ello"].boolValue,
            subscribeToOnboardingDrip: json["subscribe_to_onboarding_drip"].boolValue,
            notifyOfAnnouncementsViaPush: json["notify_of_announcements_via_push"].boolValue,
            notifyOfApprovedSubmissionsViaPush: json["notify_of_approved_submissions_via_push"].boolValue,
            notifyOfCommentsViaPush: json["notify_of_comments_via_push"].boolValue,
            notifyOfLovesViaPush: json["notify_of_loves_via_push"].boolValue,
            notifyOfMentionsViaPush: json["notify_of_mentions_via_push"].boolValue,
            notifyOfRepostsViaPush: json["notify_of_reposts_via_push"].boolValue,
            notifyOfNewFollowersViaPush: json["notify_of_new_followers_via_push"].boolValue,
            notifyOfInvitationAcceptancesViaPush: json["notify_of_invitation_acceptances_via_push"].boolValue,
            notifyOfWatchesViaPush: json["notify_of_watches_via_push"].boolValue,
            notifyOfWatchesViaEmail: json["notify_of_watches_via_email"].boolValue,
            notifyOfCommentsOnPostWatchViaPush: json["notify_of_comments_on_post_watch_via_push"].boolValue,
            notifyOfCommentsOnPostWatchViaEmail: json["notify_of_comments_on_post_watch_via_email"].boolValue,
            notifyOfApprovedSubmissionsFromFollowingViaPush: json["notify_of_approved_submissions_from_following_via_push"].boolValue,
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
