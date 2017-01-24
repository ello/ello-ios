////
///  FreeMethodsTests.swift
//

@testable import Ello
import Quick
import Nimble


class FreeMethodsSpec: QuickSpec {
    override func spec() {
        describe("FreeMethods") {
            describe("times") {
                it("calls the block 5 times") {
                    var counter = 0
                    times(5) {
                        counter += 1
                    }
                    expect(counter) == 5
                }
            }

            describe("times with index") {
                it( "calls the block 5 times, passing in the index") {
                    var sum = 0
                    times(5) { index in
                        sum += index
                    }
                    expect(sum) == 10
                }
            }

            describe("after gets called") {
                it("should not get called after(2) (0)") {
                    var called = 0
                    _ = after(2) { called += 1 }
                    expect(called) == 0
                }
                it("should not get called after(2) (1)") {
                    var called = 0
                    let afterFn = after(2) { called += 1 }
                    afterFn()
                    expect(called) == 0
                }
                it("should get called after(2) (2)") {
                    var called = 0
                    let afterFn = after(2) { called += 1 }
                    afterFn()
                    afterFn()
                    expect(called) == 1
                }
            }

            describe("after only gets called once") {
                it("should not get called after(2) (3)") {
                    var called = 0
                    let afterFn = after(2) { called += 1 }
                    afterFn()
                    afterFn()
                    afterFn()
                    expect(called) == 1
                }
            }

            describe("after(0) called immediately") {
                it("gets called immediately after(0)") {
                    var called = 0
                    _ = after(0) { called += 1 }
                    expect(called) == 1
                }
            }

            describe("afterN gets called") {
                it("should not get called afterN(1) (0)") {
                    var called = 0
                    let (afterAll, _) = afterN() { called += 1 }
                    _ = afterAll()
                    expect(called) == 0
                }
                it("should not get called afterN(1) (1)") {
                    var called = 0
                    let (afterAll, _) = afterN() { called += 1 }
                    let blk = afterAll()
                    blk()
                    expect(called) == 0
                }
                it("should get called afterN(1) and done() (1)") {
                    var called = 0
                    let (afterAll, done) = afterN() { called += 1 }
                    let blk = afterAll()
                    done()
                    blk()
                    expect(called) == 1
                }
                it("should only get called once afterN(1) (2)") {
                    var called = 0
                    let (afterAll, done) = afterN() { called += 1 }
                    let blk = afterAll()
                    done()
                    blk()
                    blk()
                    expect(called) == 1
                }
                it("should get called afterN(2) (2)") {
                    var called = 0
                    let (afterAll, done) = afterN() { called += 1 }
                    let blk1 = afterAll()
                    let blk2 = afterAll()
                    done()
                    blk1()
                    expect(called) == 0
                    blk2()
                    expect(called) == 1
                }
                it("should get called afterN(2) (2) regardless of order") {
                    var called = 0
                    let (afterAll, done) = afterN() { called += 1 }
                    let blk1 = afterAll()
                    let blk2 = afterAll()
                    done()
                    blk2()
                    expect(called) == 0
                    blk1()
                    expect(called) == 1
                }
            }

            describe("until") {
                it("should get called until(2) (0)") {
                    var called = 0
                    _ = until(2) { called += 1 }
                    expect(called) == 0
                }
                it("should get called until(2) (1)") {
                    var called = 0
                    let untilFn = until(2) { called += 1 }
                    untilFn()
                    expect(called) == 1
                }
                it("should get called until(2) (2)") {
                    var called = 0
                    let untilFn = until(2) { called += 1 }
                    untilFn()
                    untilFn()
                    expect(called) == 2
                }
                it("should not be called until(2) (3)") {
                    var called = 0
                    let untilFn = until(2) { called += 1 }
                    untilFn()
                    untilFn()
                    untilFn()
                    expect(called) == 2
                }
            }

            describe("until never called") {
                it("should not be called until(0) (0)") {
                    var called = 0
                    let _ = until(0) { called += 1 }
                    expect(called) == 0
                }
                it("should not be called until(0) (1)") {
                    var called = 0
                    let untilFn = until(0) { called += 1 }
                    untilFn()
                    expect(called) == 0
                }
            }

            describe("once") {
                it("should not be called yet") {
                    var called = 0
                    let _ = once { called += 1 }
                    expect(called) == 0
                }
                it("should be called once") {
                    var called = 0
                    let onceFn = once { called += 1 }
                    onceFn()
                    expect(called) == 1
                }
                it("should only be called once") {
                    var called = 0
                    let onceFn = once { called += 1 }
                    onceFn()
                    onceFn()
                    expect(called) == 1
                }
            }
        }
    }

}
