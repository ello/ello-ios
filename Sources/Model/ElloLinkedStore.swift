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
        database = YapDatabase(path: ElloLinkedStore.databasePath())
        writeConnection = database.newConnection()
    }

    func parseLinked(_ linked: [String: [[String: Any]]], completion: @escaping Block) {
        if AppSetup.shared.isTesting {
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
    func setObject(_ jsonable: JSONAble, forKey key: String, type: MappingType) {
        let collection = type.rawValue
        writeConnection.readWrite { transaction in
            transaction.setObject(jsonable, forKey: key, inCollection: collection)
        }
    }

    func getObject(_ key: String, type: MappingType) -> JSONAble? {
        let collection = type.rawValue
        var object: JSONAble?
        readConnection.read { transaction in
            if transaction.hasObject(forKey: key, inCollection: collection) {
                object = transaction.object(forKey: key, inCollection: collection) as? JSONAble
            }
        }
        return object
    }

    func saveObject(_ jsonable: JSONAble, id: String, type: MappingType) {
        let collection = type.rawValue
        self.writeConnection.readWrite { transaction in
            if let existing = transaction.object(forKey: id, inCollection: collection) as? JSONAble {
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

    static func databasePath(name: String? = nil) -> String {
        var path = ""
        if let baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ElloGroupName) {
            path = baseURL.appendingPathComponent(name ?? ElloLinkedStore.databaseName).path
        }
        return path
    }

    func parseLinkedSync(_ linked: [String: [[String: Any]]]) {
        for (type, typeObjects): (String, [[String: Any]]) in linked {
            guard let mappingType = MappingType(rawValue: type) else { continue }

            for object: [String: Any] in typeObjects {
                guard let id = object["id"] as? String else { continue }

                let jsonable = mappingType.fromJSON(object)
                self.saveObject(jsonable, id: id, type: mappingType)
            }
        }
    }
}
