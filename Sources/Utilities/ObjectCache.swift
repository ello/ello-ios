////
///  ObjectCache.swift
//

import Foundation

protocol PersistentLayer {
    func setObject(_ value: Any?, forKey: String)
    func objectForKey(_ defaultName: String) -> Any?
    func removeObjectForKey(_ defaultName: String)
}

extension UserDefaults: PersistentLayer { }

class ObjectCache<T: Any> {
    fileprivate let persistentLayer: PersistentLayer
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
        persistentLayer.setObject(cache as AnyObject?, forKey: name)
    }

    func load() {
        cache = persistentLayer.objectForKey(name) as? [T] ?? []
    }

    func clear() {
        persistentLayer.removeObjectForKey(name)
    }
}
