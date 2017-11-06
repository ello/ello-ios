////
///  ElloURI.swift
//

import Keys


class ElloURIWrapper: NSObject {
    let uri: ElloURI
    init(uri: ElloURI) { self.uri = uri }
}

enum ElloURI {
    // more specific
    case artistInvitesBrowse
    case artistInvitesDetail
    case betaPublicProfiles
    case category
    case confirm
    case discover
    case discoverRandom
    case discoverRecent
    case discoverRelated
    case discoverTrending
    case email
    case enter
    case exit
    case explore
    case exploreRecent
    case exploreRecommended
    case exploreTrending
    case external
    case faceMaker
    case following
    case forgotMyPassword
    case freedomOfSpeech
    case friends
    case invitations
    case invite
    case join
    case login
    case manifesto
    case nativeRedirect
    case noise
    case notifications
    case onboarding
    case passwordResetError
    case post
    case profile
    case profileFollowers
    case profileFollowing
    case profileLoves
    case pushNotificationArtistInvite
    case pushNotificationComment
    case pushNotificationPost
    case pushNotificationUser
    case randomSearch
    case requestInvitation
    case requestInvitations
    case requestInvite
    case resetMyPassword
    case resetPasswordError
    case root
    case search
    case searchPeople
    case searchPosts
    case settings
    case signup
    case starred
    case subdomain
    case unblock
    case whoMadeThis
    case wtf

