////
///  ElloURI.swift
//

import Keys


class ElloURIWrapper: NSObject {
    let uri: ElloURI
    init(uri: ElloURI) { self.uri = uri }
}

enum ElloURI: String {
    // matching stream or page in app
    case discover = "discover(/featured|/recommended)?/?$"
    case discoverRandom = "discover/random/?$"
    case discoverRecent = "discover/recent/?$"
    case discoverRelated = "discover/related/?$"
    case discoverTrending = "discover/trending/?$"
    case category = "discover/([^/]+)/?$"
    case enter = "enter/?$"
    case friends = "friends/?$"
    case following = "following/?$"
    case noise = "noise/?$"
    case notifications = "notifications(?:/?|/([^/]+)/?)$"
    case pushNotificationComment = "notifications/posts/([^/]+)/comments/([^/]+)$"
    case pushNotificationPost = "notifications/posts/([^/]+)/?$"
    case pushNotificationUser = "notifications/users/([^/]+)/?$"
    case post = "post/([^/]+)/?$"           // usernameRegex gets prepended
    case profile = "(?:\\?.*?)?$"           // usernameRegex gets prepended
    case profileFollowers = "/followers/?$" // usernameRegex gets prepended
    case profileFollowing = "/following/?$" // usernameRegex gets prepended
    case profileLoves = "/loves/?$"         // usernameRegex gets prepended
    case search = "(search|find)/?(\\?.*)?$"
    case searchPeople = "(search|find)/people/?(\\?.*)?$"
    case searchPosts = "(search|find)/posts/?(\\?.*)?$"
    case settings = "settings/?$"
    // other ello pages
    case confirm = "confirm/?$"
    case betaPublicProfiles = "beta-public-profiles/?$"
    case exit = "exit/?$"
    case explore = "explore/?$"
    case exploreRecommended = "explore/recommended/?$"
    case exploreRecent = "explore/recent/?$"
    case exploreTrending = "explore/trending/?$"
    case faceMaker = "facemaker/?$"
    case forgotMyPassword = "forgot-password/?$"
    case freedomOfSpeech = "freedom-of-speech/?$"
    case invitations = "invitations/?$"
    case invite = "join/([^/]+)/?$"
    case join = "join/?$"
    case login = "login/?$"
    case manifesto = "manifesto/?$"
    case nativeRedirect = "native_redirect/?$"
    case onboarding = "onboarding/?$"
    case passwordResetError = "password-reset-error/?$"
    case randomSearch = "random_searches/?$"
    case requestInvite = "request-an-invite/?$"
    case requestInvitation = "request-an-invitation/?$"
    case requestInvitations = "request_invitations/?$"
    case resetMyPassword = "auth/reset-my-password/?\\?reset_password_token=([^&]+)$"
    case resetPasswordError = "auth/password-reset-error/?$"
    case root = "?$"
    case signup = "signup/?$"
    case subdomain = "//.+(?<!(w{3}|staging))\\."
    case starred = "starred/?$"
    case unblock = "unblock/?$"
    case whoMadeThis = "who-made-this/?$"
    case wtf = "(wtf$|wtf/.*$)"
    // more specific
    case email = "(.+)@(.+)\\.([a-z]{2,})/?$"
    case external = "https?://.{3,}"

    var loadsInWebViewFromWebView: Bool {
        switch self {
        case .discover,
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
    static let usernameRegex = "([\\w\\-]+)"
    static var userPathRegex: String { return "\(ElloURI.fuzzyDomain)/\(ElloURI.usernameRegex)\\??.*" }

    static func match(_ url: String) -> (type: ElloURI, data: String) {
        let trimmed = ElloURI.replaceElloScheme(url)
        for type in self.all where trimmed.range(of: type.regexPattern, options: .regularExpression) != nil {
            return (type, type.data(trimmed))
        }
        return (self.external, self.external.data(trimmed))
    }

    fileprivate var regexPattern: String {
        switch self {
        case .email,
             .external:
            return rawValue
        case .category, .invite, .notifications, .search:
            return "\(ElloURI.fuzzyDomain)/\(rawValue)"
        case .pushNotificationComment,
             .pushNotificationPost,
             .pushNotificationUser:
            return "\(rawValue)"
        case .post,
             .profile,
             .profileFollowers,
             .profileFollowing,
             .profileLoves:
            return "\(ElloURI.userPathRegex)\(rawValue)"
        case .subdomain:
            return "\(rawValue)\(ElloURI.fuzzyDomain)"
        default:
            return "\(ElloURI.fuzzyDomain)/\(rawValue)"
        }
    }

    fileprivate static func replaceElloScheme(_ path: String) -> String {
        if path.hasPrefix("ello://") {
            return path.replacingOccurrences(of: "ello://", with: "\(baseURL)/")
        }
        if let url = NSURLComponents(string: path),
            items = url.queryItems
            where path.contains("native_redirect")
        {
            for item in items {
                if let value = item.value
                    where item.name == "target"
                {
                    return value
                }
            }
        }
        return path
    }

    fileprivate func data(_ url: String) -> String {
        let regex = Regex(self.regexPattern)
        switch self {
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
        case .category:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .pushNotificationUser:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .pushNotificationComment:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .invite:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .notifications:
            return regex?.matchingGroups(url).safeValue(1) ?? "notifications"
        case .profileFollowers, .profileFollowing, .profileLoves:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .post:
            let last = regex?.matchingGroups(url).safeValue(2) ?? url
            let lastArr = last.characters.split { $0 == "?" }.map { String($0) }
            return lastArr.first ?? last
        case .pushNotificationPost:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .profile:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .resetMyPassword:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .search, .searchPosts, .searchPeople:
            if let urlComponents = URLComponents(string: url),
                let queryItems = urlComponents.queryItems,
                let terms = (queryItems.filter { $0.name == "terms" }.first?.value)
            {
                return terms
            }
            else {
                return ""
            }
        default: return url
        }
    }

    // Order matters: [MostSpecific, MostGeneric]
    static let all = [
        email,
        subdomain,
        post,
        wtf,
        root,
        // generic / pages
        betaPublicProfiles,
        confirm,
        discover,
        discoverRandom,
        discoverRecent,
        discoverRelated,
        discoverTrending,
        category,
        enter,
        exit,
        explore,
        exploreRecommended,
        exploreRecent,
        exploreTrending,
        forgotMyPassword,
        freedomOfSpeech,
        faceMaker,
        friends,
        following,
        invitations,
        invite,
        join,
        signup,
        login,
        manifesto,
        nativeRedirect,
        noise,
        pushNotificationComment,
        pushNotificationPost,
        pushNotificationUser,
        notifications,
        onboarding,
        passwordResetError,
        randomSearch,
        requestInvite,
        requestInvitation,
        requestInvitations,
        resetMyPassword,
        resetPasswordError,
        searchPeople,
        searchPosts,
        search,
        settings,
        starred,
        unblock,
        whoMadeThis,
        // profile specific
        profileFollowing,
        profileFollowers,
        profileLoves,
        profile,
        // anything else
        external
    ]
}
