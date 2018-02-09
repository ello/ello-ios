////
///  TemporaryCache.swift
//

typealias TemporaryCacheEntry = (image: UIImage, expiration: Date)

struct TemporaryCache {
    enum Key {
        case coverImage
        case avatar
    }
    private static var coverImage: TemporaryCacheEntry?
    private static var avatar: TemporaryCacheEntry?

    static func clear() {
        TemporaryCache.coverImage = nil
        TemporaryCache.avatar = nil
    }

    static func save(_ key: Key, image: UIImage) {
        let fiveMinutes: TimeInterval = 5 * 60
        let date = Date(timeIntervalSinceNow: fiveMinutes)
        switch key {
        case .coverImage:
            TemporaryCache.coverImage = (image: image, expiration: date)
        case .avatar:
            TemporaryCache.avatar = (image: image, expiration: date)
        }
    }

    static func load(_ key: Key) -> UIImage? {
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
