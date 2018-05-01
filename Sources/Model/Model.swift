////
///  Model.swift
//


protocol JSONSaveable {
    var uniqueId: String? { get }
    var tableId: String? { get }
}


enum ModelResult {
    case one(Model)
    case many([Model])
    case none
}


@objc(Model)
class Model: NSObject, NSCoding {
    enum Link {
        case one(id: String, type: MappingType)
        case many(ids: [String], type: MappingType)
    }

    var links: [String: Link] = [:]
    let version: Int

    init(version: Int) {
        self.version = version
        super.init()
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.links = [:]
        if let decoderData: [String: Any] = decoder.decodeOptionalKey("links") {
            for (key, data) in decoderData {
                guard let decoded = Link.decode(key, data) else { continue }
                links[key] = decoded
            }
        }
        self.version = decoder.decodeKey("version")
    }

    func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(links.mapValues { $0.encode() }, forKey: "links")
        coder.encodeObject(version, forKey: "version")
    }

    func merge(_ other: Model) -> Model {
        return other
    }
}

// MARK: get associated Models via ids in `links`

extension Model {

    func getLinkObject<T: Model>(_ key: String) -> T? {
        guard
            let link = links[key],
            case let .one(id, mappingType) = link
        else { return nil }

        var obj: T?
        ElloLinkedStore.shared.readConnection.read { transaction in
            obj = transaction.object(forKey: id, inCollection: mappingType.rawValue) as? T
        }
        return obj
    }

    func getLinkArray<T: Model>(_ key: String) -> [T] {
        guard
            let link = links[key],
            case let .many(ids, mappingType) = link
        else { return [] }

        var arr = [T]()
        ElloLinkedStore.shared.readConnection.read { transaction in
            arr = ids.compactMap { transaction.object(forKey: $0, inCollection: mappingType.rawValue) as? T }
        }
        return arr
    }

    func mergeLinks(_ links: [String: Any]?) {
        guard let links = links else { return }

        for (key, data) in links {
            guard let link = Link.decode(key, data) else { continue }
            self.links[key] = link
        }
    }

    func addLinkObject(_ key: String, id: String, type: MappingType) {
        links[key] = .one(id: id, type: type)
    }

    func storeLinkObject(_ model: Model, key: String, id: String, type: MappingType) {
        addLinkObject(key, id: id, type: type)
        ElloLinkedStore.shared.setObject(model, forKey: key, type: type)
    }

    func addLinkArray(_ key: String, array: [String], type: MappingType) {
        links[key] = .many(ids: array, type: type)
    }
}

extension Model.Link {

    func encode() -> [String: Any] {
        switch self {
        case let .one(id, type): return ["id": id, "type": type.rawValue]
        case let .many(ids, type): return ["ids": ids, "type": type.rawValue]
        }
    }

    static func decode(_ key: String, _ rawData: Any) -> Model.Link? {
        if let id = rawData as? String {
            return decode(key, ["id": id, "type": key])
        }
        else if let ids = rawData as? [String] {
            return decode(key, ["ids": ids, "type": key])
        }

        guard
            let data = rawData as? [String: Any],
            let type: MappingType = (data["type"] as? String).flatMap({ MappingType(rawValue: $0) })
        else { return nil }

        if let id = data["id"] as? String {
            return .one(id: id, type: type)
        }
        else if let ids = data["ids"] as? [String] {
            return .many(ids: ids, type: type)
        }
        else {
            return nil
        }
    }

}
