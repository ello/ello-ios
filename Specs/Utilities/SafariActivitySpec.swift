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
                expect(subject.activityType()) == "SafariActivity"
            }

            it("activityTitle()") {
                expect(subject.activityTitle()) == "Open in Safari"
            }

            it("activityImage()") {
                expect(subject.activityImage()).toNot(beNil())
            }

            context("canPerformWithActivityItems(items: [AnyObject]) -> Bool") {
                let url = NSURL(string: "https://ello.co")!
                let url2 = NSURL(string: "https://google.com")!
                let string = "ignore"
                let image = UIImage.imageWithColor(.blueColor())!
                let expectations: [(String, [AnyObject], Bool)] = [
                    ("a url", [url], true),
                    ("a url and a string", [url, string], true),
                    ("two urls", [string, url, string, url2], true),

                    ("a string", [string], false),
                    ("a string and an image", [image, string], false),
                ]
                for (description, items, expected) in expectations {
                    it("should return \(expected) for \(description)") {
                        expect(subject.canPerformWithActivityItems(items)) == expected
                    }
                }
            }

            context("prepareWithActivityItems(items: [AnyObject])") {
                let url = NSURL(string: "https://ello.co")!
                let url2 = NSURL(string: "https://google.com")!
                let string = "ignore"
                let image = UIImage.imageWithColor(.blueColor())!
                let expectations: [(String, [AnyObject], NSURL?)] = [
                    ("a url", [url], url),
                    ("a url and a string", [url, string], url),
                    ("two urls", [string, url, string, url2], url),

                    ("a string", [string], nil),
                    ("a string and an image", [image, string], nil),
                ]
                for (description, items, expected) in expectations {
                    it("should assign \(expected) for \(description)") {
                        subject.prepareWithActivityItems(items)
                        if expected == nil {
                            expect(subject.url).to(beNil())
                        }
                        else {
                            expect(subject.url) == expected
                        }
                    }
                }
            }

        }
    }
}
