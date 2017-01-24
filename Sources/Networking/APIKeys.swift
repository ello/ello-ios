////
///  APIKeys.swift
//

import Foundation
import Keys

// Mark: - API Keys

struct APIKeys {
    let key: String
    let secret: String

    // MARK: Shared Keys

    fileprivate struct SharedKeys {
        static var instance = APIKeys()
    }

    static var sharedKeys: APIKeys {
        get {
        return SharedKeys.instance
        }

        set (newSharedKeys) {
            SharedKeys.instance = newSharedKeys
        }
    }

    // MARK: Methods

    var stubResponses: Bool {
        return key.characters.count == 0 || secret.characters.count == 0
    }

    // MARK: Initializers

    init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }

    init() {
        let key: String = ElloKeys().oauthKey()
        let secret: String = ElloKeys().oauthSecret()
        self.init(key: key, secret: secret)
    }
}
