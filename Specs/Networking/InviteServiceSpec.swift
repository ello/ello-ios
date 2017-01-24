////
///  InviteServiceSpec.swift
//

@testable import Ello
import Quick
import Moya
import Nimble


class InviteServiceSpec: QuickSpec {
    struct FakeAddressBook: AddressBookProtocol {
        var localPeople: [LocalPerson]

        init(_ people: [String: [String]]) {
            localPeople = people.map { id, emails in
                return LocalPerson(name: "\(id)", emails: emails, id: id)
            }
        }
    }

    override func spec() {
        describe("-invite:success:failure:") {

            let subject = InviteService()

            it("succeeds") {
                var loadedSuccessfully = false
                subject.invite("test@nowhere.test", success: {
                    loadedSuccessfully = true
                    }, failure: { _ in })

                expect(loadedSuccessfully) == true
            }

            it("fails") {
                ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                var loadedSuccessfully = true
                subject.invite("test@nowhere.test", success: {
                    loadedSuccessfully = true
                }, failure: { (error, statusCode) in
                    loadedSuccessfully = false
                })

                expect(loadedSuccessfully) == false
            }
        }

        describe("-find:success:failure:") {

            let subject = InviteService()

            it("succeeds") {
                var expectedUsers: [(LocalPerson, User?)] = []
                let addressBook = FakeAddressBook(["1": ["blah"], "2": ["blah"]])
                subject.find(addressBook, currentUser: nil, success: {
                    users in
                    expectedUsers = users
                }, failure: { _ in })

                expect(expectedUsers.count) == 2
            }

            it("fails") {
                ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                var loadedSuccessfully = true

                let addressBook = FakeAddressBook(["1": ["blah"], "2": ["blah"]])
                subject.find(addressBook, currentUser: nil, success: {
                    users in
                    loadedSuccessfully = true
                }, failure: { (error, statusCode) in
                    loadedSuccessfully = false
                })

                expect(loadedSuccessfully) == false
            }
        }
    }
}
