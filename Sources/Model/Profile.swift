////
///  Profile.swift
//

import SwiftyJSON


@objc(Profile)
final class Profile: Model {
    // version 1: initial
    // version 2: added hasAutoWatchEnabled and moved in notifyOfWatch* settings
    // version 3: added notifyOfAnnouncementsViaPush
    // version 4: added hasAnnouncementsEnabled
    // version 5: added isCommunity
    // version 6: added creatorTypeCategoryIds
    // version 7: added notifyOfApprovedSubmissionsViaPush
    // version 8: added notifyOfApprovedSubmissionsFromFollowingViaPush
    // version 9: added notifyOfWhatYouMissedViaEmail
    // version 10: added notifyOfApprovedSubmissionsFromFollowingViaEmail
    // version 11: added notifyOfFeaturedCategoryPostViaEmail, notifyOfFeaturedCategoryPostViaPush
    static let Version = 11

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

        var trackerName: String {
            switch self {
            case .none:
                return "skipped"
            case .fan:
                return "fan"
            case let .artist(selections):
                return "artist, \(selections.count) selections"
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
        case username
        case email
        case bio = "unsanitized_short_bio"
        case links = "external_links"
        case location
        case avatarURL = "remote_avatar_url"
        case coverImageURL = "remote_cover_image_url"
        case webOnboardingVersion = "web_onboarding_version"
        case creatorTypeCategoryIds = "creator_type_category_ids"

        case currentPassword = "current_password"
        case password
        case passwordConfirmation = "password_confirmation"

        case allowsAnalytics = "allows_analytics"
        case discoverable
        case hasAdNotificationsEnabled = "has_ad_notifications_enabled"
        case hasAnnouncementsEnabled = "has_announcements_enabled"
        case hasAutoWatchEnabled = "has_auto_watch_enabled"
        case hasRepostingEnabled = "has_reposting_enabled"
        case hasSharingEnabled = "has_sharing_enabled"
        case isCollaborateable = "is_collaborateable"
        case isHireable = "is_hireable"
        case notifyOfAnnouncementsViaPush = "notify_of_announcements_via_push"
        case notifyOfApprovedSubmissionsFromFollowingViaEmail = "notify_of_approved_submissions_from_following_via_email"
        case notifyOfFeaturedCategoryPostViaEmail = "notify_of_featured_category_post_via_email"
        case notifyOfFeaturedCategoryPostViaPush = "notify_of_featured_category_post_via_push"
        case notifyOfApprovedSubmissionsFromFollowingViaPush = "notify_of_approved_submissions_from_following_via_push"
        case notifyOfApprovedSubmissionsViaPush = "notify_of_approved_submissions_via_push"
        case notifyOfCommentsOnPostWatchViaEmail = "notify_of_comments_on_post_watch_via_email"
        case notifyOfCommentsOnPostWatchViaPush = "notify_of_comments_on_post_watch_via_push"
        case notifyOfCommentsViaEmail = "notify_of_comments_via_email"
        case notifyOfCommentsViaPush = "notify_of_comments_via_push"
        case notifyOfInvitationAcceptancesViaEmail = "notify_of_invitation_acceptances_via_email"
        case notifyOfInvitationAcceptancesViaPush = "notify_of_invitation_acceptances_via_push"
        case notifyOfLovesViaEmail = "notify_of_loves_via_email"
        case notifyOfLovesViaPush = "notify_of_loves_via_push"
        case notifyOfMentionsViaEmail = "notify_of_mentions_via_email"
        case notifyOfMentionsViaPush = "notify_of_mentions_via_push"
        case notifyOfNewFollowersViaEmail = "notify_of_new_followers_via_email"
        case notifyOfNewFollowersViaPush = "notify_of_new_followers_via_push"
        case notifyOfRepostsViaEmail = "notify_of_reposts_via_email"
        case notifyOfRepostsViaPush = "notify_of_reposts_via_push"
        case notifyOfWatchesViaEmail = "notify_of_watches_via_email"
        case notifyOfWatchesViaPush = "notify_of_watches_via_push"
        case notifyOfWhatYouMissedViaEmail = "notify_of_what_you_missed_via_email"
        case subscribeToDailyEllo = "subscribe_to_daily_ello"
        case subscribeToOnboardingDrip = "subscribe_to_onboarding_drip"
        case subscribeToUsersEmailList = "subscribe_to_users_email_list"
        case subscribeToWeeklyEllo = "subscribe_to_weekly_ello"
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
    @objc var notifyOfApprovedSubmissionsFromFollowingViaEmail: Bool
    @objc var notifyOfFeaturedCategoryPostViaEmail: Bool
    @objc var notifyOfFeaturedCategoryPostViaPush: Bool
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
        notifyOfApprovedSubmissionsFromFollowingViaEmail: Bool,
        notifyOfFeaturedCategoryPostViaEmail: Bool,
        notifyOfFeaturedCategoryPostViaPush: Bool,
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
        discoverable: Bool,
        gaUniqueId: String?)
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
        self.notifyOfApprovedSubmissionsFromFollowingViaEmail = notifyOfApprovedSubmissionsFromFollowingViaEmail
        self.notifyOfFeaturedCategoryPostViaEmail = notifyOfFeaturedCategoryPostViaEmail
        self.notifyOfFeaturedCategoryPostViaPush = notifyOfFeaturedCategoryPostViaPush
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
        self.gaUniqueId = gaUniqueId
        super.init(version: Profile.Version)
    }

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
        if version < 11 {
            self.notifyOfFeaturedCategoryPostViaEmail = true
            self.notifyOfFeaturedCategoryPostViaPush = true
        }
        else {
            self.notifyOfFeaturedCategoryPostViaEmail = decoder.decodeKey("notifyOfFeaturedCategoryPostViaEmail")
            self.notifyOfFeaturedCategoryPostViaPush = decoder.decodeKey("notifyOfFeaturedCategoryPostViaPush")
        }

