////
///  CGRectSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CGRectExtensionSpec: QuickSpec {
    override func spec() {
        describe("getters") {
            let badFrame = CGRect(x: 4, y: 2, width: -4, height: -2)
            it("should return raw values") {
                expect(badFrame.x).to(equal(CGFloat(4)))
                expect(badFrame.y).to(equal(CGFloat(2)))
            }
            it("should return center") {
                let center = badFrame.center
                expect(center.x).to(equal(CGFloat(2)))
                expect(center.y).to(equal(CGFloat(1)))
            }
        }

        describe("factories") {
            describe("CGRect w/ right & bottom") {
                let newFrame = CGRect(x: 1, y: 2, right: 4, bottom: 6)
                it("should set x")      { expect(newFrame.origin.x) == 1 }
                it("should set y")      { expect(newFrame.origin.y) == 2 }
                it("should set width")  { expect(newFrame.size.width) == 3 }
                it("should set height") { expect(newFrame.size.height) == 4 }
            }
            describe("CGRect w/ x & y (size zero)") {
                let newFrame = CGRect(x: 1, y: 2)
                it("should set x")      { expect(newFrame.origin.x) == 1 }
                it("should set y")      { expect(newFrame.origin.y) == 2 }
                it("should set width")     { expect(newFrame.size.width) == 0 }
                it("should set height") { expect(newFrame.size.height) == 0 }
            }
            describe("CGRect w/ origin (size zero)") {
                let newFrame = CGRect(origin: CGPoint(x: 1, y: 2))
                it("should set x")      { expect(newFrame.origin.x) == 1 }
                it("should set y")      { expect(newFrame.origin.y) == 2 }
                it("should set width")     { expect(newFrame.size.width) == 0 }
                it("should set height") { expect(newFrame.size.height) == 0 }
            }
            describe("CGRect w/ width & height (origin zero)") {
                let newFrame = CGRect(width: 1, height: 2)
                it("should set x")      { expect(newFrame.origin.x) == 0 }
                it("should set y")      { expect(newFrame.origin.y) == 0 }
                it("should set width")     { expect(newFrame.size.width) == 1 }
                it("should set height") { expect(newFrame.size.height) == 2 }
            }
            describe("CGRect w/ size (origin zero)") {
                let newFrame = CGRect(size: CGSize(width: 1, height: 2))
                it("should set x")      { expect(newFrame.origin.x) == 0 }
                it("should set y")      { expect(newFrame.origin.y) == 0 }
                it("should set width")     { expect(newFrame.size.width) == 1 }
                it("should set height") { expect(newFrame.size.height) == 2 }
            }
        }

        describe("setters") {
            let frame = CGRect(x: 1, y: 2, width: 3, height: 4)
            describe("-atOrigin:") {
                let newFrame = frame.at(origin: CGPoint(x: 5, y: 5))
                it("should set x")      { expect(newFrame.origin.x).to(equal(CGFloat(5)))}
                it("should set y")      { expect(newFrame.origin.y).to(equal(CGFloat(5)))}
                it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            describe("-withSize:") {
                let newFrame = frame.with(size: CGSize(width: 5, height: 5))
                it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should set width")     { expect(newFrame.size.width).to(equal(CGFloat(5)))}
                it("should set height") { expect(newFrame.size.height).to(equal(CGFloat(5)))}
            }
            describe("-atX:") {
                let newFrame = frame.at(x: 5)
                it("should set x")      { expect(newFrame.origin.x).to(equal(CGFloat(5)))}
                it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            describe("-atY:") {
                let newFrame = frame.at(y: 5)
                it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should set y")      { expect(newFrame.origin.y).to(equal(CGFloat(5)))}
                it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            describe("-withWidth:") {
                let newFrame = frame.with(width: 5)
                it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should set width")     { expect(newFrame.size.width).to(equal(CGFloat(5)))}
                it("should ignore height") { expect(newFrame.size.height).to(equal(CGFloat(4)))}
            }
            describe("-withHeight:") {
                let newFrame = frame.with(height: 5)
                it("should ignore x")      { expect(newFrame.origin.x).to(equal(CGFloat(1)))}
                it("should ignore y")      { expect(newFrame.origin.y).to(equal(CGFloat(2)))}
                it("should ignore width")     { expect(newFrame.size.width).to(equal(CGFloat(3)))}
                it("should set height") { expect(newFrame.size.height).to(equal(CGFloat(5)))}
            }
        }
        describe("inset(Xyz:)") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-inset(all:)") {
                let newFrame = frame.inset(all: 1)
                expect(newFrame).to(equal(CGRect(x: 6, y: 8, width: 8, height: 12)))
            }
            it("-inset(topBottom:sides:)") {
                let newFrame = frame.inset(topBottom: 1, sides: 2)
                expect(newFrame).to(equal(CGRect(x: 7, y: 8, width: 6, height: 12)))
            }
            it("-inset(topBottom:)") {
                let newFrame = frame.inset(topBottom: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 8, width: 10, height: 12)))
            }
            it("-inset(sides:)") {
                let newFrame = frame.inset(sides: 2)
                expect(newFrame).to(equal(CGRect(x: 7, y: 7, width: 6, height: 14)))
            }
            it("-inset(top:sides:bottom:)") {
                let newFrame = frame.inset(top: 1, sides: 2, bottom: 3)
                expect(newFrame).to(equal(CGRect(x: 7, y: 8, width: 6, height: 10)))
            }
            it("-inset(top:left:bottom:right:)") {
                let newFrame = frame.inset(top: 1, left: 2, bottom: 3, right: 4)
                expect(newFrame).to(equal(CGRect(x: 7, y: 8, width: 4, height: 10)))
            }
            it("-inset(insets)") {
                let insets = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
                let newFrame = frame.inset(insets)
                expect(newFrame).to(equal(CGRect(x: 7, y: 8, width: 4, height: 10)))
            }
        }
        describe("shrink(direction:)") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-shrink(left:)") {
                let newFrame = frame.shrink(left: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 9, height: 14)))
            }
            it("-shrink(right:)") {
                let newFrame = frame.shrink(right: 1)
                expect(newFrame).to(equal(CGRect(x: 6, y: 7, width: 9, height: 14)))
            }
            it("-shrink(down:)") {
                let newFrame = frame.shrink(down: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 8, width: 10, height: 13)))
            }
            it("-shrink(up:)") {
                let newFrame = frame.shrink(up: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 10, height: 13)))
            }
        }
        describe("grow(Xyz:)") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-grow(margins)") {
                let margins = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
                let newFrame = frame.grow(margins)
                expect(newFrame).to(equal(CGRect(x: 3, y: 6, width: 16, height: 18)))
            }
            it("-grow(all:)") {
                let newFrame = frame.grow(all: 1)
                expect(newFrame).to(equal(CGRect(x: 4, y: 6, width: 12, height: 16)))
            }
            it("-grow(topBottom:sides:)") {
                let newFrame = frame.grow(topBottom: 1, sides: 2)
                expect(newFrame).to(equal(CGRect(x: 3, y: 6, width: 14, height: 16)))
            }
            it("-grow(top:sides:bottom:)") {
                let newFrame = frame.grow(top: 1, sides: 2, bottom: 3)
                expect(newFrame).to(equal(CGRect(x: 3, y: 6, width: 14, height: 18)))
            }
            it("-grow(top:left:bottom:right:)") {
                let newFrame = frame.grow(top: 1, left: 2, bottom: 3, right: 4)
                expect(newFrame).to(equal(CGRect(x: 3, y: 6, width: 16, height: 18)))
            }
        }
        describe("growXyz") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-growLeft:") {
                let newFrame = frame.grow(left: 1)
                expect(newFrame).to(equal(CGRect(x: 4, y: 7, width: 11, height: 14)))
            }
            it("-growRight:") {
                let newFrame = frame.grow(right: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 11, height: 14)))
            }
            it("-growUp:") {
                let newFrame = frame.grow(up: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 6, width: 10, height: 15)))
            }
            it("-growDown:") {
                let newFrame = frame.grow(down: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 10, height: 15)))
            }
        }
        describe("-fromXyz:") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-fromTop:") {
                let newFrame = frame.fromTop()
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 10, height: 0)))
            }
            it("-fromBottom:") {
                let newFrame = frame.fromBottom()
                expect(newFrame).to(equal(CGRect(x: 5, y: 21, width: 10, height: 0)))
            }
            it("-fromLeft:") {
                let newFrame = frame.fromLeft()
                expect(newFrame).to(equal(CGRect(x: 5, y: 7, width: 0, height: 14)))
            }
            it("-fromRight:") {
                let newFrame = frame.fromRight()
                expect(newFrame).to(equal(CGRect(x: 15, y: 7, width: 0, height: 14)))
            }
        }
        describe("shiftXyz") {
            let frame = CGRect(x: 5, y: 7, width: 10, height: 14)
            it("-shiftUp:") {
                let newFrame = frame.shift(up: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 6, width: 10, height: 14)))
            }
            it("-shiftDown:") {
                let newFrame = frame.shift(down: 1)
                expect(newFrame).to(equal(CGRect(x: 5, y: 8, width: 10, height: 14)))
            }
            it("-shiftLeft:") {
                let newFrame = frame.shift(left: 1)
                expect(newFrame).to(equal(CGRect(x: 4, y: 7, width: 10, height: 14)))
            }
            it("-shiftRight:") {
                let newFrame = frame.shift(right: 1)
                expect(newFrame).to(equal(CGRect(x: 6, y: 7, width: 10, height: 14)))
            }
        }
    }
}
