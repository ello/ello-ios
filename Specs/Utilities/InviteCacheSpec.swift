////
///  InviteControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class InviteCacheSpec: QuickSpec {
    override func spec() {
        beforeEach {
            GroupDefaults["ElloInviteCache"] = ["contact"]
        }
        describe("saveInvite") {
            it("saves the contact id to the cache") {
                var inviteCache = InviteCache()
                inviteCache.saveInvite("contact id")
                let invites = GroupDefaults["ElloInviteCache"].array as? [String]
                expect(invites?.last) == "contact id"
            }
        }

        describe("has") {
            context("'contact' has been saved") {
                it("returns true") {
                    let inviteCache = InviteCache()
                    expect(inviteCache.has("contact")).to(beTrue())
                }
            }

            context("'made up' has not been saved") {
                it("returns false") {
                    let inviteCache = InviteCache()
                    expect(inviteCache.has("'made up'")).to(beFalse())
                }
            }
        }
    }
}
