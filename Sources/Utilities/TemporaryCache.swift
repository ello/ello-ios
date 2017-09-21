////
///  TemporaryCache.swift
//

typealias TemporaryCacheEntry = (image: UIImage, expiration: Date)
enum CacheKey {
    case coverImage
    case avatar
}
struct TemporaryCache {
    static var coverImage: TemporaryCacheEntry?
    static var avatar: TemporaryCacheEntry?

    static func clear() {
        TemporaryCache.coverImage = nil
        TemporaryCache.avatar = nil
    }

    static func save(_ key: CacheKey, image: UIImage) {
        let fiveMinutes: TimeInterval = 5 * 60
        let date = Date(timeIntervalSinceNow: fiveMinutes)
        switch key {
        case .coverImage:
            TemporaryCache.coverImage = (image: image, expiration: date)
        case .avatar:
            TemporaryCache.avatar = (image: image, expiration: date)
        }
    }

    static func load(_ key: CacheKey) -> UIImage? {
        let date = Globals.now
        let entry: TemporaryCacheEntry?

        switch key {
        case .coverImage:
            entry = TemporaryCache.coverImage
        case .avatar:
            entry = TemporaryCache.avatar
        }

        if let entry = entry, entry.expiration > date {
            return entry.image
        }
        return nil
    }
}
