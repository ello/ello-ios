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
    var links: [String: Any] = [:]
    let version: Int

    init(version: Int) {
        self.version = version
        super.init()
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.links = decoder.decodeOptionalKey("links") ?? [:]
        self.version = decoder.decodeKey("version")
    }

    func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(links, forKey: "links")
        coder.encodeObject(version, forKey: "version")
    }

    func merge(_ other: Model) -> Model {
        return other
    }
}

// MARK: get associated Models via ids in `links`

extension Model {
    func getLinkObject<T: Model>(_ identifier: String) -> T? {
        var obj: T?
        if let linksMap = links[identifier] as? [String: Any],
            let id = linksMap["id"] as? String,
            let collection = linksMap["type"] as? String
        {
            ElloLinkedStore.shared.readConnection.read { transaction in
                obj = transaction.object(forKey: id, inCollection: collection) as? T
            }
        }
        else if let id = links[identifier] as? String {
            ElloLinkedStore.shared.readConnection.read { transaction in
                obj = transaction.object(forKey: id, inCollection: identifier) as? T
            }
        }

        return obj
    }

    func getLinkArray<T: Model>(_ identifier: String) -> [T] {
        let linksList = links[identifier] as? [String]
        let linksMap = links[identifier] as? [String: Any]
        guard
            let ids =
                linksList ??
                linksMap?["ids"] as? [String]
        else { return [] }

        let collection = (linksMap?["type"] as? String) ?? identifier

        var arr = [T]()
        ElloLinkedStore.shared.readConnection.read { transaction in
            for key in ids {
                if let jsonable = transaction.object(forKey: key, inCollection: collection) as? T {
                    arr.append(jsonable)
                }
            }
        }
        return arr
    }

    func mergeLinks(_ links: [String: Any]?) {
        guard let links = links else { return }
        for (key, value) in links {
            self.links[key] = value
        }
    }

    func addLinkObject(_ identifier: String, key: String, type: MappingType) {
        links[identifier] = ["id": key, "type": type.rawValue]
    }

    func removeLink(_ identifier: String) {
        links[identifier] = nil
    }

    func addLinkObject(_ model: Model, identifier: String, key: String, type: MappingType) {
        addLinkObject(identifier, key: key, type: type)
        ElloLinkedStore.shared.setObject(model, forKey: key, type: type)
    }

    func clearLinkObject(_ identifier: String) {
        links[identifier] = nil
    }

    func addLinkArray(_ identifier: String, array: [String], type: MappingType) {
        links[identifier] = ["ids": array, "type": type.rawValue]
    }
}
