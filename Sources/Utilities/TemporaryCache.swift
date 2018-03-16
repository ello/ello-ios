////
///  TemporaryCache.swift
//


struct TemporaryCache {
    typealias Entry = (data: Any, expiration: Date)
    enum Key {
        case avatar
        case coverImage
        case categories
    }

    private static var cache: [Key: Entry] = [:]

    static func clear() {
        TemporaryCache.cache = [:]
    }

    static func save(_ prop: Profile.ImageProperty, image: UIImage) {
        let key: Key
        switch prop {
        case .avatar: key = .avatar
        case .coverImage: key = .coverImage
        }
        save(key, image)
    }

    static func save(_ key: Key, _ data: Any, expires: TimeInterval = 5) {
        let fiveMinutes: TimeInterval = expires * 60
        let date = Date(timeIntervalSinceNow: fiveMinutes)
        cache[key] = (data: data, expiration: date)
    }

    static func load(_ prop: Profile.ImageProperty) -> UIImage? {
        let key: Key
        switch prop {
        case .avatar: key = .avatar
        case .coverImage: key = .coverImage
        }
        return load(key)
    }

    static func load<T>(_ key: Key) -> T? {
        guard
            let entry = cache[key],
            entry.expiration > Globals.now
        else { return nil }

        return entry.data as? T
    }
}
