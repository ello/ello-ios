////
///  CGSizeSpec.swift
//

import Quick
import Nimble
@testable import Ello


class CGSizeSpec: QuickSpec {
    override func spec() {
        context("integral") {
            it("should return already integral sizes") {
                expect(CGSize(width: 10, height: 10).integral) == CGSize(width: 10, height: 10)
            }
            it("should round width up") {
                expect(CGSize(width: 10.1, height: 10).integral) == CGSize(width: 11, height: 10)
                expect(CGSize(width: 10.6, height: 10).integral) == CGSize(width: 11, height: 10)
            }
            it("should round height up") {
                expect(CGSize(width: 10, height: 10.1).integral) == CGSize(width: 10, height: 11)
                expect(CGSize(width: 10, height: 10.6).integral) == CGSize(width: 10, height: 11)
            }
            it("should round width and height up") {
                expect(CGSize(width: 10.1, height: 10.1).integral) == CGSize(width: 11, height: 11)
                expect(CGSize(width: 10.6, height: 10.6).integral) == CGSize(width: 11, height: 11)
            }
        }

        context("scaledSize(_:)") {
            describe("should ignore sizes that are already small enough") {
                it("CGSize(width: 100, height: 100).scaledSize(CGSize(width: 1000, height: 1000))") {
                    let initial = CGSize(width: 100, height: 100)
                    let maxSize = CGSize(width: 1000, height: 1000)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == initial.width
                    expect(subject.height) == initial.height
                }
                it("CGSize(width: 100, height: 100).scaledSize(CGSize(width: 100, height: 1000))") {
                    let initial = CGSize(width: 100, height: 100)
                    let maxSize = CGSize(width: 100, height: 1000)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == initial.width
                    expect(subject.height) == initial.height
                }
                it("CGSize(width: 100, height: 100).scaledSize(CGSize(width: 1000, height: 100))") {
                    let initial = CGSize(width: 100, height: 100)
                    let maxSize = CGSize(width: 1000, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == initial.width
                    expect(subject.height) == initial.height
                }
                it("CGSize(width: 100, height: 100).scaledSize(CGSize(width: 100, height: 100))") {
                    let initial = CGSize(width: 100, height: 100)
                    let maxSize = CGSize(width: 100, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == initial.width
                    expect(subject.height) == initial.height
                }
            }
            describe("should change the width") {
                it("CGSize(width: 1000, height: 500).scaledSize(CGSize(width: 100, height: 1000))") {
                    let initial = CGSize(width: 1000, height: 500)
                    let maxSize = CGSize(width: 100, height: 1000)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(100)
                    expect(subject.height) == CGFloat(50)
                }
            }
            describe("should change the height") {
                it("CGSize(width: 500, height: 1000).scaledSize(CGSize(width: 1000, height: 100))") {
                    let initial = CGSize(width: 500, height: 1000)
                    let maxSize = CGSize(width: 1000, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(50)
                    expect(subject.height) == CGFloat(100)
                }
            }
            describe("should change the width and height") {
                it("CGSize(width: 1000, height: 1000).scaledSize(CGSize(width: 500, height: 100))") {
                    let initial = CGSize(width: 1000, height: 1000)
                    let maxSize = CGSize(width: 500, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(100)
                    expect(subject.height) == CGFloat(100)
                }
                it("CGSize(width: 1000, height: 1000).scaledSize(CGSize(width: 100, height: 500))") {
                    let initial = CGSize(width: 1000, height: 1000)
                    let maxSize = CGSize(width: 500, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(100)
                    expect(subject.height) == CGFloat(100)
                }
                it("CGSize(width: 1000, height: 1000).scaledSize(CGSize(width: 100, height: 100))") {
                    let initial = CGSize(width: 1000, height: 1000)
                    let maxSize = CGSize(width: 500, height: 100)
                    let subject = initial.scaledSize(maxSize)
                    expect(subject.width) == CGFloat(100)
                    expect(subject.height) == CGFloat(100)
                }
            }
        }
    }
}
