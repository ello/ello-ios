////
///  ElloLinkedStore.swift
//

import Foundation
import YapDatabase

private let _ElloLinkedStore = ElloLinkedStore()


public struct ElloLinkedStore {

    public static var sharedInstance: ElloLinkedStore { return _ElloLinkedStore }
    public static var databaseName = "ello.sqlite"

    public var readConnection: YapDatabaseConnection {
        let connection = database.newConnection()
        connection.objectCacheLimit = 500
        return connection
    }
    public var writeConnection: YapDatabaseConnection
    private var database: YapDatabase

    public init() {
        ElloLinkedStore.deleteNonSharedDB()
        database = YapDatabase(path: ElloLinkedStore.databasePath())
        writeConnection = database.newConnection()
    }

    public func parseLinked(linked: [String:[[String: AnyObject]]], completion: ElloEmptyCompletion) {
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
    public func setObject(object: JSONAble, forKey key: String, inCollection collection: String ) {
        writeConnection.readWriteWithBlock { transaction in
            transaction.setObject(object, forKey: key, inCollection: collection)
        }
    }

    public func getObject(key: String, inCollection collection: String) -> JSONAble? {
        var object: JSONAble?
        readConnection.readWithBlock { transaction in
            if transaction.hasObjectForKey(key, inCollection: collection) {
                object = transaction.objectForKey(key, inCollection: collection) as? JSONAble
            }
        }
        return object
    }
}

// MARK: Private
private extension ElloLinkedStore {

    static func deleteNonSharedDB(overrideDefaults overrideDefaults: NSUserDefaults? = nil) {
        let defaults: NSUserDefaults
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
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let baseDir: String
        if let firstPath = paths.first {
            baseDir = firstPath
        }
        else {
            baseDir = NSTemporaryDirectory()
        }

        let path: String
        if let baseURL = NSURL(string: baseDir) {
            path = baseURL.URLByAppendingPathComponent(ElloLinkedStore.databaseName)?.path ?? ""
        }
        else {
            path = ""
        }
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
            catch _ {}
        }
    }

    static func databasePath() -> String {
        var path = ""
        if let baseURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(ElloGroupName) {
            path = baseURL.URLByAppendingPathComponent(ElloLinkedStore.databaseName)?.path ?? ""
        }
        return path
    }

    func parseLinkedSync(linked: [String: [[String: AnyObject]]]) {
        for (type, typeObjects): (String, [[String: AnyObject]]) in linked {
            if let mappingType = MappingType(rawValue: type) {
                for object: [String: AnyObject] in typeObjects {
                    if let id = object["id"] as? String {
                        let jsonable = mappingType.fromJSON(data: object, fromLinked: true)

                        self.writeConnection.readWriteWithBlock { transaction in
                            transaction.setObject(jsonable, forKey: id, inCollection: type)
                        }
                    }
                }
            }
        }
    }
}
