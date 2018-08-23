////
///  OneParser.swift
//

import SwiftyJSON


class OneParser<T> {
    enum Error: Swift.Error {
        case notIdentifiable
        case wrongType
    }

    let parser: Parser

    init(_ parser: Parser) {
        self.parser = parser
    }

    func parse(json: JSON) throws -> T {
        guard let identifier = parser.identifier(json: json) else {
            throw Error.notIdentifiable
        }

        var db: Parser.Database = [:]
        parser.flatten(json: json, identifier: identifier, db: &db)
        let one = Parser.saveToDB(parser: parser, identifier: identifier, db: db)

        for (table, objects) in db {
            guard let tableParser = table.parser else { continue }

            for (_, json) in objects {
                guard let identifier = tableParser.identifier(json: json) else { continue }
                Parser.saveToDB(parser: tableParser, identifier: identifier, db: db)
            }
        }

        if let one = one as? T {
            return one
        }
        throw Error.wrongType
    }
}
