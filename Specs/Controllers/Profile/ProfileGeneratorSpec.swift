////
///  ProfileGeneratorSpec.swift
//

@testable import Ello
import Quick
import Nimble

class ProfileGeneratorSpec: QuickSpec {

    class MockProfileDestination: StreamDestination {
        var placeholderItems: [StreamCellItem] = []
        var headerItems: [StreamCellItem] = []
        var postItems: [StreamCellItem] = []
        var otherPlaceholderLoaded = false
        var user: User?
        var responseConfig: ResponseConfig?
        var pagingEnabled: Bool = false

        func setPlaceholders(items: [StreamCellItem]) {
            placeholderItems = items
        }

        func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping ElloEmptyCompletion) {
            switch type {
            case .profileHeader:
                headerItems = items
            case .profilePosts:
                postItems = items
            default:
                otherPlaceholderLoaded = true
            }
        }

        func setPrimary(jsonable: JSONAble) {
            guard let user = jsonable as? User else { return }
            self.user = user
        }

        func primaryJSONAbleNotFound() {
        }

        func setPagingConfig(responseConfig: ResponseConfig) {
            self.responseConfig = responseConfig
        }
    }

    override func spec() {
        describe("ProfileGenerator") {
            var destination: MockProfileDestination!
            var currentUser: User!
            var streamKind: StreamKind!
            var subject: ProfileGenerator!

            beforeEach {
                destination = MockProfileDestination()
                currentUser = User.stub(["id": "42"])
                streamKind = .currentUserStream
                subject = ProfileGenerator(
                    currentUser: currentUser,
                    userParam: "42",
                    user: currentUser,
                    streamKind: streamKind,
                    destination: destination
                )
            }

            describe("load()") {

                it("sets 2 placeholders") {
                    subject.load()
                    expect(destination.placeholderItems.count) == 2
                }

                it("replaces only ProfileHeader and ProfilePosts") {
                    subject.load()
                    expect(destination.headerItems.count) > 0
                    expect(destination.postItems.count) > 0
                    expect(destination.otherPlaceholderLoaded) == false
                }

                it("sets the primary jsonable") {
                    subject.load()
                    expect(destination.user).toNot(beNil())
                }

                it("sets the config response") {
                    subject.load()
                    expect(destination.responseConfig).toNot(beNil())
                }
            }
        }
    }
}
