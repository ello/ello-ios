////
///  ColorsSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ColorsSpec: QuickSpec {
    override func spec() {

        describe("color methods") {
            it("+grey231F20") {
                expect(UIColor.grey231F20()).to(beAKindOf(UIColor.self))
            }
            it("+grey3") {
                expect(UIColor.grey3()).to(beAKindOf(UIColor.self))
            }
            it("+grey4D") {
                expect(UIColor.grey4D()).to(beAKindOf(UIColor.self))
            }
            it("+grey6") {
                expect(UIColor.grey6()).to(beAKindOf(UIColor.self))
            }
            it("+greyA") {
                expect(UIColor.greyA()).to(beAKindOf(UIColor.self))
            }
            it("+greyE5") {
                expect(UIColor.greyE5()).to(beAKindOf(UIColor.self))
            }
            it("+greyF1") {
                expect(UIColor.greyF1()).to(beAKindOf(UIColor.self))
            }
            it("+yellowFFFFCC") {
                expect(UIColor.yellowFFFFCC()).to(beAKindOf(UIColor.self))
            }
            it("+redFFCCCC") {
                expect(UIColor.redFFCCCC()).to(beAKindOf(UIColor.self))
            }
        }
    }
}
