////
///  MentionablesSpec.swift
//

@testable import Ello
import Quick
import Nimble


class MentionablesSpec: QuickSpec {
    override func spec() {
        describe("Mentionables") {
            context("findAll(String) -> [String]") {
                let expectations = [
                    "@abc @def @ghi": ["@abc", "@def", "@ghi"],
                    "@abc-123 .@def. !aa@ghi": ["@abc-123", "@def"],
                ]
                for (test, expected) in expectations {
                    it("should find usernames in \(test)") {
                        let regions: [Regionable] = [TextRegion(content: test)]
                        expect(Mentionables.findAll(regions)) == expected
                    }
                }
            }
        }
    }
}
