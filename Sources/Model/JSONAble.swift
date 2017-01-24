////
///  JSONAble.swift
//

import YapDatabase
import Foundation

typealias FromJSONClosure = ([String: AnyObject]) -> JSONAble

let JSONAbleVersion = 1

protocol JSONSaveable {
    var uniqueId: String? { get }
    var tableId: String? { get }
}

@objc(JSONAble)
class JSONAble: NSObject, NSCoding {
    // links
    var links: [String: AnyObject]?
    let version: Int

    init(version: Int) {
        self.version = version
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.links = decoder.decodeOptionalKey("links")
        self.version = decoder.decodeKey("version")
    }

    func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(links, forKey: "links")
        coder.encodeObject(version, forKey: "version")
    }

    class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        return JSONAble(version: JSONAbleVersion)
    }

    func merge(_ other: JSONAble) -> JSONAble {
        return other
    }
}

// MARK: Links methods to get JSONAbles

extension JSONAble {
    func getLinkObject(_ identifier: String) -> JSONAble? {
        var obj: JSONAble?
        if let id = links?[identifier]?["id"] as? String,
            let collection = links?[identifier]?["type"] as? String
        {
            ElloLinkedStore.sharedInstance.readConnection.read { transaction in
                obj = transaction.object(forKey: id, inCollection: collection) as? JSONAble
            }
        }
        else if let id = links?[identifier] as? String {
            ElloLinkedStore.sharedInstance.readConnection.read { transaction in
                obj = transaction.object(forKey: id, inCollection: identifier) as? JSONAble
            }
        }
        return obj
    }

    func getLinkArray(_ identifier: String) -> [JSONAble] {

        guard let ids =
            self.links?[identifier] as? [String] ??
            self.links?[identifier]?["ids"] as? [String]
        else { return [] }

        var arr = [JSONAble]()
        ElloLinkedStore.sharedInstance.readConnection.read { transaction in
            for key in ids {
                if let jsonable = transaction.object(forKey: key, inCollection: identifier) as? JSONAble {
                    arr.append(jsonable)
                }
            }
        }
        return arr
    }

    func addLinkObject(_ identifier: String, key: String, type: MappingType) {
        if links == nil { links = [String: AnyObject]() }
        links![identifier] = ["id": key, "type": type.rawValue] as AnyObject

    }

    func addLinkObject(_ model: JSONAble, identifier: String, key: String, type: MappingType) {
        addLinkObject(identifier, key: key, type: type)
        ElloLinkedStore.sharedInstance.setObject(model, forKey: key, type: type)
    }

    func clearLinkObject(_ identifier: String) {
        if links == nil { links = [String: AnyObject]() }
        links![identifier] = nil
    }

    func addLinkArray(_ identifier: String, array: [String], type: MappingType) {
        if links == nil { links = [String: AnyObject]() }
        links![identifier] = ["ids": array, "type": type.rawValue] as AnyObject
    }
}
