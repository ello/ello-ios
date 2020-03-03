////
///  SimpleStreamViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class SimpleStreamViewControllerSpec: QuickSpec {
    override func spec() {

        var subject: SimpleStreamViewController!
        beforeEach {
            subject = SimpleStreamViewController(
                endpoint: ElloAPI.userStreamFollowers(userId: "666"),
                title: "Followers"
            )
        }

        describe("SimpleStreamViewController") {
            it("sets the title") {
                expect(subject.title) == "Followers"
            }
        }
    }
}
