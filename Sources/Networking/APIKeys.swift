////
///  APIKeys.swift
//

import Keys


struct APIKeys {
    let key: String
    let secret: String
    let segmentKey: String
    let domain: String
    var hasGraphQL: Bool

    static let `default`: APIKeys = {
        return APIKeys(
            key: ElloKeys().oauthKey(),
            secret: ElloKeys().oauthSecret(),
            segmentKey: ElloKeys().segmentKey(),
            domain: ElloKeys().domain(),
            hasGraphQL: false
        )
    }()
    static let ninja: APIKeys = {
        return APIKeys(
            key: ElloKeys().ninjaOauthKey(),
            secret: ElloKeys().ninjaOauthSecret(),
            segmentKey: ElloKeys().stagingSegmentKey(),
            domain: ElloKeys().ninjaDomain(),
            hasGraphQL: false
        )
    }()
    static let stage1: APIKeys = {
        return APIKeys(
            key: ElloKeys().stage1OauthKey(),
            secret: ElloKeys().stage1OauthSecret(),
            segmentKey: ElloKeys().stagingSegmentKey(),
            domain: ElloKeys().stage1Domain(),
            hasGraphQL: false
        )
    }()
    static let stage2: APIKeys = {
        return APIKeys(
            key: ElloKeys().stage2OauthKey(),
            secret: ElloKeys().stage2OauthSecret(),
            segmentKey: ElloKeys().stagingSegmentKey(),
            domain: ElloKeys().stage2Domain(),
            hasGraphQL: true
        )
    }()
    static let rainbow: APIKeys = {
        return APIKeys(
            key: ElloKeys().rainbowOauthKey(),
            secret: ElloKeys().rainbowOauthSecret(),
            segmentKey: ElloKeys().stagingSegmentKey(),
            domain: ElloKeys().rainbowDomain(),
            hasGraphQL: false
        )
    }()

    static var shared = APIKeys.default

    init(key: String, secret: String, segmentKey: String, domain: String, hasGraphQL: Bool) {
        self.key = key
        self.secret = secret
        self.segmentKey = segmentKey
        self.domain = domain
        self.hasGraphQL = hasGraphQL
    }
}
