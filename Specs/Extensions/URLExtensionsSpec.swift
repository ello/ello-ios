////
///  URLSpec.swift
//

@testable import Ello
import Quick
import Nimble

class URLExtensionSpec: QuickSpec {
    override func spec() {
        describe("hasGifExtension") {
            let expectations: [(String, Bool)] = [
                ("http://ello.co/file.gif", true),
                ("http://ello.co/file.GIF", true),
                ("http://ello.co/file.Gif", true),
                ("http://ello.co/filegif", false),
                ("http://ello.co/file/gif", false),
            ]
            for (url, expected) in expectations {
                it("should be \(expected) for \(url)") {
                    expect(URL(string: url)?.hasGifExtension) == expected
                }
            }
        }

        describe("isValidShorthand") {
            let expectations: [(String, Bool)] = [
                ("", false),
                ("http://", false),
                ("://", false),
                ("://ello.co", false),
                ("ello", false),
                ("http://ello", false),
                ("http://ello.", false),
                ("http://ello/foo.html", false),

                ("ello.co", true),
                ("http://ello.co", true),
                ("https://ello.co", true),
                ("http://any.where/foo", true),
            ]
            for (url, expected) in expectations {
                it("\(url) should\(expected ? "" : " not") be valid") {
                    expect(URL.isValidShorthand(url)) == expected
                }
            }
        }

        describe("absoluteStringWithoutProtocol") {
            it("returns the path of the url without the protocol") {
                let expectedPath = "stream/foo/bar"
                let path = "ello://" + expectedPath
                let url = URL(string: path)

                expect(url?.absoluteStringWithoutProtocol).to(equal(expectedPath))
            }
        }
    }
}
