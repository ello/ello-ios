////
///  NotificationsGeneratorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class NotificationsGeneratorSpec: QuickSpec {

    class MockNotificationsDestination: StreamDestination {
        var placeholderItems: [StreamCellItem] = []
        var announcementItems: [StreamCellItem] = []
        var notificationItems: [StreamCellItem] = []
        var otherPlaceholderLoaded = false
        var responseConfig: ResponseConfig?
        var pagingEnabled: Bool = false

        func setPlaceholders(items: [StreamCellItem]) {
            placeholderItems = items
        }

        func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping ElloEmptyCompletion) {
            switch type {
            case .announcements:
                announcementItems = items
            case .notifications:
                notificationItems = items
            default:
                otherPlaceholderLoaded = true
            }
        }

        func setPrimary(jsonable: JSONAble) {
        }

        func primaryJSONAbleNotFound() {
        }

        func setPagingConfig(responseConfig: ResponseConfig) {
            self.responseConfig = responseConfig
        }
    }

    override func spec() {
        describe("NotificationsGenerator") {
            var destination: MockNotificationsDestination!
            var currentUser: User!
            var streamKind: StreamKind!
            var subject: NotificationsGenerator!

            beforeEach {
                destination = MockNotificationsDestination()
                currentUser = User.stub(["id": "42"])
                streamKind = .notifications(category: nil)
                subject = NotificationsGenerator(
                    currentUser: currentUser,
                    streamKind: streamKind,
                    destination: destination
                )
            }

            describe("load()") {

                it("sets 2 placeholders") {
                    subject.load()
                    expect(destination.placeholderItems.count) == 2
                }

                it("replaces only Announcements and Notifications") {
                    subject.load()
                    expect(destination.announcementItems.count) > 0
                    expect(destination.notificationItems.count) > 0
                    expect(destination.otherPlaceholderLoaded) == false
                }

                it("sets the config response") {
                    subject.load()
                    expect(destination.responseConfig).toNot(beNil())
                }
            }

            describe("reloadAnnouncements()") {
                it("does not trigger when identical announcements are found") {
                    ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                    subject.load()
                    let prevItems = destination.announcementItems
                    subject.reloadAnnouncements()
                    expect(destination.announcementItems) == prevItems
                }
            }
        }
    }
}
