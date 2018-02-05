////
///  ManyParser.swift
//

import SwiftyJSON


class ManyParser<T> {
    enum Error: Swift.Error {
        case notAnArray
    }

    let parser: Parser
    let resultsKey: String

    init(_ resultsKey: String, _ parser: Parser) {
        self.parser = parser
        self.resultsKey = resultsKey
    }

    func parse(json: JSON) throws -> (PageConfig, [T]) {
        let results = json[resultsKey]
        guard let objects = results.array else {
            throw Error.notAnArray
        }

        let next = json["next"].string
        let isLastPage = json["isLastPage"].bool
        let config = PageConfig(next: next, isLastPage: isLastPage)

        var db: Parser.Database = [:]
        var ids: [Parser.Identifier] = []
        for object in objects {
            guard let identifier = parser.identifier(json: object) else { continue }
            ids.append(identifier)
            parser.flatten(json: object, identifier: identifier, db: &db)
        }

        let many: [JSONAble]? = (ids.count > 0 ? ids.flatMap { identifier in
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
            return (config, many)
        }
        else {
            return (config, [T]())
        }
    }
}
