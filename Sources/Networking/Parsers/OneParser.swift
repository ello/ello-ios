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
    let resultsKey: String

    init(_ resultsKey: String, _ parser: Parser) {
        self.parser = parser
        self.resultsKey = resultsKey
    }

    func parse(json: JSON) throws -> (PageConfig, T) {
        let results = json[resultsKey]
        guard let identifier = parser.identifier(json: results) else {
            throw Error.notIdentifiable
        }

        var db: Parser.Database = [:]
        parser.flatten(json: results, identifier: identifier, db: &db)
        let one = Parser.saveToDB(parser: parser, identifier: identifier, db: &db)

        for (table, objects) in db {
            guard let tableParser = table.parser() else { continue }

            for (_, json) in objects {
                guard let identifier = tableParser.identifier(json: json) else { continue }
                Parser.saveToDB(parser: tableParser, identifier: identifier, db: &db)
            }
        }

        if let one = one as? T {
            let next = json["next"].string
            let isLastPage = json["isLastPage"].bool
            let config = PageConfig(next: next, isLastPage: isLastPage)
            return (config, one)
        }
        throw Error.wrongType
    }
}
