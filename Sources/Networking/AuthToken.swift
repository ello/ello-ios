////
///  AuthToken.swift
//

import Foundation
import SwiftyJSON


struct AuthToken {
    static var sharedKeychain: KeychainType = ElloKeychain()
    var keychain: KeychainType

    // MARK: - Initializers

    init() {
        keychain = AuthToken.sharedKeychain
    }

    // MARK: - Properties

    var tokenWithBearer: String? {
        get {
            if let key = keychain.authToken {
                return "Bearer \(key)"
            }
            else { return nil }
        }
    }

    var token: String? {
        get { return keychain.authToken }
        set(newToken) { keychain.authToken = newToken }
    }

    var type: String? {
        get { return keychain.authTokenType }
        set(newType) { keychain.authTokenType = newType }
    }

    var refreshToken: String? {
        get { return keychain.refreshAuthToken }
        set(newRefreshToken) { keychain.refreshAuthToken = newRefreshToken }
    }

    var isPresent: Bool {
        return (token ?? "").characters.count > 0
    }

    var isPasswordBased: Bool {
        get { return isPresent && keychain.isPasswordBased ?? false }
        set { keychain.isPasswordBased = newValue }
    }

    var isAnonymous: Bool {
        return isPresent && !isPasswordBased
    }

    var username: String? {
        get { return keychain.username }
        set { keychain.username = newValue }
    }

    var password: String? {
        get { return keychain.password }
        set { keychain.password = newValue }
    }

    var isStaff: Bool {
        get { return keychain.isStaff ?? false }
        set { keychain.isStaff = newValue }
    }

    static func storeToken(_ data: Data, isPasswordBased: Bool, email: String? = nil, password: String? = nil) {
        var authToken = AuthToken()
        authToken.isPasswordBased = isPasswordBased

        let json = JSON(data: data)
        if let email = email {
            authToken.username = email
        }
        if let password = password {
            authToken.password = password
        }
        authToken.token = json["access_token"].stringValue
        authToken.type = json["token_type"].stringValue
        authToken.refreshToken = json["refresh_token"].stringValue

        JWT.refresh()
    }

    static func reset() {
        var keychain = sharedKeychain
        keychain.authToken = nil
        keychain.refreshAuthToken = nil
        keychain.authTokenType = nil
        keychain.isPasswordBased = false
        keychain.username = nil
        keychain.password = nil
        keychain.isStaff = nil
    }
}
