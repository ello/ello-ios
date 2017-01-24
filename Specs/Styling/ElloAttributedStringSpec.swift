////
///  ElloAttributedStringSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ElloAttributedStringSpec: QuickSpec {
    override func spec() {
        describe("styling a string") {
            it("returns an attributed string") {
                let text = "text"
                let attrd = ElloAttributedString.style(text)
                expect(attrd).to(beAKindOf(NSAttributedString.self))
            }
            it("accepts additional options") {
                let text = "text"
                let c = UIColor.gray
                let attrd = ElloAttributedString.style(text, [NSForegroundColorAttributeName: c])
                expect(attrd).to(beAKindOf(NSAttributedString.self))
                expect(attrd.attributes(at: 0, effectiveRange: nil)[NSForegroundColorAttributeName] as? UIColor) == c
            }
            it("ElloAttributedString.attrs() accepts many additional options") {
                let c1 = UIColor.lightGray
                let c2 = UIColor.darkGray
                let attrs1: [String: AnyObject] = [NSForegroundColorAttributeName: c1]
                let attrs2: [String: AnyObject] = [NSBackgroundColorAttributeName: c2]
                let attrs = ElloAttributedString.attrs(attrs1, attrs2)
                expect(attrs[NSForegroundColorAttributeName] as? UIColor) == c1
                expect(attrs[NSBackgroundColorAttributeName] as? UIColor) == c2
            }
        }

        describe("splitting a string") {
            it("preserves a string") {
                let attrd = ElloAttributedString.style("text")
                let splits = ElloAttributedString.split(attrd)
                expect(splits.count) == 1
                expect(splits.safeValue(0)?.string) == "text"
            }
            it("preserves a string with emoji") {
                let attrd = ElloAttributedString.style("text😄")
                let splits = ElloAttributedString.split(attrd)
                expect(splits.count) == 1
                expect(splits.safeValue(0)?.string) == "text😄"
            }
            it("splits a string") {
                let attrd = ElloAttributedString.style("test1\ntest2")
                let splits = ElloAttributedString.split(attrd)
                expect(splits.count) == 2
                expect(splits.safeValue(0)?.string) == "test1\n"
                expect(splits.safeValue(1)?.string) == "test2"
            }
            it("splits a string with emoji") {
                let attrd = ElloAttributedString.style("test1😄\ntest2")
                let splits = ElloAttributedString.split(attrd)
                expect(splits.count) == 2
                expect(splits.safeValue(0)?.string) == "test1😄\n"
                expect(splits.safeValue(1)?.string) == "test2"
            }
            it("preserves trailing newlines") {
                let attrd = ElloAttributedString.style("test1\ntest2\n\n")
                let splits = ElloAttributedString.split(attrd)
                expect(splits.count) == 2
                expect(splits.safeValue(0)?.string) == "test1\n"
                expect(splits.safeValue(1)?.string) == "test2\n\n"
            }
            it("preserves trailing newlines with emoji") {
                let attrd = ElloAttributedString.style("test1\n😄test2\n\n")
                let splits = ElloAttributedString.split(attrd)
                expect(splits.count) == 2
                expect(splits.safeValue(0)?.string) == "test1\n"
                expect(splits.safeValue(1)?.string) == "😄test2\n\n"
            }
            it("preserves preceding newlines") {
                let attrd = ElloAttributedString.style("\n\ntest1\ntest2")
                let splits = ElloAttributedString.split(attrd)
                expect(splits.count) == 2
                expect(splits.safeValue(0)?.string) == "\n\ntest1\n"
                expect(splits.safeValue(1)?.string) == "test2"
            }
            it("preserves many regions") {
                let attrd = ElloAttributedString.style("\n\ntest1\n\ntest2\ntest3\n\n\n")
                let splits = ElloAttributedString.split(attrd)
                expect(splits.count) == 3
                expect(splits.safeValue(0)?.string) == "\n\ntest1\n\n"
                expect(splits.safeValue(1)?.string) == "test2\n"
                expect(splits.safeValue(2)?.string) == "test3\n\n\n"
            }
            it("preserves many regions with emoji") {
                let attrd = ElloAttributedString.style("\n\n😄test1\n\nte😄st2\ntest3😄\n😄\n\n")
                let splits = ElloAttributedString.split(attrd)
                expect(splits.count) == 4
                expect(splits.safeValue(0)?.string) == "\n\n😄test1\n\n"
                expect(splits.safeValue(1)?.string) == "te😄st2\n"
                expect(splits.safeValue(2)?.string) == "test3😄\n"
                expect(splits.safeValue(3)?.string) == "😄\n\n"
            }
        }

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
