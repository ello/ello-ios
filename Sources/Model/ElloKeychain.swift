////
///  ElloKeychain.swift
//

import KeychainAccess
import Keys


protocol KeychainType {
    var pushToken: Data? { get set }
    var authToken: String? { get set }
    var refreshAuthToken: String? { get set }
    var authTokenType: String? { get set }
    var isPasswordBased: Bool? { get set }
    var username: String? { get set }
    var password: String? { get set }
    var isStaff: Bool? { get set }
    var isNabaroo: Bool? { get set }
}

private let PushToken = "ElloPushToken"
private let AuthTokenKey = "ElloAuthToken"
private let AuthTokenRefresh = "ElloAuthTokenRefresh"
private let AuthTokenType = "ElloAuthTokenType"
private let AuthTokenAuthenticated = "ElloAuthTokenAuthenticated"
private let AuthUsername = "ElloAuthUsername"
private let AuthPassword = "ElloAuthPassword"
private let AuthIsStaff = "ElloAuthIsStaff"
private let AuthIsNabaroo = "ElloAuthIsNabaroo"

struct ElloKeychain: KeychainType {
    var keychain: Keychain

    init() {
        let appIdentifierPrefix: String = ElloKeys().teamId()
        keychain = Keychain(
            service: "co.ello.Ello",
            accessGroup: "\(appIdentifierPrefix).co.ello.Ello"
        )
    }

    var pushToken: Data? {
        get { return keychain[data: PushToken] }
        set { keychain[data: PushToken] = newValue }
    }

    var authToken: String? {
        get { return keychain[AuthTokenKey] }
        set { keychain[AuthTokenKey] = newValue }
    }

    var refreshAuthToken: String? {
        get { return keychain[AuthTokenRefresh] }
        set { keychain[AuthTokenRefresh] = newValue }
    }

    var authTokenType: String? {
        get { return keychain[AuthTokenType] }
        set { keychain[AuthTokenType] = newValue }
    }

    var username: String? {
        get { return keychain[AuthUsername] }
        set { keychain[AuthUsername] = newValue }
    }

    var password: String? {
        get { return keychain[AuthPassword] }
        set { keychain[AuthPassword] = newValue }
    }

    var isPasswordBased: Bool? {
        get { return keychain[data: AuthTokenAuthenticated]?.toBool() }
        set { keychain[data: AuthTokenAuthenticated] = newValue?.toData() }
    }

    var isStaff: Bool? {
        get { return keychain[data: AuthIsStaff]?.toBool() }
        set { keychain[data: AuthIsStaff] = newValue?.toData() }
    }

    var isNabaroo: Bool? {
        get { return keychain[data: AuthIsNabaroo]?.toBool() }
        set { keychain[data: AuthIsNabaroo] = newValue?.toData() }
    }
}

extension Data {
    func toBool() -> Bool? {
        return (NSKeyedUnarchiver.unarchiveObject(with: self) as? NSNumber)?.boolValue
    }
}

extension Bool {
    func toData() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: NSNumber(value: self))
    }
}

extension Keychain {

    func updateIfNeeded(_ value: String, key: String) throws {
        if self[key] != value {
            try self.set(value, key: key)
        }
    }
}
