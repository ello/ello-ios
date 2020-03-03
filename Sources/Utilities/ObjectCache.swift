////
///  ObjectCache.swift
//

protocol PersistentLayer {
    func set(_ value: Any?, forKey: String)
    func object(forKey defaultName: String) -> Any?
    func removeObject(forKey defaultName: String)
}

extension UserDefaults: PersistentLayer {}

class ObjectCache<T: Any> {
    private let persistentLayer: PersistentLayer
    var cache: [T] = []
    let name: String

    init(name: String) {
        self.name = name
        persistentLayer = GroupDefaults
    }

    init(name: String, persistentLayer: PersistentLayer) {
        self.name = name
        self.persistentLayer = persistentLayer
    }

    func append(_ item: T) {
        cache.append(item)
        persist()
    }

    func getAll() -> [T] {
        return cache
    }

    func persist() {
        persistentLayer.set(cache, forKey: name)
    }

    func load() {
        cache = persistentLayer.object(forKey: name) as? [T] ?? []
    }

    func clear() {
        persistentLayer.removeObject(forKey: name)
    }
}
