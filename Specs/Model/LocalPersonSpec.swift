@testable import Ello
import Quick
import Nimble


class LocalPersonSpec: QuickSpec {
    override func spec() {
        describe("identifier") {
            it("returns the id string") {
                let person = LocalPerson(name: "Test", emails: [], id: "123")
                expect(person.identifier) == "123"
            }
        }

        describe("emails") {
            it("returns an array of emails") {
                let emails = ["tester@test.com", "coolemail@bro.com"]
                let person = LocalPerson(name: "", emails: emails, id: "123")
                expect(person.emails) == emails
            }
        }
    }
}
