////
///  JSONAble.swift
//


protocol JSONSaveable {
    var uniqueId: String? { get }
    var tableId: String? { get }
}


enum JSONAbleResult {
    case one(JSONAble)
    case many([JSONAble])
    case none
}


@objc(JSONAble)
class JSONAble: NSObject, NSCoding {
    var links: [String: Any]?
    let version: Int

    init(version: Int) {
        self.version = version
        super.init()
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.links = decoder.decodeOptionalKey("links")
        self.version = decoder.decodeKey("version")
    }

    func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(links, forKey: "links")
        coder.encodeObject(version, forKey: "version")
    }

    func merge(_ other: JSONAble) -> JSONAble {
        return other
    }
}

// MARK: Links methods to get JSONAbles

extension JSONAble {
    func getLinkObject(_ identifier: String) -> JSONAble? {
        guard let links = links else { return nil }

        var obj: JSONAble?
        if let linksMap = links[identifier] as? [String: Any],
            let id = linksMap["id"] as? String,
            let collection = linksMap["type"] as? String
        {
            ElloLinkedStore.shared.readConnection.read { transaction in
                obj = transaction.object(forKey: id, inCollection: collection) as? JSONAble
            }
        }
        else if let id = links[identifier] as? String {
            ElloLinkedStore.shared.readConnection.read { transaction in
                obj = transaction.object(forKey: id, inCollection: identifier) as? JSONAble
            }
        }

        return obj
    }

    func getLinkArray(_ identifier: String) -> [JSONAble] {
        guard let links = links else { return [] }

        let linksList = links[identifier] as? [String]
        let linksMap = links[identifier] as? [String: Any]
        guard
            let ids =
                linksList ??
                linksMap?["ids"] as? [String]
        else { return [] }

        let collection = (linksMap?["type"] as? String) ?? identifier

        var arr = [JSONAble]()
        ElloLinkedStore.shared.readConnection.read { transaction in
            for key in ids {
                if let jsonable = transaction.object(forKey: key, inCollection: collection) as? JSONAble {
                    arr.append(jsonable)
                }
            }
        }
        return arr
    }

    func addLinkObject(_ identifier: String, key: String, type: MappingType) {
        if links == nil { links = [String: Any]() }
        links![identifier] = ["id": key, "type": type.rawValue]

    }

    func addLinkObject(_ model: JSONAble, identifier: String, key: String, type: MappingType) {
        addLinkObject(identifier, key: key, type: type)
        ElloLinkedStore.shared.setObject(model, forKey: key, type: type)
    }

    func clearLinkObject(_ identifier: String) {
        if links == nil { links = [String: Any]() }
        links![identifier] = nil
    }

    func addLinkArray(_ identifier: String, array: [String], type: MappingType) {
        if links == nil { links = [String: Any]() }
        links![identifier] = ["ids": array, "type": type.rawValue]
    }
}
