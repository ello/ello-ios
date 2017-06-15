////
///  APIKeys.swift
//

import Keys


struct APIKeys {
    let key: String
    let secret: String
    let segmentKey: String
    let domain: String

    // MARK: Shared Keys

    static let `default`: APIKeys = {
        return APIKeys(
            key: ElloKeys().oauthKey(),
            secret: ElloKeys().oauthSecret(),
            segmentKey: ElloKeys().segmentKey(),
            domain: ElloKeys().domain()
            )
    }()
    static let ninja: APIKeys = {
        return APIKeys(
            key: ElloKeys().ninjaOauthKey(),
            secret: ElloKeys().ninjaOauthSecret(),
            segmentKey: ElloKeys().stagingSegmentKey(),
            domain: ElloKeys().ninjaDomain()
            )
    }()
    static let stage1: APIKeys = {
        return APIKeys(
            key: ElloKeys().stage1OauthKey(),
            secret: ElloKeys().stage1OauthSecret(),
            segmentKey: ElloKeys().stagingSegmentKey(),
            domain: ElloKeys().stage1Domain()
            )
    }()
    static let stage2: APIKeys = {
        return APIKeys(
            key: ElloKeys().stage2OauthKey(),
            secret: ElloKeys().stage2OauthSecret(),
            segmentKey: ElloKeys().stagingSegmentKey(),
            domain: ElloKeys().stage2Domain()
            )
    }()

    static var shared = APIKeys.default

    // MARK: Initializers

    init(key: String, secret: String, segmentKey: String, domain: String) {
        self.key = key
        self.secret = secret
        self.segmentKey = segmentKey
        self.domain = domain
    }
}
