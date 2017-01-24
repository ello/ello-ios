////
///  ElloLinkedStore.swift
//

import Foundation
import YapDatabase

private let _ElloLinkedStore = ElloLinkedStore()


struct ElloLinkedStore {

    static var sharedInstance: ElloLinkedStore { return _ElloLinkedStore }
    static var databaseName = "ello.sqlite"

    var readConnection: YapDatabaseConnection {
        let connection = database.newConnection()
        connection.objectCacheLimit = 500
        return connection
    }
    var writeConnection: YapDatabaseConnection
    fileprivate var database: YapDatabase

    init() {
        ElloLinkedStore.deleteNonSharedDB()
        database = YapDatabase(path: ElloLinkedStore.databasePath())
        writeConnection = database.newConnection()
    }

    func parseLinked(_ linked: [String:[[String: AnyObject]]], completion: @escaping ElloEmptyCompletion) {
        if AppSetup.sharedState.isTesting {
            parseLinkedSync(linked)
            completion()
        }
        else {
            inBackground {
                self.parseLinkedSync(linked)
                inForeground(completion)
            }
        }
    }

    // primarialy used for testing for now.. could be used for setting a model after it's fromJSON
    func setObject(_ object: JSONAble, forKey key: String, type: MappingType) {
        writeConnection.readWrite { transaction in
            transaction.setObject(object, forKey: key, inCollection: type.rawValue)
        }
    }

    func getObject(_ key: String, type: MappingType) -> JSONAble? {
        var object: JSONAble?
        readConnection.read { transaction in
            if transaction.hasObject(forKey: key, inCollection: type.rawValue) {
                object = transaction.object(forKey: key, inCollection: type.rawValue) as? JSONAble
            }
        }
        return object
    }

    func saveObject(_ jsonable: JSONAble, id: String, type: MappingType) {
        self.writeConnection.readWrite { transaction in
            if let existing = transaction.object(forKey: id, inCollection: type.rawValue) as? JSONAble {
                let merged = existing.merge(jsonable)
                transaction.replace(merged, forKey: id, inCollection: type.rawValue)
            }
            else {
                transaction.setObject(jsonable, forKey: id, inCollection: type.rawValue)
            }
        }
    }

}

// MARK: Private
private extension ElloLinkedStore {

    static func deleteNonSharedDB(_ overrideDefaults: UserDefaults? = nil) {
        let defaults: UserDefaults
        if let overrideDefaults = overrideDefaults {
            defaults = overrideDefaults
        }
        else {
            defaults = GroupDefaults
        }

        let didDeleteNonSharedDB = defaults["DidDeleteNonSharedDB"].bool ?? false
        if !didDeleteNonSharedDB {
            defaults["DidDeleteNonSharedDB"] = true
            ElloLinkedStore.removeNonSharedDB()
        }
    }

    static func removeNonSharedDB() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let baseDir: String
        if let firstPath = paths.first {
            baseDir = firstPath
        }
        else {
            baseDir = NSTemporaryDirectory()
        }

        let path: String
        if let baseURL = URL(string: baseDir) {
            path = baseURL.appendingPathComponent(ElloLinkedStore.databaseName).path
        }
        else {
            path = ""
        }
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }
            catch _ {}
        }
    }

    static func databasePath() -> String {
        var path = ""
        if let baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ElloGroupName) {
            path = baseURL.appendingPathComponent(ElloLinkedStore.databaseName).path
        }
        return path
    }

    func parseLinkedSync(_ linked: [String: [[String: AnyObject]]]) {
        for (type, typeObjects): (String, [[String: AnyObject]]) in linked {
            guard let mappingType = MappingType(rawValue: type) else { continue }

            for object: [String: AnyObject] in typeObjects {
                guard let id = object["id"] as? String else { continue }

                let jsonable = mappingType.fromJSON(object)
                self.saveObject(jsonable, id: id, type: mappingType)
            }
        }
    }
}
