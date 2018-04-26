////
///  ManyParser.swift
//

import SwiftyJSON


class ManyParser<T> {
    enum Error: Swift.Error {
        case notAnArray
    }

    let parser: Parser

    init(_ parser: Parser) {
        self.parser = parser
    }

    func parse(json: JSON) throws -> [T] {
        guard let objects = json.array else {
            throw Error.notAnArray
        }

        var db: Parser.Database = [:]
        var ids: [Parser.Identifier] = []
        for object in objects {
            guard let identifier = parser.identifier(json: object) else { continue }
            ids.append(identifier)
            parser.flatten(json: object, identifier: identifier, db: &db)
        }

        let many: [Model]? = (ids.count > 0 ? ids.compactMap { identifier in
            return Parser.saveToDB(parser: parser, identifier: identifier, db: &db)
            } : nil)

        for (table, objects) in db {
            guard let tableParser = table.parser() else { continue }

            for (_, json) in objects {
                guard let identifier = tableParser.identifier(json: json) else { continue }
                Parser.saveToDB(parser: tableParser, identifier: identifier, db: &db)
            }
        }

        if let many = many as? [T] {
            return many
        }
        else {
            return [T]()
        }
    }
}
