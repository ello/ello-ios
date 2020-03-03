////
///  ElloLinkedStore.swift
//

import YapDatabase


struct ElloLinkedStore {

    static var shared = ElloLinkedStore()
    static var databaseName = "ello-v2.sqlite" {
        didSet {
            shared = ElloLinkedStore()
        }
    }

    var readConnection: YapDatabaseConnection {
        let connection = database.newConnection()
        connection.objectCacheLimit = 500
        return connection
    }
    var writeConnection: YapDatabaseConnection
    private var database: YapDatabase

    init() {
        database = YapDatabase(path: ElloLinkedStore.databasePath())!
        writeConnection = database.newConnection()
    }

    func parseLinked(_ linked: [String: [[String: Any]]], completion: @escaping Block) {
        if Globals.isTesting {
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
    func setObject(_ jsonable: Model, forKey key: String, type: MappingType) {
        let collection = type.rawValue
        writeConnection.readWrite { transaction in
            transaction.setObject(jsonable, forKey: key, inCollection: collection)
        }
    }

    func getObject(_ key: String, type: MappingType) -> Model? {
        let collection = type.rawValue
        var object: Model?
        readConnection.read { transaction in
            if transaction.hasObject(forKey: key, inCollection: collection) {
                object = transaction.object(forKey: key, inCollection: collection) as? Model
            }
        }
        return object
    }

    func saveObject(_ jsonable: Model, id: String, type: MappingType) {
        let collection = type.rawValue
        self.writeConnection.readWrite { transaction in
            if let existing = transaction.object(forKey: id, inCollection: collection) as? Model {
                let merged = existing.merge(jsonable)
                transaction.replace(merged, forKey: id, inCollection: collection)
            }
            else {
                transaction.setObject(jsonable, forKey: id, inCollection: collection)
            }
        }
    }

}

extension ElloLinkedStore {

    static func clearDB(name: String? = nil) {
        ElloLinkedStore.shared.writeConnection.readWrite { transaction in
            transaction.removeAllObjectsInAllCollections()
        }
    }

    static func removeDB(name: String? = nil) {
        let path = ElloLinkedStore.databasePath(name: name)

        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    static func databaseFolder(appending appendURL: String? = nil) -> String? {
        guard
            var baseURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: ElloGroupName
            )
        else { return nil }

        if let appendURL = appendURL {
            baseURL = baseURL.appendingPathComponent(appendURL)
        }
        return baseURL.path
    }

    static func databasePath(name: String? = nil) -> String {
        let databaseName = name ?? ElloLinkedStore.databaseName
        return databaseFolder(appending: databaseName) ?? databaseName
    }

    func parseLinkedSync(_ linked: [String: [[String: Any]]]) {
        for (type, typeObjects):(String, [[String: Any]]) in linked {
            guard let mappingType = MappingType(rawValue: type) else { continue }

            for object:[String: Any] in typeObjects {
                guard
                    let id = object["id"] as? String,
                    let jsonable = mappingType.fromJSON?(object)
                else { continue }

                self.saveObject(jsonable, id: id, type: mappingType)
            }
        }
    }
}
