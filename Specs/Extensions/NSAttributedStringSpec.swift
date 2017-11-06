////
///  NSAttributedStringSpec.swift
//

@testable import Ello
import Quick
import Nimble


class NSAttributedStringSpec: QuickSpec {
    override func spec() {
        describe("NSAttributedString") {
            it("NSAttributedString.defaultAttrs() accepts many additional options") {
                let c1 = UIColor.lightGray
                let c2 = UIColor.darkGray
                let attrs1: [NSAttributedStringKey: Any] = [.foregroundColor: c1]
                let attrs2: [NSAttributedStringKey: Any] = [.backgroundColor: c2]
                let attrs = NSAttributedString.defaultAttrs(attrs1, attrs2)
                expect(attrs[.foregroundColor] as? UIColor) == c1
                expect(attrs[.backgroundColor] as? UIColor) == c2
            }

            describe("joinWithNewlines(_: NSAttributedString)") {
                it("can insert two newlines") {
                    let subject1 = NSAttributedString(string: "one")
                    let subject2 = NSAttributedString(string: "two")
                    let joined = subject1.joinWithNewlines(subject2)
                    expect(joined.string) == "one\n\ntwo"
                }
                it("can insert one newline") {
                    let subject1 = NSAttributedString(string: "one\n")
                    let subject2 = NSAttributedString(string: "two")
                    let joined = subject1.joinWithNewlines(subject2)
                    expect(joined.string) == "one\n\ntwo"
                }
                it("can insert zero newlines") {
                    let subject1 = NSAttributedString(string: "one\n\n")
                    let subject2 = NSAttributedString(string: "two")
                    let joined = subject1.joinWithNewlines(subject2)
                    expect(joined.string) == "one\n\ntwo"
                }
            }

            describe("featuredIn(categories:)") {
                it("should render one category") {
                    let categories = [Category.featured]
                    let subject = NSAttributedString(featuredIn: categories)
                    expect(subject.string) == "Featured in Featured"
                }
                it("should render two categories") {
                    let categories = [Category.featured, Category.trending]
                    let subject = NSAttributedString(featuredIn: categories)
                    expect(subject.string) == "Featured in Featured & Trending"
                }
                it("should render three categories") {
                    let categories = [Category.featured, Category.trending, Category.recent]
                    let subject = NSAttributedString(featuredIn: categories)
                    expect(subject.string) == "Featured in Featured, Trending & Recent"
                }
            }
        }
    }
}
