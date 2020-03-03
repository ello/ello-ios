////
///  DrawerViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class DrawerViewControllerSpec: QuickSpec {
    override func spec() {
        describe("DrawerViewController") {
            describe("snapshots") {
                validateAllSnapshots(named: "DrawerViewController") {
                    return DrawerViewController()
                }
            }
        }
    }
}
