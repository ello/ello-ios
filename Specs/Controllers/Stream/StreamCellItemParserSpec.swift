////
///  StreamCellItemParserSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class StreamCellItemParserSpec: QuickSpec {
    override func spec() {
        describe("StreamCellItemParser") {

            var subject: StreamCellItemParser!
            beforeEach {
                subject = StreamCellItemParser()
            }

            describe("-streamCellItems:") {

                it("returns an empty array if an empty array of Posts is passed in") {
                    let posts = [Post]()
                    expect(subject.parse(posts, streamKind: .following).count) == 0
                }

                it("returns an empty array if an empty array of Comments is passed in") {
                    let comments = [ElloComment]()
                    expect(subject.parse(comments, streamKind: .following).count) == 0
                }

                it("returns an array with the proper count of stream cell items when parsing friends.json's posts") {
                    var cellItems = [StreamCellItem]()
                    StreamService().loadStream(endpoint: .following)
                        .onSuccess { response in
                            if case let .jsonables(jsonables, responseConfig)) = response {
                                cellItems = subject.parse(jsonables, streamKind: .following)
                            }
                        }
                        .onFail { _ in }
                    expect(cellItems.count) == 8
                }

                it("doesn't include user's own post headers on a profile stream") {
                    var cellItems = [StreamCellItem]()
                    StreamService().loadStream(endpoint: .following)
                        .onSuccess { response in
                            if case let .jsonables(jsonables, responseConfig)) = response {
                                cellItems = subject.parse(jsonables, streamKind: .userStream(userParam: "42"))
                            }
                        }
                        .onFail { _ in }
                    let header = cellItems.find { $0.type == .header }
                    expect(header).to(beNil())
                }

                it("returns an empty array if an empty array of Activities is passed in") {
                    let activities: [Ello.Notification] = []
                    expect(subject.parse(activities, streamKind: .notifications(category: nil)).count) == 0
                }

                it("returns an array with the proper count of stream cell items when parsing friends.json's activities") {
                    var loadedNotifications = [StreamCellItem]()
                    StreamService().loadStream(endpoint: .notificationsStream(category: nil))
                        .onSuccess { response in
                            if case let .jsonables(jsonables, responseConfig)) = response {
                                loadedNotifications = subject.parse(jsonables, streamKind: .notifications(category: nil))
                            }
                        }
                        .onFail { _ in }
                    expect(loadedNotifications.count) == 14
                }
            }
        }
    }
}
