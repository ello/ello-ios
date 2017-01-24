////
///  SafariActivitySpec.swift
//

@testable import Ello
import Quick
import Nimble


class SafariActivitySpec: QuickSpec {
    override func spec() {
        describe("SafariActivity") {
            var subject: SafariActivity!

            beforeEach {
                subject = SafariActivity()
            }

            it("activityType()") {
                expect(subject.activityType.rawValue) == "SafariActivity"
            }

            it("activityTitle()") {
                expect(subject.activityTitle) == "Open in Safari"
            }

            it("activityImage()") {
                expect(subject.activityImage).toNot(beNil())
            }

            context("canPerformWithActivityItems(items: [AnyObject]) -> Bool") {
                let url = URL(string: "https://ello.co")!
                let url2 = URL(string: "https://google.com")!
                let string = "ignore"
                let image = UIImage.imageWithColor(.blue)!
                let expectations: [(String, [Any], Bool)] = [
                    ("a url", [url], true),
                    ("a url and a string", [url, string as AnyObject], true),
                    ("two urls", [string, url, string, url2], true),

                    ("a string", [string], false),
                    ("a string and an image", [image, string], false),
                ]
                for (description, items, expected) in expectations {
                    it("should return \(expected) for \(description)") {
                        expect(subject.canPerform(withActivityItems: items)) == expected
                    }
                }
            }

            context("prepareWithActivityItems(items: [AnyObject])") {
                let url = URL(string: "https://ello.co")!
                let url2 = URL(string: "https://google.com")!
                let string = "ignore"
                let image = UIImage.imageWithColor(.blue)!
                let expectations: [(String, [Any], URL?)] = [
                    ("a url", [url], url),
                    ("a url and a string", [url, string as AnyObject], url),
                    ("two urls", [string, url, string, url2], url),

                    ("a string", [string], nil),
                    ("a string and an image", [image, string], nil),
                ]
                for (description, items, expected) in expectations {
                    it("should assign \(expected) for \(description)") {
                        subject.prepare(withActivityItems: items)
                        if expected == nil {
                            expect(subject.url).to(beNil())
                        }
                        else {
                            expect(subject.url) == expected as URL?
                        }
                    }
                }
            }

        }
    }
}
