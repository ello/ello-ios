////
///  SimpleStreamViewControllerSpec.swift
//

@testable import Ello
import Foundation
import Quick
import Nimble


class SimpleStreamViewControllerSpec: QuickSpec {
    override func spec() {

        var subject: SimpleStreamViewController!
        beforeEach {
            subject = SimpleStreamViewController(endpoint: ElloAPI.userStreamFollowers(userId: "666"), title: "Followers")
        }

        describe("initialization") {

            it("can be instantiated") {
                expect(subject).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(subject).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a StreamableViewController") {
                expect(subject).to(beAKindOf(StreamableViewController.self))
            }

            it("is a SimpleStreamViewController") {
                expect(subject).to(beAKindOf(SimpleStreamViewController.self))
            }

            it("sets the title") {
                expect(subject.title) == "Followers"
            }
        }
    }
}
