////
///  AuthToken.swift
//

import Foundation
import SwiftyJSON


public struct AuthToken {
    static var sharedKeychain: KeychainType = ElloKeychain()
    var keychain: KeychainType

    // MARK: - Initializers

    public init() {
        keychain = AuthToken.sharedKeychain
    }

    // MARK: - Properties

    public var tokenWithBearer: String? {
        get {
            if let key = keychain.authToken {
                return "Bearer \(key)"
            }
            else { return nil }
        }
    }

    public var token: String? {
        get { return keychain.authToken }
        set(newToken) { keychain.authToken = newToken }
    }

    public var type: String? {
        get { return keychain.authTokenType }
        set(newType) { keychain.authTokenType = newType }
    }

    public var refreshToken: String? {
        get { return keychain.refreshAuthToken }
        set(newRefreshToken) { keychain.refreshAuthToken = newRefreshToken }
    }

    public var isPresent: Bool {
        return (token ?? "").characters.count > 0
    }

    public var isPasswordBased: Bool {
        get { return isPresent && keychain.isPasswordBased ?? false }
        set { keychain.isPasswordBased = newValue }
    }

    public var isAnonymous: Bool {
        return isPresent && !isPasswordBased
    }

    public var username: String? {
        get { return keychain.username }
        set { keychain.username = newValue }
    }

    public var password: String? {
        get { return keychain.password }
        set { keychain.password = newValue }
    }

    public static func storeToken(data: NSData, isPasswordBased: Bool, email: String? = nil, password: String? = nil) {
        var authToken = AuthToken()
        authToken.isPasswordBased = isPasswordBased

        do {
            let json = try JSON(data: data)
            if let email = email {
                authToken.username = email
            }
            if let password = password {
                authToken.password = password
            }
            authToken.token = json["access_token"].stringValue
            authToken.type = json["token_type"].stringValue
            authToken.refreshToken = json["refresh_token"].stringValue
        }
        catch {
            log("token JSON failure", object: "failed to create JSON and store authToken")
        }
    }

    static func reset() {
        var keychain = sharedKeychain
        keychain.authToken = nil
        keychain.refreshAuthToken = nil
        keychain.authTokenType = nil
        keychain.isPasswordBased = false
        keychain.username = nil
        keychain.password = nil
    }
}