    var regexPattern: String {
        switch self {
        case .email:                        return "(.+)@(.+)\\.([a-z]{2,})/?$"
        case .external:                     return "https?://.{3,}"
        case .pushNotificationArtistInvite: return "notifications/artist-invites/([^/]+)$"
        case .pushNotificationComment:      return "notifications/posts/([^/]+)/comments/([^/]+)$"
        case .pushNotificationPost:         return "notifications/posts/([^/]+)/?$"
        case .pushNotificationUser:         return "notifications/users/([^/]+)/?$"

        case .post:             return "\(ElloURI.userPathRegex)post/([^/]+)/?$"
        case .profile:          return "\(ElloURI.userPathRegex)(?:\\?.*?)?$"
        case .profileFollowers: return "\(ElloURI.userPathRegex)/followers/?$"
        case .profileFollowing: return "\(ElloURI.userPathRegex)/following/?$"
        case .profileLoves:     return "\(ElloURI.userPathRegex)/loves/?$"

        case .subdomain: return "//.+(?<!(w{3}|staging))\\.\(ElloURI.fuzzyDomain)"

        case .artistInvitesBrowse: return "\(ElloURI.fuzzyDomain)/artist-invites/?$"
        case .artistInvitesDetail: return "\(ElloURI.fuzzyDomain)/artist-invites/([^/]+)/?$"
        case .betaPublicProfiles:  return "\(ElloURI.fuzzyDomain)/beta-public-profiles/?$"
        case .category:            return "\(ElloURI.fuzzyDomain)/discover/([^/]+)/?$"
        case .confirm:             return "\(ElloURI.fuzzyDomain)/confirm/?$"
        case .discover:            return "\(ElloURI.fuzzyDomain)/discover(/featured|/recommended)?/?$"
        case .discoverRandom:      return "\(ElloURI.fuzzyDomain)/discover/random/?$"
        case .discoverRecent:      return "\(ElloURI.fuzzyDomain)/discover/recent/?$"
        case .discoverRelated:     return "\(ElloURI.fuzzyDomain)/discover/related/?$"
        case .discoverTrending:    return "\(ElloURI.fuzzyDomain)/discover/trending/?$"
        case .enter:               return "\(ElloURI.fuzzyDomain)/enter/?$"
        case .exit:                return "\(ElloURI.fuzzyDomain)/exit/?$"
        case .explore:             return "\(ElloURI.fuzzyDomain)/explore/?$"
        case .exploreRecent:       return "\(ElloURI.fuzzyDomain)/explore/recent/?$"
        case .exploreRecommended:  return "\(ElloURI.fuzzyDomain)/explore/recommended/?$"
        case .exploreTrending:     return "\(ElloURI.fuzzyDomain)/explore/trending/?$"
        case .faceMaker:           return "\(ElloURI.fuzzyDomain)/facemaker/?$"
        case .following:           return "\(ElloURI.fuzzyDomain)/following/?$"
        case .forgotMyPassword:    return "\(ElloURI.fuzzyDomain)/forgot-password/?$"
        case .freedomOfSpeech:     return "\(ElloURI.fuzzyDomain)/freedom-of-speech/?$"
        case .friends:             return "\(ElloURI.fuzzyDomain)/friends/?$"
        case .invitations:         return "\(ElloURI.fuzzyDomain)/invitations/?$"
        case .invite:              return "\(ElloURI.fuzzyDomain)/join/([^/]+)/?$"
        case .join:                return "\(ElloURI.fuzzyDomain)/join/?$"
        case .login:               return "\(ElloURI.fuzzyDomain)/login/?$"
        case .manifesto:           return "\(ElloURI.fuzzyDomain)/manifesto/?$"
        case .nativeRedirect:      return "\(ElloURI.fuzzyDomain)/native_redirect/?$"
        case .noise:               return "\(ElloURI.fuzzyDomain)/noise/?$"
        case .notifications:       return "\(ElloURI.fuzzyDomain)/notifications(?:/?|/([^/]+)/?)$"
        case .onboarding:          return "\(ElloURI.fuzzyDomain)/onboarding/?$"
        case .passwordResetError:  return "\(ElloURI.fuzzyDomain)/password-reset-error/?$"
        case .randomSearch:        return "\(ElloURI.fuzzyDomain)/random_searches/?$"
        case .requestInvitation:   return "\(ElloURI.fuzzyDomain)/request-an-invitation/?$"
        case .requestInvitations:  return "\(ElloURI.fuzzyDomain)/request_invitations/?$"
        case .requestInvite:       return "\(ElloURI.fuzzyDomain)/request-an-invite/?$"
        case .resetMyPassword:     return "\(ElloURI.fuzzyDomain)/auth/reset-my-password/?\\?reset_password_token=([^&]+)$"
        case .resetPasswordError:  return "\(ElloURI.fuzzyDomain)/auth/password-reset-error/?$"
        case .root:                return "\(ElloURI.fuzzyDomain)/?$"
        case .search:              return "\(ElloURI.fuzzyDomain)/(search|find)/?(\\?.*)?$"
        case .searchPeople:        return "\(ElloURI.fuzzyDomain)/(search|find)/people/?(\\?.*)?$"
        case .searchPosts:         return "\(ElloURI.fuzzyDomain)/(search|find)/posts/?(\\?.*)?$"
        case .settings:            return "\(ElloURI.fuzzyDomain)/settings/?$"
        case .signup:              return "\(ElloURI.fuzzyDomain)/signup/?$"
        case .starred:             return "\(ElloURI.fuzzyDomain)/starred/?$"
        case .unblock:             return "\(ElloURI.fuzzyDomain)/unblock/?$"
        case .whoMadeThis:         return "\(ElloURI.fuzzyDomain)/who-made-this/?$"
        case .wtf:                 return "\(ElloURI.fuzzyDomain)/(wtf$|wtf/.*$)"
        }
    }

    var loadsInWebViewFromWebView: Bool {
        switch self {
        case .artistInvitesBrowse,
             .artistInvitesDetail,
             .discover,
             .category,
             .email,
             .enter,
             .explore,
             .following,
             .starred,
             .notifications,
             .post,
             .profile,
             .root,
             .search,
             .settings:
            return false
        default: return true
        }
    }

    var requiresLogin: Bool {
        switch self {
        case .settings, .notifications, .following, .starred, .friends, .noise,
             .invitations, .onboarding, .unblock:
            return true
        default:
            return false
        }
    }

    var shouldLoadInApp: Bool {
        switch self {
        case .confirm,
             .email,
             .external,
             .faceMaker,
             .freedomOfSpeech,
             .manifesto,
             .nativeRedirect,
             .passwordResetError,
             .randomSearch,
             .requestInvitation,
             .requestInvitations,
             .requestInvite,
             .resetPasswordError,
             .subdomain,
             .unblock,
             .whoMadeThis:
            return false
        default:
            return true
        }
    }

    static var baseURL: String { return APIKeys.shared.domain }

