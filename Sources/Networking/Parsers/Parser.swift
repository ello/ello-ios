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

    private var linkedArrays: [(MappingType, String)] = []
    private var linkedObjects: [(MappingType, String)] = []

    @discardableResult
    static func saveToDB(parser: Parser, identifier: Parser.Identifier, db: inout Parser.Database) -> JSONAble? {
        guard
            var table = db[identifier.table],
            let json = table[identifier.id]
        else { return nil }
        table[identifier.id] = nil
        db[identifier.table] = table
        return parser.parse(json: json)
    }

    func linkArray(_ table: MappingType, _ key: String? = nil) {
        linkedArrays.append((table, key ?? table.pluralKey))
    }

    func linkObject(_ table: MappingType, _ key: String? = nil) {
        linkedObjects.append((table, key ?? table.singularKey))
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

        var links: [String: Any] = [:]
        for (linkTable, linkName) in linkedArrays {
            guard
                let linkedObjects = json[linkName].array,
                let parser = linkTable.parser()
                else { continue }

            var ids: [String] = []
            for linkedJSON in linkedObjects {
                guard let identifier = parser.identifier(json: linkedJSON) else { continue }
                parser.flatten(json: linkedJSON, identifier: identifier, db: &db)
                ids.append(identifier.id)
            }
            links[linkName] = ["ids": ids, "type": linkTable.rawValue]
        }

        for (linkTable, linkName) in linkedObjects {
            let linkedJSON = json[linkName]
            guard
                let parser = linkTable.parser(),
                let identifier = parser.identifier(json: linkedJSON)
            else { continue }

            parser.flatten(json: linkedJSON, identifier: identifier, db: &db)
            links[linkName] = ["id": identifier.id, "type": linkTable.rawValue]
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
