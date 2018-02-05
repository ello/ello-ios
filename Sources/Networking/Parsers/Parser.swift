////
///  Parser.swift
//

import SwiftyJSON


class Parser {
    typealias Id = String
    struct Identifier {
        let id: Id
        let table: MappingType
    }
    typealias Database = [MappingType: [Id: JSON]]

    private var linkedArrays: [(type: MappingType, jsonKey: String, linkKey: String)] = []
    private var linkedObjects: [(type: MappingType, jsonKey: String, linkKey: String)] = []

    @discardableResult
    static func saveToDB(parser: Parser, identifier: Parser.Identifier, db: inout Parser.Database) -> JSONAble? {
        guard
            var table = db[identifier.table],
            let json = table[identifier.id]
        else { return nil }

        table[identifier.id] = nil
        db[identifier.table] = table
        guard let jsonable = parser.parse(json: json) else { return nil }

        ElloLinkedStore.shared.setObject(jsonable, forKey: identifier.id, type: identifier.table)
        return jsonable
    }

    func linkArray(_ table: MappingType, _ _jsonKey: String? = nil, _ _linkKey: String? = nil) {
        let jsonKey = _jsonKey ?? table.pluralKey
        let linkKey = _linkKey ?? jsonKey.snakeCase
        linkedArrays.append((type: table, jsonKey: jsonKey, linkKey: linkKey))
    }

    func linkObject(_ table: MappingType, _ _jsonKey: String? = nil, _ _linkKey: String? = nil) {
        let jsonKey = _jsonKey ?? table.singularKey
        let linkKey = _linkKey ?? jsonKey.snakeCase
        linkedObjects.append((type: table, jsonKey: jsonKey, linkKey:linkKey))
    }

    func identifier(json: JSON) -> Identifier? {
        return nil
    }

    func flatten(json: JSON, identifier: Identifier, db: inout Database) {
        var newJSON: JSON
        if var existing = db[identifier.table]?[identifier.id] {
            for (key, value) in json.dictionaryValue {
                existing[key] = value
            }
            newJSON = existing
        }
        else {
            newJSON = json
        }

        var links: [String: Any] = json["links"].dictionaryObject ?? [:]
        for (linkTable, jsonKey, linkKey) in linkedArrays {
            guard
                let linkedObjects = json[jsonKey].array,
                let parser = linkTable.parser()
                else { continue }

            var ids: [String] = []
            for linkedJSON in linkedObjects {
                guard let identifier = parser.identifier(json: linkedJSON) else { continue }
                parser.flatten(json: linkedJSON, identifier: identifier, db: &db)
                ids.append(identifier.id)
            }
            links[linkKey] = ["ids": ids, "type": linkTable.rawValue]
        }

        for (linkTable, jsonKey, linkKey) in linkedObjects {
            let linkedJSON = json[jsonKey]
            guard
                let parser = linkTable.parser(),
                let identifier = parser.identifier(json: linkedJSON)
            else { continue }

            parser.flatten(json: linkedJSON, identifier: identifier, db: &db)
            links[linkKey] = ["id": identifier.id, "type": linkTable.rawValue]
        }

        newJSON["links"] = JSON(links)

        var table = db[identifier.table] ?? [:]
        table[identifier.id] = newJSON
        db[identifier.table] = table
    }

    func parse(json: JSON) -> JSONAble? {
        return nil
    }
}

class IdParser: Parser {
    var table: MappingType
    init(table: MappingType) {
        self.table = table
    }

    override func identifier(json: JSON) -> Identifier? {
        guard let id = json["id"].string else { return nil }
        return Identifier(id: id, table: table)
    }
}
