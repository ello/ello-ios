////
///  ElloURI.swift
//

import Foundation
import Keys

enum ElloURI: String {
    // matching stream or page in app
    case discover = "discover(/featured|/recommended)?/?$"
    case discoverRandom = "discover/random"
    case discoverRecent = "discover/recent"
    case discoverRelated = "discover/related"
    case discoverTrending = "discover/trending"
    case category = "discover/([^\\/]+)/?$"
    case enter = "enter"
    case friends = "friends"
    case following = "following"
    case noise = "noise"
    case notifications = "notifications(?:\\/?|\\/([^\\/]+)/?)$"
    case pushNotificationComment = "notifications/posts/([^\\/]+)\\/comments/([^\\/]+)$"
    case pushNotificationPost = "notifications/posts/([^\\/]+)\\/?$"
    case pushNotificationUser = "notifications/users/([^\\/]+)\\/?$"
    case post = "\\/post\\/([^\\/]+)\\/?$"
    case profile = "\\/?$"
    case profileFollowers = "followers\\/?$"
    case profileFollowing = "following\\/?$"
    case profileLoves = "loves\\/?$"
    case search = "(search|find)\\b\\/?(\\?*.)?"
    case searchPeople = "(search|find)/people"
    case searchPosts = "(search|find)/posts"
    case settings = "settings"
    // other ello pages
    case confirm = "confirm"
    case betaPublicProfiles = "beta-public-profiles"
    case downloads = "downloads"
    case exit = "exit"
    case explore = "explore"
    case exploreRecommended = "explore/recommended"
    case exploreRecent = "explore/recent"
    case exploreTrending = "explore/trending"
    case faceMaker = "facemaker"
    case forgotMyPassword = "forgot-my-password"
    case freedomOfSpeech = "freedom-of-speech"
    case invitations = "invitations"
    case invite = "join/([^\\/]+)/?$"
    case join = "join"
    case login = "login"
    case manifesto = "manifesto"
    case nativeRedirect = "native_redirect"
    case onboarding = "onboarding"
    case passwordResetError = "password-reset-error"
    case randomSearch = "random_searches"
    case requestInvite = "request-an-invite"
    case requestInvitation = "request-an-invitation"
    case requestInvitations = "request_invitations"
    case resetMyPassword = "reset-my-password"
    case root = "?$"
    case subdomain = "\\/\\/.+(?<!(w{3}|staging))\\."
    case starred = "starred"
    case unblock = "unblock"
    case whoMadeThis = "who-made-this"
    case wtf = "(wtf$|wtf\\/.*$)"
    // more specific
    case email = "(.+)@(.+)\\.([a-z]{2,})"
    case external = "https?:\\/\\/.{3,}"

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

    var shouldLoadInApp: Bool {
        switch self {
        case .confirm,
             .downloads,
             .email,
             .external,
             .faceMaker,
             .forgotMyPassword,
             .freedomOfSpeech,
             .manifesto,
             .nativeRedirect,
             .passwordResetError,
             .randomSearch,
             .requestInvitation,
             .requestInvitations,
             .requestInvite,
             .resetMyPassword,
             .subdomain,
             .unblock,
             .whoMadeThis:
            return false
        default:
            return true
        }
    }

    // get the proper domain
    fileprivate static var _httpProtocol: String?
    static var httpProtocol: String {
        get {
            return ElloURI._httpProtocol ?? ElloKeys().httpProtocol()
        }
        set {
            if AppSetup.sharedState.isTesting {
                ElloURI._httpProtocol = newValue
            }
        }
    }
    fileprivate static var _domain: String?
    static var domain: String {
        get {
        return ElloURI._domain ?? ElloKeys().domain()
        }
        set {
            if AppSetup.sharedState.isTesting {
                ElloURI._domain = newValue
            }
        }
    }
    static var baseURL: String { return "\(ElloURI.httpProtocol)://\(ElloURI.domain)" }

    // this is taken directly from app/models/user.rb
    static let usernameRegex = "([\\w\\-]+)"
    static let fuzzyDomain: String = "((w{3}\\.)?ello\\.(?:ninja|co)|ello-stag(?:ing|e)\\d?\\.herokuapp\\.com|ello-fg-stage\\d?\\.herokuapp\\.com)"
    static var userPathRegex: String { return "\(ElloURI.fuzzyDomain)\\/\(ElloURI.usernameRegex)\\??.*" }

    static func match(_ url: String) -> (type: ElloURI, data: String) {
        let trimmed = ElloURI.replaceElloScheme(url)
        for type in self.all {
            if let _ = trimmed.range(of: type.regexPattern, options: .regularExpression) {
                return (type, type.data(trimmed))
            }
        }
        return (self.external, self.external.data(trimmed))
    }

    fileprivate var regexPattern: String {
        switch self {
        case .email,
             .external:
            return rawValue
        case .category, .invite, .notifications, .search:
            return "\(ElloURI.fuzzyDomain)\\/\(rawValue)"
        case .post:
            return "\(ElloURI.userPathRegex)\(rawValue)"
        case .pushNotificationComment,
             .pushNotificationPost,
             .pushNotificationUser:
            return "\(rawValue)"
        case .profile:
            return "\(ElloURI.userPathRegex)\(rawValue)"
        case .profileFollowers,
             .profileFollowing,
             .profileLoves:
            return "\(ElloURI.userPathRegex)\(rawValue)"
        case .subdomain:
            return "\(rawValue)\(ElloURI.fuzzyDomain)"
        default:
            return "\(ElloURI.fuzzyDomain)\\/\(rawValue)\\/?$"
        }
    }

    fileprivate static func replaceElloScheme(_ path: String) -> String {
        if path.hasPrefix("ello://") {
            return path.replacingOccurrences(of: "ello://", with: "\(baseURL)/")
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
            return regex?.matchingGroups(url).safeValue(2) ?? url
        case .pushNotificationUser:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .pushNotificationComment:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .invite:
            return regex?.matchingGroups(url).safeValue(2) ?? url
        case .notifications:
            return regex?.matchingGroups(url).safeValue(2) ?? "notifications"
        case .profileFollowers, .profileFollowing, .profileLoves:
            return regex?.matchingGroups(url).safeValue(2) ?? url
        case .post:
            let last = regex?.matchingGroups(url).safeValue(3) ?? url
            let lastArr = last.characters.split { $0 == "?" }.map { String($0) }
            return lastArr.first ?? last
        case .pushNotificationPost:
            return regex?.matchingGroups(url).safeValue(1) ?? url
        case .profile:
            return regex?.matchingGroups(url).safeValue(2) ?? url
        case .search:
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
        downloads,
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
