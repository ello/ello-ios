////
///  RegexExtensionsSpec.swift
//

@testable import Ello
import Quick
import Nimble

class RegexExtensionsSpec: QuickSpec {
    override func spec() {
        describe("RegexExtensions") {
            context("Regex class") {
                it("should create an instance") {
                    let regex = Regex("^$")
                    expect(regex).notTo(beNil())
                }
                it("should be nil if invalid regex") {
                    let regex = Regex("[")
                    expect(regex).to(beNil())
                }
                context("test(String)") {
                    let regex = Regex("^tes*t$")!
                    let expectations = [
                        "tet": true,
                        "test": true,
                        "tesst": true,
                        "BOO!": false,
                    ]
                    for (test, expectation) in expectations {
                        it("'\(test)' should return \(expectation)") {
                            expect(regex.test(test)) == expectation
                        }
                    }
                }
                context("match(String)") {
                    let regex = Regex("^tes*t$")!
                    let expectations = [
                        "tet": true,
                        "test": true,
                        "tesst": true,
                        "BOO!": false,
                    ]
                    for (test, expectation) in expectations {
                        let expected = expectation ? test : "nil"
                        it("'\(test)' should return \(expected)") {
                            if expectation {
                                expect(regex.match(test)) == test
                            }
                            else {
                                expect(regex.match(test)).to(beNil())
                            }
                        }
                    }
                    it("should return the matched part of a string") {
                        let regex = Regex("\\w+")!
                        expect(regex.match("!!!abc!!!")) == "abc"
                        expect(regex.match("!!!abc")) == "abc"
                        expect(regex.match("abc!!!")) == "abc"
                    }
                }
                context("matches(String)") {
                    let regex = Regex("\\w+")!
                    let expectations = [
                        "test": ["test"],
                        "test test2": ["test", "test2"],
                        "!test!ing!": ["test", "ing"],
                        "BOO!": ["BOO"],
                    ]
                    for (test, expectation) in expectations {
                        let expected = expectation.joined(separator: ",")
                        it("'\(test)' should return \(expected)") {
                            expect(regex.matches(test)) == expectation
                        }
                    }
                }
                context("matches(String) with groups") {
                    let regex = Regex("([a-zA-Z]+)(\\d+)")!
                    let expectations = [
                        "test1": ["test1"],
                        "test1 test2": ["test1", "test2"],
                        "!test1!ing2!": ["test1", "ing2"],
                        "BOO1!": ["BOO1"],
                    ]
                    for (test, expectation) in expectations {
                        let expected = expectation.joined(separator: ",")
                        it("'\(test)' should return \(expected)") {
                            expect(regex.matches(test)) == expectation
                        }
                    }
                }
                context("matchingGroups(String)") {
                    let regex = Regex("(\\w+)/(\\w+)")!
                    let expectations = [
                        "test1/test2": ["test1/test2", "test1", "test2"],
                        "test1/test2\ntest3/test4": ["test1/test2", "test1", "test2"],
                        "!test1/test2!": ["test1/test2", "test1", "test2"],
                    ]
                    for (test, expectation) in expectations {
                        let expected = expectation.joined(separator: ",")
                        it("'\(test)' should return \(expected)") {
                            expect(regex.matchingGroups(test)) == expectation
                        }
                    }
                }
            }

            context("testing with regex operators =~ !~") {
                let pattern = "^tes*t$"
                let regex = Regex(pattern)!

                let expectations = [
                    "tet": true,
                    "test": true,
                    "tesst": true,
                    "BOO!": false,
                ]
                for (test, expectation) in expectations {
                    it("'\(test)' should return \(expectation)") {
                        expect(test =~ pattern) == expectation
                        expect(test !~ pattern) == !expectation
                        expect(test =~ regex) == expectation
                        expect(test !~ regex) == !expectation
                    }
                }
                it("should return false for invalid regex") {
                    expect("anything" =~ "[") == false
                    expect("anything" !~ "[") == false
                }
            }

            context("matching with ~") {
                let pattern = "^tes*t$"
                let regex = Regex(pattern)!

                let expectations = [
                    "tet": true,
                    "test": true,
                    "tesst": true,
                    "BOO!": false,
                ]
                for (test, expectation) in expectations {
                    let expected = expectation ? test : "nil"
                    it("'\(test)' should return \(expected)") {
                        if expectation {
                            expect(test ~ pattern) == test
                            expect(test ~ regex) == test
                        }
                        else {
                            expect(test ~ pattern).to(beNil())
                        }
                    }
                }

                it("should return the matched part of a string") {
                    let pattern = "\\w+"
                    let regex = Regex(pattern)!

                    let expected = "abc"
                    let tests = [
                        "!!!\(expected)!!!",
                        "!!!\(expected)",
                        "\(expected)!!!",
                    ]
                    for test in tests {
                        expect(test ~ pattern) == expected
                        expect(test ~ regex) == expected
                    }
                }

                it("should return nil for invalid regex") {
                    expect("anything" ~ "[").to(beNil())
                }
            }
        }
    }
}
