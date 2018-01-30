////
///  StringExtensionSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StringExtensionSpec: QuickSpec {
    override func spec() {
        describe("String") {
            describe("encoding URL strings") {
                it("should encode 'asdf' to 'asdf'") {
                    let str = "asdf"
                    expect(str.urlEncoded()).to(equal("asdf"))
                }
                it("should encode 'a&/=' to 'a%26%2F%3D'") {
                    let str = "a&/="
                    expect(str.urlEncoded()).to(equal("a%26%2F%3D"))
                }
                it("should encode '…' to '%E2%80%A6'") {
                    let str = "…"
                    expect(str.urlEncoded()).to(equal("%E2%80%A6"))
                }
            }
            describe("decoding URL strings") {
                it("should decode 'asdf' to 'asdf'") {
                    let str = "asdf"
                    expect(str.urlDecoded()).to(equal("asdf"))
                }
                it("should decode 'a%26%2F%3D' to 'a&/='") {
                    let str = "a%26%2F%3D"
                    expect(str.urlDecoded()).to(equal("a&/="))
                }
                it("should decode '%E2%80%A6' to '…'") {
                    let str = "%E2%80%A6"
                    expect(str.urlDecoded()).to(equal("…"))
                }
            }
            describe("stripping HTML src attribute") {
                it("should replace the src= attribute with double quotes") {
                    let str = "<img src=\"foo\" />"
                    expect(str.stripHtmlImgSrc()).to(beginWith("<img src=\""))
                    expect(str.stripHtmlImgSrc()).to(endWith("\" />"))
                    expect(str.stripHtmlImgSrc()).notTo(contain("foo"))
                    expect(str.stripHtmlImgSrc().count) > str.count
                }
                it("should replace the src= attribute with single quotes") {
                    let str = "<img src='foo' />"
                    expect(str.stripHtmlImgSrc()).to(beginWith("<img src=\""))
                    expect(str.stripHtmlImgSrc()).to(endWith("\" />"))
                    expect(str.stripHtmlImgSrc()).notTo(contain("foo"))
                    expect(str.stripHtmlImgSrc().count) > str.count
                }
            }
            describe("adding entities") {
                it("should handle 1-char length strings") {
                    let str = "&"
                    expect(str.entitiesEncoded()).to(equal("&amp;"))
                }
                it("should handle longer length strings") {
                    let str = "black & blue"
                    expect(str.entitiesEncoded()).to(equal("black &amp; blue"))
                }
                it("should handle many entities") {
                    let str = "&\"<>'"
                    expect(str.entitiesEncoded()).to(equal("&amp;&quot;&lt;&gt;&#039;"))
                }
                it("should handle many entities with strings") {
                    let str = "a & < c > == d"
                    expect(str.entitiesEncoded()).to(equal("a &amp; &lt; c &gt; == d"))
                }
            }
            describe("removing entities") {
                it("should handle 1-char length strings") {
                    let str = "&amp;"
                    expect(str.entitiesDecoded()).to(equal("&"))
                }
                it("should handle longer length strings") {
                    let str = "black &amp; blue"
                    expect(str.entitiesDecoded()).to(equal("black & blue"))
                }
                it("should handle many entities") {
                    let str = "&amp; &lt;&gt; &pi;"
                    expect(str.entitiesDecoded()).to(equal("& <> π"))
                }
                it("should handle many entities with strings") {
                    let str = "a &amp; &lt; c &gt; &pi; == pi"
                    expect(str.entitiesDecoded()).to(equal("a & < c > π == pi"))
                }
            }
            describe("salted sha1 hashing") {
                it("hashes the string using the sha1 algorithm with a prefixed salt value") {
                    let str = "test"
                    expect(str.saltedSHA1String) == "5bb3e61a51e40b8074716d2a30549c5b7b55cf63"
                }
            }
            describe("sha1 hashing") {
                it("hashes the string using the sha1 algorithm") {
                    let str = "test"
                    expect(str.SHA1String) == "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3"
                }
            }
            describe("split") {
                it("splits a string") {
                    let str = "a,b,cc,ddd"
                    expect(str.split(",")) == ["a", "b", "cc", "ddd"]
                }
                it("ignores a string with no splits") {
                    let str = "abccddd"
                    expect(str.split(",")) == ["abccddd"]
                }
            }
            describe("trimmed") {
                it("trims leading whitespace") {
                    let strs = [
                        "  string",
                        "\t\tstring",
                        " \t\nstring",
                    ]
                    for str in strs {
                        expect(str.trimmed()) == "string"
                    }
                }
                it("trims trailing whitespace") {
                    let strs = [
                        "string  ",
                        "string\t\t",
                        "string\n\t ",
                    ]
                    for str in strs {
                        expect(str.trimmed()) == "string"
                    }
                }
                it("trims leading and trailing whitespace") {
                    let strs = [
                        "  string  ",
                        "\t\tstring\t\t",
                        "\n \tstring\t\n ",
                    ]
                    for str in strs {
                        expect(str.trimmed()) == "string"
                    }
                }
                it("ignores embedded whitespace") {
                    let strs = [
                        "str  ing",
                        "  str  ing",
                        "\t\tstr  ing",
                        "\n\nstr  ing",
                        "str  ing  ",
                        "str  ing\t\t",
                        "str  ing\n\n",
                        "  str  ing  ",
                        "\t\tstr  ing\t\t",
                        "\n\nstr  ing\n\n",
                    ]
                    for str in strs {
                        expect(str.trimmed()) == "str  ing"
                    }
                }
            }
            describe("camelCase") {
                it("converts a string from snake case to camel case") {
                    let snake = "hhhhh_sssss"
                    expect(snake.camelCase) == "hhhhhSssss"
                }
            }
            describe("jsonQuoted") {
                let expectations: [(String, String)] = [
                    ("", "\"\""),
                    ("test", "\"test\""),
                    ("newline\ntest", "\"newline\\ntest\""),
                    ("carriage\rtest", "\"carriage\\rtest\""),
                    ("quote\"test", "\"quote\\\"test\""),
                    ("quote'test", "\"quote'test\""),
                    ("日本語 test", "\"日本語 test\""),
                ]
                for (input, expected) in expectations {
                    it("should quote \(input)") {
                        expect(input.jsonQuoted) == expected
                    }
                }
            }
        }
    }
}
