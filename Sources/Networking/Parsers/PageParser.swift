////
///  PageParser.swift
//

import SwiftyJSON


class PageParser<T> {
    let parser: ManyParser<T>
    let resultsKey: String

    init(_ resultsKey: String, _ parser: Parser) {
        self.parser = ManyParser(parser)
        self.resultsKey = resultsKey
    }

    func parse(json: JSON) throws -> (PageConfig, [T]) {
        let objects = try parser.parse(json: json[resultsKey])
        let next = json["next"].string
        let isLastPage = json["isLastPage"].bool
        let config = PageConfig(next: next, isLastPage: isLastPage)
        return (config, objects)
    }
}