        if version < 10 {
            self.notifyOfApprovedSubmissionsFromFollowingViaEmail = true
        }
        else {
            self.notifyOfApprovedSubmissionsFromFollowingViaEmail = decoder.decodeKey("notifyOfApprovedSubmissionsFromFollowingViaEmail")
        }

        if version < 9 {
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
        self.gaUniqueId = decoder.decodeOptionalKey("gaUniqueId")
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
        coder.encodeObject(notifyOfApprovedSubmissionsFromFollowingViaEmail, forKey: "notifyOfApprovedSubmissionsFromFollowingViaEmail")
        coder.encodeObject(notifyOfFeaturedCategoryPostViaEmail, forKey: "notifyOfFeaturedCategoryPostViaEmail")
        coder.encodeObject(notifyOfFeaturedCategoryPostViaPush, forKey: "notifyOfFeaturedCategoryPostViaPush")
        coder.encodeObject(hasAnnouncementsEnabled, forKey: "hasAnnouncementsEnabled")
        coder.encodeObject(discoverable, forKey: "discoverable")
        coder.encodeObject(gaUniqueId, forKey: "gaUniqueId")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Profile {
        let json = JSON(data)
        let creatorTypeCategoryIds: [String] = json["creator_type_category_ids"].arrayValue.compactMap { $0.stringValue }

        let profile = Profile(
            id: json["id"].stringValue,
            createdAt: (json["created_at"].stringValue.toDate() ?? Globals.now),
            shortBio: json["short_bio"].stringValue,
            email: json["email"].stringValue,
            confirmedAt: (json["confirmed_at"].stringValue.toDate() ?? Globals.now),
            isPublic: json["is_public"].boolValue,
            isCommunity: json["is_community"].boolValue,
            mutedCount: json["muted_count"].intValue,
            blockedCount: json["blocked_count"].intValue,
            creatorTypeCategoryIds: creatorTypeCategoryIds,
            hasSharingEnabled: json["has_sharing_enabled"].bool ?? false,
            hasAdNotificationsEnabled: json["has_ad_notifications_enabled"].bool ?? false,
            hasAutoWatchEnabled: json["has_auto_watch_enabled"].bool ?? false,
            allowsAnalytics: json["allows_analytics"].bool ?? false,
            notifyOfCommentsViaEmail: json["notify_of_comments_via_email"].bool ?? true,
            notifyOfLovesViaEmail: json["notify_of_loves_via_email"].bool ?? true,
            notifyOfInvitationAcceptancesViaEmail: json["notify_of_invitation_acceptances_via_email"].bool ?? true,
            notifyOfMentionsViaEmail: json["notify_of_mentions_via_email"].bool ?? true,
            notifyOfNewFollowersViaEmail: json["notify_of_new_followers_via_email"].bool ?? true,
            notifyOfRepostsViaEmail: json["notify_of_reposts_via_email"].bool ?? true,
            notifyOfWhatYouMissedViaEmail: json["notify_of_what_you_missed_via_email"].bool ?? true,
            notifyOfApprovedSubmissionsFromFollowingViaEmail: json["notify_of_approved_submissions_from_following_via_email"].bool ?? true,
            notifyOfFeaturedCategoryPostViaEmail: json["notify_of_featured_category_post_via_email"].bool ?? true,
            notifyOfFeaturedCategoryPostViaPush: json["notify_of_featured_category_post_via_push"].bool ?? true,
            subscribeToUsersEmailList: json["subscribe_to_users_email_list"].bool ?? true,
            subscribeToDailyEllo: json["subscribe_to_daily_ello"].bool ?? true,
            subscribeToWeeklyEllo: json["subscribe_to_weekly_ello"].bool ?? true,
            subscribeToOnboardingDrip: json["subscribe_to_onboarding_drip"].bool ?? true,
            notifyOfAnnouncementsViaPush: json["notify_of_announcements_via_push"].bool ?? true,
            notifyOfApprovedSubmissionsViaPush: json["notify_of_approved_submissions_via_push"].bool ?? true,
            notifyOfCommentsViaPush: json["notify_of_comments_via_push"].bool ?? true,
            notifyOfLovesViaPush: json["notify_of_loves_via_push"].bool ?? true,
            notifyOfMentionsViaPush: json["notify_of_mentions_via_push"].bool ?? true,
            notifyOfRepostsViaPush: json["notify_of_reposts_via_push"].bool ?? true,
            notifyOfNewFollowersViaPush: json["notify_of_new_followers_via_push"].bool ?? true,
            notifyOfInvitationAcceptancesViaPush: json["notify_of_invitation_acceptances_via_push"].bool ?? true,
            notifyOfWatchesViaPush: json["notify_of_watches_via_push"].bool ?? true,
            notifyOfWatchesViaEmail: json["notify_of_watches_via_email"].bool ?? true,
            notifyOfCommentsOnPostWatchViaPush: json["notify_of_comments_on_post_watch_via_push"].bool ?? true,
            notifyOfCommentsOnPostWatchViaEmail: json["notify_of_comments_on_post_watch_via_email"].bool ?? true,
            notifyOfApprovedSubmissionsFromFollowingViaPush: json["notify_of_approved_submissions_from_following_via_push"].bool ?? true,
            hasAnnouncementsEnabled: json["has_announcements_enabled"].bool ?? true,
            discoverable: json["discoverable"].bool ?? true,
            gaUniqueId: json["ga_unique_id"].string
        )
        return profile
    }
}

extension Profile: JSONSaveable {
    var uniqueId: String? { return "Profile-\(id)" }
    var tableId: String? { return id }
}
