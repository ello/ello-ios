////
///  ArraySpec.swift
//

@testable import Ello
import Quick
import Nimble


class ArraySpec: QuickSpec {
    override func spec() {
        describe("safeValue(_:Int)->T") {
            let subject = [1,2,3]
            it("should return Some<Int> when valid") {
                let val1 = subject.safeValue(0)
                expect(val1) == 1
                let val2 = subject.safeValue(2)
                expect(val2) == 3
            }
            it("should return None when invalid") {
                let val1 = subject.safeValue(3)
                expect(val1).to(beNil())
                let val2 = subject.safeValue(100)
                expect(val2).to(beNil())
            }
        }
        describe("find(test:(T) -> Bool) -> Bool") {
            let subject = [1,2,3]
            it("should return 2 if test passes") {
                expect(subject.find { $0 == 2 }) == 2
            }
            it("should return 1 when first test passes") {
                expect(subject.find { $0 < 4 }) == 1
            }
            it("should return nil if no tests pass") {
                expect(subject.find { $0 < 0 }).to(beNil())
            }
        }
        describe("any(test:(T) -> Bool) -> Bool") {
            let subject = [1,2,3]
            it("should return true if any pass") {
                expect(subject.any { $0 == 2 }) == true
            }
            it("should return true if all pass") {
                expect(subject.any { $0 < 4 }) == true
            }
            it("should return false if none pass") {
                expect(subject.any { $0 < 0 }) == false
            }
        }
        describe("all(test:(T) -> Bool) -> Bool") {
            let subject = [1,2,3]
            it("should return false if only one pass") {
                expect(subject.all { $0 == 2 }) == false
            }
            it("should return true if all pass") {
                expect(subject.all { $0 < 4 }) == true
            }
            it("should return false if none pass") {
                expect(subject.all { $0 < 0 }) == false
            }
        }
        describe("eachPair arity 2") {
            var a: Int?, b: Int?, count: Int = 0
            beforeEach {
                (a, b) = (nil, nil)
                count = 0
            }
            it("should work with zero items") {
                let subject: [Int] = []
                subject.eachPair { prev, curr in
                    (a, b) = (prev, curr)
                    count += 1
                }
                expect(a).to(beNil())
                expect(b).to(beNil())
                expect(count) == subject.count
            }
            it("should work with one item") {
                let subject = [1]
                subject.eachPair { prev, curr in
                    (a, b) = (prev, curr)
                    count += 1
                }
                expect(a).to(beNil())
                expect(b) == 1
                expect(count) == subject.count
            }
            it("should work with two items") {
                let subject = [1,2]
                subject.eachPair { prev, curr in
                    (a, b) = (prev, curr)
                    count += 1
                }
                expect(a) == 1
                expect(b) == 2
                expect(count) == subject.count
            }
            it("should work with more items") {
                let subject = [1,2,3]
                subject.eachPair { prev, curr in
                    switch count {
                    case 0:
                        expect(prev).to(beNil())
                        expect(curr) == 1
                    case 1:
                        expect(prev) == 1
                        expect(curr) == 2
                    case 2:
                        expect(prev) == 2
                        expect(curr) == 3
                    default:
                        fail()
                    }

                    count += 1
                }
            }
        }
        describe("eachPair arity 3") {
            var a: Int?, b: Int?, expectedIsLast: Bool?, count: Int = 0
            beforeEach {
                (a, b, expectedIsLast) = (nil, nil, nil)
                count = 0
            }
            it("should work with zero items") {
                let subject: [Int] = []
                subject.eachPair { prev, curr, isLast in
                    (a, b, expectedIsLast) = (prev, curr, isLast)
                    count += 1
                }
                expect(a).to(beNil())
                expect(b).to(beNil())
                expect(count) == subject.count
            }
            it("should work with one item") {
                let subject = [1]
                subject.eachPair { prev, curr, isLast in
                    (a, b, expectedIsLast) = (prev, curr, isLast)
                    count += 1
                }
                expect(a).to(beNil())
                expect(b) == 1
                expect(expectedIsLast) == true
                expect(count) == subject.count
            }
            it("should work with two items") {
                let subject = [1,2]
                var wasLast: Bool?
                subject.eachPair { prev, curr, isLast in
                    wasLast = expectedIsLast
                    (a, b, expectedIsLast) = (prev, curr, isLast)
                    count += 1
                }
                expect(a) == 1
                expect(b) == 2
                expect(wasLast) == false
                expect(expectedIsLast) == true
                expect(count) == subject.count
            }
            it("should work with more items") {
                let subject = [1,2,3]
                subject.eachPair { prev, curr, isLast in
                    switch count {
                    case 0:
                        expect(prev).to(beNil())
                        expect(curr) == 1
                        expect(isLast) == false
                    case 1:
                        expect(prev) == 1
                        expect(curr) == 2
                        expect(isLast) == false
                    case 2:
                        expect(prev) == 2
                        expect(curr) == 3
                        expect(isLast) == true
                    default:
                        fail()
                    }

                    count += 1
                }
            }
        }
        describe("unique() -> []") {
            it("should remove duplicates and preserve order") {
                let subject = [1,2,3,3,2,4,1,5]
                expect(subject.unique()) == [1,2,3,4,5]
            }
        }
    }
}