    // this is taken directly from app/models/user.rb
    static let fuzzyDomain: String = "(?:(?:w{3}\\.)?ello\\.(?:ninja|co)|ello-stag(?:ing|e)\\d?\\.herokuapp\\.com|ello-fg-stage\\d?\\.herokuapp\\.com)"
    static var userPathRegex: String { return "\(ElloURI.fuzzyDomain)/([\\w\\-]+)\\??.*" }

    static func match(_ url: String) -> (type: ElloURI, data: String?) {
        let trimmed = ElloURI.replaceElloScheme(url)
        for type in self.all where trimmed.range(of: type.regexPattern, options: .regularExpression) != nil {
            return (type, type.data(trimmed))
        }
        return (self.external, self.external.data(trimmed))
    }

    private static func replaceElloScheme(_ path: String) -> String {
        if path.hasPrefix("ello://") {
            return path.replacingOccurrences(of: "ello://", with: "\(baseURL)/")
        }
        return path
    }

    private func data(_ url: String) -> String? {
        let regex = Regex(regexPattern)
        switch self {
        case .subdomain, .email, .external, .root:
            return url
        case .discover:
            return "recommended"
        case .discoverRandom:
            return "random"
        case .discoverRecent:
            return "recent"
        case .discoverRelated:
            return "related"
        case .discoverTrending:
            return "trending"
        case .artistInvitesDetail:
            return regex?.matchingGroups(url).safeValue(1)
        case .category:
            return regex?.matchingGroups(url).safeValue(1)
        case .invite:
            return regex?.matchingGroups(url).safeValue(1)
        case .notifications:
            return regex?.matchingGroups(url).safeValue(1)
        case .profileFollowers, .profileFollowing, .profileLoves:
            return regex?.matchingGroups(url).safeValue(1)
        case .post:
            let last = regex?.matchingGroups(url).safeValue(2)
            let lastArr = last?.split { $0 == "?" }.map { String($0) }
            return lastArr?.first ?? last
        case .pushNotificationArtistInvite:
            return regex?.matchingGroups(url).safeValue(1)
        case .pushNotificationComment:
            return regex?.matchingGroups(url).safeValue(1)
        case .pushNotificationPost:
            return regex?.matchingGroups(url).safeValue(1)
        case .pushNotificationUser:
            return regex?.matchingGroups(url).safeValue(1)
        case .profile:
            return regex?.matchingGroups(url).safeValue(1)
        case .resetMyPassword:
            return regex?.matchingGroups(url).safeValue(1)
        case .search, .searchPosts, .searchPeople:
            guard let urlComponents = URLComponents(string: url),
                let queryItems = urlComponents.queryItems,
                let terms = (queryItems.filter { $0.name == "terms" }.first?.value)
            else { return nil }
            return terms
        default:
            return nil
        }
    }

    // Order matters: [most specific ... most generic]
    static let all: [ElloURI] = [
        .email,
        .subdomain,
        .post,
        .wtf,
        .root,
        // generic / pages
        .betaPublicProfiles,
        .confirm,
        .discover,
        .discoverRandom,
        .discoverRecent,
        .discoverRelated,
        .discoverTrending,
        .category,
        .artistInvitesBrowse,
        .artistInvitesDetail,
        .enter,
        .exit,
        .explore,
        .exploreRecommended,
        .exploreRecent,
        .exploreTrending,
        .forgotMyPassword,
        .freedomOfSpeech,
        .faceMaker,
        .friends,
        .following,
        .invitations,
        .invite,
        .join,
        .signup,
        .login,
        .manifesto,
        .nativeRedirect,
        .noise,
        .pushNotificationArtistInvite,
        .pushNotificationComment,
        .pushNotificationPost,
        .pushNotificationUser,
        .notifications,
        .onboarding,
        .passwordResetError,
        .randomSearch,
        .requestInvite,
        .requestInvitation,
        .requestInvitations,
        .resetMyPassword,
        .resetPasswordError,
        .searchPeople,
        .searchPosts,
        .search,
        .settings,
        .starred,
        .unblock,
        .whoMadeThis,
        // profile specific
        .profileFollowing,
        .profileFollowers,
        .profileLoves,
        .profile,
        // anything else
        .external,
    ]
}
