////
///  ValidatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ValidatorSpec: QuickSpec {
    override func spec() {
        describe("Validator") {

            context("isValidLink") {
                let expectations: [(String, Bool)] = [
                    ("http://foo.com", true),
                    ("http://foo.com/path", true),
                    ("http://foo.com/+path", true),
                    ("http://foo.com/#path", true),
                    ("http://foo.com/and_(wow)", true),
                    ("https://foo.com", true),
                    ("http://foo.co", true),
                    ("http://foo.co:80", true),
                    ("example.com", true),
                    ("github.com/example", true),
                    ("HTTP://FOO.COM", true),
                    ("HTTPS://FOO.COM", true),
                    ("http://foo.com/blah_blah", true),
                    ("http://foo.com/blah_blah/", true),
                    ("http://foo.com/blah_blah_(wikipedia)", true),
                    ("http://foo.com/blah_blah_(wikipedia)_(again)", true),
                    ("http://www.example.com/wpstyle/?p=364", true),
                    ("https://www.example.com/foo/?bar=baz&inga=42&quux", true),
                    ("http://userid:password@example.com:8080", true),
                    ("http://userid:password@example.com:8080/", true),
                    ("http://userid@example.com", true),
                    ("http://userid@example.com/", true),
                    ("http://userid@example.com:8080", true),
                    ("http://userid@example.com:8080/", true),
                    ("http://userid:password@example.com", true),
                    ("http://userid:password@example.com/", true),
                    ("http://142.42.1.1/", true),
                    ("http://142.42.1.1:8080/", true),
                    ("http://foo.com/blah_(wikipedia)#cite-", true),
                    ("http://foo.com/blah_(wikipedia)_blah#cite-", true),
                    ("http://foo.com/(something)?after=parens", true),
                    ("http://code.google.com/events/#&product=browser", true),
                    ("http://j.mp", true),
                    ("http://foo.bar/?q=Test%20URL-encoded%20stuff", true),
                    ("http://1337.net", true),
                    ("http://a.b-c.de", true),
                    ("http://223.255.255.254", true),
                    ("", false),
                    ("foo", false),
                    ("ftp://foo.com", false),
                    ("ftp://foo.com", false),
                    ("http://..", false),
                    ("http://../", false),
                    ("//", false),
                    ("///", false),
                    ("http://##/", false),
                    ("http://.www.foo.bar./", false),
                    ("rdar://1234", false),
                    ("http://foo.bar?q=Spaces should be encoded", false),
                    ("http:// shouldfail.com", false),
                    (":// should fail", false),
                ]

                for (test, expected) in expectations {
                    it("Validator.isValidLink(\(test)) returns \(expected)") {
                        expect(Validator.isValidLink(test)) == expected
                    }
                }
            }

            context("hasValidLinks") {
                let expectations: [(String, Bool)] = [
                    ("http://foo.com", true),
                    ("http://foo.com,example.com", true),
                    ("http://foo.com, example.com", true),
                    ("", false),
                    ("foo", false),
                    ("foo,http://foo.com", false),
                ]

                for (test, expected) in expectations {
                    it("Validator.hasValidLinks(\(test)) returns \(expected)") {
                        expect(Validator.hasValidLinks(test)) == expected
                    }
                }
            }

            context("isValidEmail") {
                let expectations: [(String, Bool)] = [
                    ("name@test.com", true),
                    ("n@t.co", true),
                    ("n@t.shopping", true),
                    ("some.name@domain.co.uk", true),
                    ("some+name@domain.somethingreallylong", true),
                    ("test.com", false),
                    ("name@test", false),
                    ("name@.com", false),
                    ("name@name.com.", false),
                    ("name@name.t", false),
                    ("", false),
                ]

                for (test, expected) in expectations {
                    it("Validator.isValidEmail(\(test)) returns \(expected)") {
                        expect(Validator.isValidEmail(test)) == expected
                    }
                }
            }

            context("isValidUsername") {
                let expectations: [(String, Bool)] = [
                    ("", false),
                    ("a", false),
                    ("aa", true),
                    ("-a", true),
                    ("a-", true),
                    ("--", true),
                    ("user%", false),
                ]

                for (test, expected) in expectations {
                    it("isValidUsername(\(test)) returns \(expected)") {
                        expect(Validator.isValidUsername(test)) == expected
                    }
                }
            }

            context("isValidPassword") {
                let expectations: [(String, Bool)] = [
                    ("asdfasdf", true),
                    ("12345678", true),
                    ("123456789", true),
                    ("", false),
                    ("1", false),
                    ("12", false),
                    ("123", false),
                    ("1234", false),
                    ("12345", false),
                    ("123456", false),
                    ("1234567", false),
                ]

                for (test, expected) in expectations {
                    it("Validator.isValidPassword(\(test)) returns \(expected)") {
                        expect(Validator.isValidPassword(test)) == expected
                    }
                }
            }
        }
    }
}
