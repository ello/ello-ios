////
///  UserParserSpec.swift
//

@testable import Ello
import Quick
import Nimble
import SwiftyJSON


class UserParserSpec: QuickSpec {
    override func spec() {
        describe("UserParser") {
            it("merges json") {
                let json1: JSON = [
                    "id": "123",
                    "username": "colinta",
                    "name": "",
                ]
                let json2: JSON = [
                    "id": "123",
                    "name": "Colin Gray",
                    "identifiable_by": "colintagray"
                ]
                var db: Parser.Database = [:]
                let parser = UserParser()
                parser.flatten(json: json1, identifier: Parser.Identifier(id: "123", table: .usersType), db: &db)
                parser.flatten(json: json2, identifier: Parser.Identifier(id: "123", table: .usersType), db: &db)
                if let userJSON = db[.usersType]?["123"] {
                    expect(userJSON["id"].string) == "123"
                    expect(userJSON["username"].string) == "colinta"
                    expect(userJSON["name"].string) == "Colin Gray"
                    expect(userJSON["identifiable_by"].string) == "colintagray"
                }
                else {
                    fail("did not save user JSON")
                }
            }
            it("can parse sparse JSON") {
                let json: JSON = [
                    "id": "123",
                    "username": "colinta",
                    "name": "Colin Gray",
                ]
                let parser = UserParser()
                let user = parser.parse(json: json)
                expect(user.id) == "123"
                expect(user.username) == "colinta"
                expect(user.name) == "Colin Gray"
            }
        }
    }
}
