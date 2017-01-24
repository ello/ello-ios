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
        describe("unique() -> []") {
            it("should remove duplicates and preserve order") {
                let subject = [1,2,3,3,2,4,1,5]
                expect(subject.unique()) == [1,2,3,4,5]
            }
        }
    }
}
