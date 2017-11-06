////
///  ElloAttributedStringSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ElloAttributedStringSpec: QuickSpec {
    override func spec() {
        describe("parsing Post body") {
            let tests: [String: (input: String, output: String)] = [
                "with newlines": (input: "test<br><br />", output: "test\n\n"),
                "link": (input: "<a href=\"foo.com\">a link</a>", output: "[a link](foo.com)"),
                "entities": (input: "&lt;tag!&gt;that is a tag&lt;/tag&gt;", output: "<tag!>that is a tag</tag>"),
                "text and link": (input: "test <a href=\"foo.com\">a link</a>", output: "test [a link](foo.com)"),
                "styled text": (input: "test <b>bold</b> <i>italic</i> <strong>strong</strong> <em>emphasis</em>", output: "test bold italic strong emphasis")
            ]
            for (name, spec) in tests {
                it("should parse \(name)") {
                    let text = ElloAttributedString.parse(spec.input)
                    expect(text!.string) == spec.output
                }
            }
        }

        describe("rendering Post body") {
            let tests: [String: (input: String, output: String)] = [
                "with newlines": (input: "test<br><br />", output: "test\n\n"),
                "link": (input: "<a href=\"foo.com\">a link</a>", output: "[a link](foo.com)"),
                "entities": (input: "&lt;tag!&gt;that is a tag&lt;/tag&gt;", output: "&lt;tag!&gt;that is a tag&lt;/tag&gt;"),
                "text and link": (input: "test <a href=\"foo.com\">a link</a>", output: "test [a link](foo.com)"),
                "styled text": (input: "test <b>bold</b> <i>italic</i> <b><i>both</i></b> <strong>strong</strong> <em>emphasis</em> <em><strong>both</strong></em>", output: "test <strong>bold</strong> <em>italic</em> <strong><em>both</em></strong> <strong>strong</strong> <em>emphasis</em> <strong><em>both</em></strong>")
            ]
            for (name, spec) in tests {
                it("should parse \(name)") {
                    let text = ElloAttributedString.parse(spec.input)
                    let output = ElloAttributedString.render(text!)
                    expect(output) == spec.output
                }
            }
        }
    }
}
