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

            describe("userProfileItems()") {
                describe("should show badges and total count") {
                    it("when badges count is gt zero and total count is zero") {
                        let user: User = stub([
                            "badges": ["featured"],
                            "totalViewsCount": 0
                            ])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.any { $0.type == .profileHeaderTotalAndBadges }).to(be(true), description: "has .profileHeaderTotalAndBadges")
                    }

                    it("when badges count is zero and total count is gt zero") {
                        let user: User = stub([
                            "badges": [String](),
                            "totalViewsCount": 1
                            ])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.any { $0.type == .profileHeaderTotalAndBadges }).to(be(true), description: "has .profileHeaderTotalAndBadges")
                    }
                }

                describe("should not show badges and total count") {
                    it("when badges count is zero and total count is zero") {
                        let user: User = stub([
                            "badges": [String](),
                            "totalViewsCount": 0
                            ])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.all { $0.type != .profileHeaderTotalAndBadges }).to(be(true), description: "does not have .profileHeaderTotalAndBadges")
                    }
                }

                describe("should show bio") {
                    it("when bio is not empty") {
                        let user: User = stub([
                            "formattedShortBio": "not empty",
                            ])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.any { $0.type == .profileHeaderBio }).to(be(true), description: "has .profileHeaderBio")
                    }
                }

                describe("should not show bio") {
                    it("when bio is empty") {
                        let user: User = stub([
                            "formattedShortBio": "",
                            ])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.all { $0.type != .profileHeaderBio }).to(be(true), description: "does not have .profileHeaderBio")
                    }

                    it("when bio is nil") {
                        let user: User = stub([:])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.all { $0.type != .profileHeaderBio }).to(be(true), description: "does not have .profileHeaderBio")
                    }
                }

                describe("should show location") {
                    it("when location is not empty") {
                        let user: User = stub([
                            "location": "not empty",
                            ])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.any { $0.type == .profileHeaderLocation }).to(be(true), description: "has .profileHeaderLocation")
                    }
                }

                describe("should not show location") {
                    it("when location is empty") {
                        let user: User = stub([
                            "location": "",
                            ])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.all { $0.type != .profileHeaderLocation }).to(be(true), description: "does not have .profileHeaderLocation")
                    }

                    it("when location is nil") {
                        let user: User = stub([:])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.all { $0.type != .profileHeaderLocation }).to(be(true), description: "does not have .profileHeaderLocation")
                    }
                }

                describe("should show links") {
                    it("when links is not empty") {
                        let user: User = stub([
                            "externalLinksList": ["http://not.empty"],
                            ])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.any { $0.type == .profileHeaderLinks }).to(be(true), description: "has .profileHeaderLinks")
                    }
                }

                describe("should not show links") {
                    it("when links is empty") {
                        let user: User = stub([
                            "externalLinksList": [String](),
                            ])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.all { $0.type != .profileHeaderLinks }).to(be(true), description: "does not have .profileHeaderLinks")
                    }

                    it("when links is nil") {
                        let user: User = stub([:])
                        let items = subject.userProfileItems(user)
                        expect(items.any { $0.type == .profileHeaderAvatar }).to(be(true), description: "has .profileHeaderAvatar")
                        expect(items.any { $0.type == .profileHeaderName }).to(be(true), description: "has .profileHeaderName")
                        expect(items.any { $0.type == .profileHeaderStats }).to(be(true), description: "has .profileHeaderStats")
                        expect(items.all { $0.type != .profileHeaderLinks }).to(be(true), description: "does not have .profileHeaderLinks")
                    }
                }
            }

            describe("parse(_, streamKind:)") {

                it("sets collapsed and non collapsed state") {
                    let posts: [Post] = (1 ... 10).map { index in
                        return Post.stub([
                            "contentWarning": index % 2 == 0 ? "" : "NSFW",
                            ])
                    }

                    let cellItems = StreamCellItemParser().parse(posts, streamKind: .following)
                    for item in cellItems {
                        guard let post = item.jsonable as? Post else { fail("this should be a post") ; break }

                        if item.type == .streamFooter {
                            expect(item.state) == StreamCellState.none
                        }
                        else if post.isCollapsed {
                            expect(item.state) == StreamCellState.collapsed
                        }
                        else {
                            expect(item.state) == StreamCellState.expanded
                        }
                    }
                }

                context("parsing a post") {
                    let zeroPosts = [Post]()
                    let twoPosts = [
                        Post.stub(["content": [TextRegion.stub(["content": "<p>post 1</p>"])]]),
                        Post.stub(["content": [TextRegion.stub(["content": "<p>post 2</p>"])]]),
                    ]
                    let oneRepost = [
                        Post.stub([
                            "content": [TextRegion](),
                            "repostContent": [TextRegion.stub(["content": "<p>repost</p>"])],
                            "summary": [TextRegion.stub(["content": "<p>repost summary</p>"])],
                            ]),
                    ]

                    it("returns an empty array if an empty array of Posts is passed in") {
                        let cellItems = subject.parse(zeroPosts, streamKind: .following)
                        expect(cellItems.count) == 0
                    }

                    it("normal post") {
                        let cellItems = subject.parse(twoPosts, streamKind: .following)
                        let actualTypes = cellItems.map { $0.type }
                        let expectedTypes: [StreamCellType] = [
                            .streamHeader,
                            .text(data: TextRegion(content: "<p>post 1</p>")),
                            .streamFooter,
                            .spacer(height: 10),
                            .streamHeader,
                            .text(data: TextRegion(content: "<p>post 2</p>")),
                            .streamFooter,
                            .spacer(height: 10),
                        ]
                        expect(actualTypes) == expectedTypes
                    }

                    it("repost in list view") {
                        StreamKind.following.setIsGridView(false)
                        let cellItems = subject.parse(oneRepost, streamKind: .following)
                        let actualTypes = cellItems.map { $0.type }
                        let expectedTypes: [StreamCellType] = [
                            .streamHeader,
                            .text(data: TextRegion(content: "<p>repost</p>")),
                            .streamFooter,
                            .spacer(height: 10),
                        ]
                        expect(actualTypes) == expectedTypes
                    }

                    it("repost in grid view") {
                        StreamKind.following.setIsGridView(true)
                        let cellItems = subject.parse(oneRepost, streamKind: .following)
                        let actualTypes = cellItems.map { $0.type }
                        let expectedTypes: [StreamCellType] = [
                            .streamHeader,
                            .text(data: TextRegion(content: "<p>repost summary</p>")),
                            .streamFooter,
                            .spacer(height: 10),
                        ]
                        expect(actualTypes) == expectedTypes
                    }

                    it("doesn't include user's own post headers on a profile stream") {
                        let cellItems = subject.parse(twoPosts, streamKind: .userStream(userParam: "42"))
                        let header = cellItems.find { $0.type == .streamHeader }
                        expect(header).to(beNil())
                    }
                }

                it("returns an empty array if an empty array of Activities is passed in") {
                    let activities: [Ello.Notification] = []
                    expect(subject.parse(activities, streamKind: .notifications(category: nil)).count) == 0
                }

                it("returns an array with the proper count of stream cell items when parsing friends.json's activities") {
                    var loadedNotifications = [StreamCellItem]()
                    StreamService().loadStream(endpoint: .notificationsStream(category: nil))
                        .done { response in
                            if case let .jsonables(jsonables, _) = response {
                                loadedNotifications = subject.parse(jsonables, streamKind: .notifications(category: nil))
                            }
                        }
                        .catch { _ in }
                    expect(loadedNotifications.count) == 14
                }
            }

            describe("regionStreamCells") {
                it("should return images") {
                    let region = ImageRegion.stub([:])
                    let streamCellTypes = subject.regionStreamCells(region)
                    expect(streamCellTypes.count) == 1
                    if let streamCellType = streamCellTypes.first {
                        if case .image(_) = streamCellType {
                            expect(true) == true
                        }
                        else {
                            fail("wrong cell type \(streamCellType)")
                        }
                    }
                }

                it("should return embeds") {
                    let region = EmbedRegion.stub([:])
                    let streamCellTypes = subject.regionStreamCells(region)
                    expect(streamCellTypes.count) == 1
                    if let streamCellType = streamCellTypes.first {
                        if case .embed(_) = streamCellType {
                            expect(true) == true
                        }
                        else {
                            fail("wrong cell type \(streamCellType)")
                        }
                    }
                }

                it("should return simple text") {
                    let content = "<p>text</p>"
                    let region = TextRegion.stub([
                        "content": content
                        ])
                    let streamCellTypes = subject.regionStreamCells(region)
                    expect(streamCellTypes.count) == 1
                    if let streamCellType = streamCellTypes.first {
                        if case let .text(data) = streamCellType, let textRegion = data as? TextRegion {
                            expect(textRegion.content) == content
                        }
                        else {
                            fail("wrong cell type \(streamCellType)")
                        }
                    }
                }

                it("should split paragraphs") {
                    let content1 = "<p>text1</p>"
                    let content2 = "<p>text2</p>"
                    let region = TextRegion.stub([
                        "content": content1 + content2
                        ])
                    let streamCellTypes = subject.regionStreamCells(region)
                    expect(streamCellTypes.count) == 2
                    if case let .text(data) = streamCellTypes[0], let textRegion = data as? TextRegion {
                        expect(textRegion.content) == content1
                    }
                    else {
                        fail("wrong cell type \(streamCellTypes[0])")
                    }

                    if case let .text(data) = streamCellTypes[1], let textRegion = data as? TextRegion {
                        expect(textRegion.content) == content2
                    }
                    else {
                        fail("wrong cell type \(streamCellTypes[1])")
                    }
                }

                it("should not split break tags") {
                    let content1 = "text1"
                    let content2 = "text2"
                    let region = TextRegion.stub([
                        "content": "<p>\(content1)<br>\(content2)</p>"
                        ])
                    let streamCellTypes = subject.regionStreamCells(region)
                    expect(streamCellTypes.count) == 1
                    if case let .text(data) = streamCellTypes[0], let textRegion = data as? TextRegion {
                        expect(textRegion.content) == region.content
                    }
                    else {
                        fail("wrong cell type \(streamCellTypes[0])")
                    }
                }

                it("should truncate ridiculous text") {
                    let region = TextRegion.stub([
                        "content": "<p>" + String(repeating: "a", count: 8000) + "</p>"
                        ])
                    let streamCellTypes = subject.regionStreamCells(region)
                    expect(streamCellTypes.count) == 1
                    if case let .text(data) = streamCellTypes[0], let textRegion = data as? TextRegion {
                        expect(textRegion.content).to(beginWith("<p>aaaaa"))
                        expect(textRegion.content).to(endWith("&hellip;</p>"))
                    }
                    else {
                        fail("wrong cell type \(streamCellTypes[0])")
                    }
                }
            }
        }
    }
}
