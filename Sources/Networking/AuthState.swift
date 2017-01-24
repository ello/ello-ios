////
///  AuthState.swift
//

import Foundation

enum AuthState {
    static var uuid: UUID = UUID()

    case initial  // auth is in indeterminate state

    case noToken  // no auth or refresh token
    case anonymous  // anonymous token present
    case authenticated  // aww yeah - has token AND refreshToken

    case userCredsSent  // creds have been sent
    case shouldTryUserCreds  // network is offline

    case refreshTokenSent  // request is in flight
    case shouldTryRefreshToken  // network is offline

    case anonymousCredsSent
    case shouldTryAnonymousCreds

    fileprivate var nextStates: [AuthState] {
        switch self {
        case .initial: return [.noToken, .anonymous, .authenticated]

        case .noToken: return [.authenticated, .userCredsSent, .anonymousCredsSent, .shouldTryAnonymousCreds]
        case .anonymous: return [.userCredsSent, .noToken]
        case .authenticated: return [.refreshTokenSent, .noToken]

        case .refreshTokenSent: return [.authenticated, .shouldTryRefreshToken, .shouldTryUserCreds]
        case .shouldTryRefreshToken: return [.refreshTokenSent]

        case .userCredsSent: return [.noToken, .authenticated, .shouldTryUserCreds]
        case .shouldTryUserCreds: return [.userCredsSent]

        case .anonymousCredsSent: return [.noToken, .anonymous]
        case .shouldTryAnonymousCreds: return [.anonymousCredsSent]
        }
    }

    var isAuthenticated: Bool {
        switch self {
        case .authenticated: return true
        default: return false
        }
    }

    var isUndetermined: Bool {
        switch self {
        case .initial, .noToken: return true
        default: return false
        }
    }

    var isTransitioning: Bool {
        switch self {
        case .authenticated, .anonymous: return false
        default: return true
        }
    }

    func canTransitionTo(_ state: AuthState) -> Bool {
        return nextStates.contains(state)
    }

    func supports(_ target: ElloAPI) -> Bool {
        if !target.requiresAnyToken {
            return true
        }

        if isTransitioning {
            return false
        }

        if isAuthenticated {
            return true
        }

        return target.supportsAnonymousToken && self == .anonymous
    }

}
