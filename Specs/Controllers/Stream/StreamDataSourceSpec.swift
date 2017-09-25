////
///  StreamDataSourceSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya

class FakeCollectionView: ElloCollectionView {

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        updates?()
        completion?(true)
    }

    override func insertItems(at indexPaths: [IndexPath]) {
        // noop
    }

    override func deleteItems(at indexPaths: [IndexPath]) {
        // noop
    }

    override func reloadItems(at indexPaths: [IndexPath]) {
        // noop
    }
}

class StreamDataSourceSpec: QuickSpec {

    override func spec() {
        let indexPath0 = IndexPath(item: 0, section: 0)
        let indexPath1 = IndexPath(item: 1, section: 0)
        let indexPathOutOfBounds = IndexPath(item: 1000, section: 0)
        let indexPathInvalidSection = IndexPath(item: 0, section: 10)

        var streamViewController: StreamViewController!
        var subject: StreamDataSource!

        beforeEach {
            StreamKind.following.setIsGridView(true)

            subject = StreamDataSource(streamKind: .following)
            subject.textSizeCalculator = FakeStreamTextCellSizeCalculator(webView: ElloWebView())
            subject.notificationSizeCalculator = FakeStreamNotificationCellSizeCalculator(webView: ElloWebView())
            subject.announcementSizeCalculator = FakeAnnouncementCellSizeCalculator()
            subject.profileHeaderSizeCalculator = FakeProfileHeaderCellSizeCalculator()

            streamViewController = StreamViewController()
            streamViewController.streamKind = .following
            streamViewController.dataSource = subject

            showController(streamViewController)
        }

        describe("StreamDataSourceSpec") {
            context("appendStreamCellItems(_:)") {
                let post = Post.stub([:])
                let cellItems = [
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:])))
                ]

                beforeEach {
                    subject.appendStreamCellItems(cellItems)
                }

                it("adds items") {
                    expect(subject.visibleCellItems.count) == cellItems.count
                }
                it("does not size the items") {
                    for item in cellItems {
                        expect(item.calculatedCellHeights.oneColumn).to(beNil())
                    }
                }
            }

            context("replacePlaceholder(type:items:)") {
                beforeEach {
                    subject.appendStreamCellItems([StreamCellItem(type: .placeholder, placeholderType: .streamPosts)])
                }
                it("replaces a placeholder with items") {
                    let newItems = [
                        StreamCellItem(type: .streamHeader),
                        StreamCellItem(type: .streamHeader),
                    ]
                    subject.replacePlaceholder(type: .streamPosts, items: newItems)
                    expect(subject.allStreamCellItems) == newItems
                }

                it("assigns the placeholderType to the new items") {
                    let newItems = [
                        StreamCellItem(type: .streamHeader),
                        StreamCellItem(type: .streamHeader),
                    ]
                    subject.replacePlaceholder(type: .streamPosts, items: newItems)
                    for item in subject.allStreamCellItems {
                        expect(item.placeholderType) == StreamCellType.PlaceholderType.streamPosts
                    }
                }

                it("restores a placeholder when replacing with zero items") {
                    let newItems = [
                        StreamCellItem(type: .streamHeader),
                        StreamCellItem(type: .streamHeader),
                    ]
                    subject.replacePlaceholder(type: .streamPosts, items: newItems)
                    expect(subject.allStreamCellItems.count) == 2

                    subject.replacePlaceholder(type: .streamPosts, items: [])
                    expect(subject.allStreamCellItems.count) == 1
                    expect(subject.allStreamCellItems[0].type) == StreamCellType.placeholder
                    expect(subject.allStreamCellItems[0].placeholderType) == StreamCellType.PlaceholderType.streamPosts
                }

                it("ignores replacements if the placeholder is not in the data source") {
                    let newItems = [
                        StreamCellItem(type: .streamHeader),
                        StreamCellItem(type: .streamHeader),
                    ]
                    subject.replacePlaceholder(type: .categoryList, items: newItems)

                    expect(subject.allStreamCellItems.count) == 1
                    expect(subject.allStreamCellItems[0].type) == StreamCellType.placeholder
                    expect(subject.allStreamCellItems[0].placeholderType) == StreamCellType.PlaceholderType.streamPosts
                }
            }

            context("insertStreamCellItems(_:, startingIndexPath:)") {
                let firstCellItems = [
                    StreamCellItem(type: .streamHeader),
                    StreamCellItem(type: .streamHeader),
                    StreamCellItem(type: .streamHeader),
                    StreamCellItem(type: .streamHeader),
                ]
                let secondCellItems = [
                    StreamCellItem(type: .streamHeader),
                    StreamCellItem(type: .streamHeader),
                    StreamCellItem(type: .streamHeader),
                    StreamCellItem(type: .streamHeader),
                ]

                beforeEach {
                    subject.appendStreamCellItems(secondCellItems)
                    subject.insertStreamCellItems(firstCellItems, startingIndexPath: indexPath0)
                }
                it("inserts items") {
                    expect(subject.allStreamCellItems) == (firstCellItems + secondCellItems)
                }
            }

            context("hasCellItems(for:)") {
                beforeEach {
                    subject.appendStreamCellItems([
                        StreamCellItem(type: .placeholder, placeholderType: .streamPosts),
                        StreamCellItem(jsonable: Post.stub([:]), type: .streamHeader, placeholderType: .postHeader),
                        StreamCellItem(jsonable: ElloComment.stub([:]), type: .streamHeader, placeholderType: .postComments),
                        StreamCellItem(jsonable: ElloComment.stub([:]), type: .streamHeader, placeholderType: .postComments),
                    ])
                }

                it("returns false if data doesn't include placeholderType") {
                    expect(subject.hasCellItems(for: .editorials)) == false
                }

                it("returns false if data only includes a placeholder item") {
                    expect(subject.hasCellItems(for: .streamPosts)) == false
                }

                it("returns true if data includes one item of placeholderType") {
                    expect(subject.hasCellItems(for: .postHeader)) == true
                }

                it("returns true if data includes more than one item of placeholderType") {
                    expect(subject.hasCellItems(for: .postComments)) == true
                }
            }

            context("isValidIndexPath(_:)") {
                beforeEach {
                    let item = StreamCellItem(jsonable: ElloComment.newCommentForPost(Post.stub([:]), currentUser: User.stub([:])), type: .createComment)
                    subject.appendStreamCellItems([item])
                }

                it("returns true for first row") {
                    expect(subject.isValidIndexPath(IndexPath(item: 0, section: 0))) == true
                }

                it("returns true for last row") {
                    let index = subject.visibleCellItems.count - 1
                    expect(subject.isValidIndexPath(IndexPath(item: index, section: 0))) == true
                }

                it("returns false for row before first") {
                    expect(subject.isValidIndexPath(IndexPath(item: -1, section: 0))) == false
                }

                it("returns false for row after last") {
                    let index = subject.visibleCellItems.count
                    expect(subject.isValidIndexPath(IndexPath(item: index, section: 0))) == false
                }

                it("returns false for invalid section") {
                    expect(subject.isValidIndexPath(IndexPath(item: 0, section: 1))) == false
                }
            }

            describe("indexPath(forItem:)") {
                var postItem: StreamCellItem!
                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Post.stub([:])], streamKind: .following)
                    postItem = cellItems[0]
                    subject.appendStreamCellItems(cellItems)
                }

                it("returns an indexPath") {
                    expect(subject.indexPath(forItem: postItem)).notTo(beNil())
                }

                it("returns nil when cell doesn't exist") {
                    let anyItem = StreamCellItem(type: .seeMoreComments)
                    expect(subject.indexPath(forItem: anyItem)).to(beNil())
                }

                it("returns the correct indexPath for same StreamCellItem Placeholder Types") {
                    let testItem = StreamCellItem(type: .placeholder)
                    testItem.placeholderType = .postHeader
                    let testItem2 = StreamCellItem(type: .placeholder)
                    testItem2.placeholderType = .postHeader

                    subject.removeAllCellItems()
                    subject.appendStreamCellItems([testItem])

                    // this is actually a test of StreamCellItem.==, but since
                    // we don't have StreamCellItemSpec.swift, this is as good a
                    // place as any to test it.
                    let item = subject.indexPath(forItem: testItem2)?.item
                    expect(item) == 0
                }

                it("returns nil for StreamCellItem placeholders that are not the same placeholderType") {
                    let testItem = StreamCellItem(type: .placeholder)
                    testItem.placeholderType = .postHeader
                    let testItem2 = StreamCellItem(type: .placeholder)
                    testItem2.placeholderType = .categoryList

                    subject.appendStreamCellItems([testItem])

                    expect(subject.indexPath(forItem: testItem2)).to(beNil())
                }
            }

            describe("indexPaths(forPlaceholderType:)") {

                beforeEach {
                    let user = User.stub([:])

                    let profileHeaderItems = [
                        StreamCellItem(jsonable: user, type: .profileHeader, placeholderType: .profileHeader),
                        StreamCellItem(jsonable: user, type: .fullWidthSpacer(height: 5), placeholderType: .profileHeader),
                    ]

                    let postItems = [
                        StreamCellItem(type: .streamHeader, placeholderType: .streamPosts),
                        StreamCellItem(type: .streamFooter, placeholderType: .streamPosts),
                    ]

                    subject.appendStreamCellItems(profileHeaderItems + postItems)
                }

                it("returns the correct indexPaths for profile header") {
                    let headerIndexPaths = subject.indexPaths(forPlaceholderType: .profileHeader)

                    expect(headerIndexPaths[0].item) == 0
                    expect(headerIndexPaths[1].item) == 1
                }

                it("returns the correct indexPaths for profile posts") {
                    let postIndexPaths = subject.indexPaths(forPlaceholderType: .streamPosts)

                    expect(postIndexPaths[0].item) == 2
                    expect(postIndexPaths[1].item) == 3
                }
            }

            describe("post(at:)") {

                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Post.stub([:])], streamKind: .following)
                    subject.appendStreamCellItems(cellItems)
                }

                it("returns a post") {
                    expect(subject.post(at: indexPath0)).to(beAKindOf(Post.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.post(at: indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.post(at: indexPathInvalidSection)).to(beNil())
                }
            }

            describe("imageAsset(at:)") {

                beforeEach {
                    let asset = Asset.stub([:])
                    let region = ImageRegion.stub(["asset": asset])
                    let post = Post.stub([
                        "summary": [region],
                        "content": [region],
                        ])
                    let cellItems = StreamCellItemParser().parse([post], streamKind: .following)
                    subject.appendStreamCellItems(cellItems)
                }

                it("returns an image asset") {
                    expect(subject.imageAsset(at: IndexPath(item: 1, section: 0))).to(beAKindOf(Asset.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.imageAsset(at: indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.imageAsset(at: indexPathInvalidSection)).to(beNil())
                }
            }

            describe("comment(at:)") {

                beforeEach {
                    let cellItems = StreamCellItemParser().parse([ElloComment.stub([:])], streamKind: .following)
                    subject.appendStreamCellItems(cellItems)
                }

                it("returns a comment") {
                    expect(subject.comment(at: indexPath0)).to(beAKindOf(ElloComment.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.comment(at: indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.comment(at: indexPathInvalidSection)).to(beNil())
                }
            }

            describe("cellItems(for:)") {

                beforeEach {
                    let parser = StreamCellItemParser()
                    let postCellItems = parser.parse([Post.stub(["id": "666"])], streamKind: .following)
                    let commentCellItems = parser.parse([ElloComment.stub(["parentPostId": "666"]), ElloComment.stub(["parentPostId": "666"])], streamKind: .following)
                    let otherPostCellItems = parser.parse([Post.stub(["id": "777"])], streamKind: .following)
                    let cellItems = postCellItems + commentCellItems + otherPostCellItems
                    subject.appendStreamCellItems(cellItems)
                }

                it("returns an array of StreamCellItems") {
                    let post = subject.post(at: indexPath0)!
                    let items = subject.cellItems(for: post)
                    expect(items.count) == 4
                    for item in subject.visibleCellItems {
                        if items.contains(item) {
                            let itemPost = item.jsonable as! Post
                            expect(itemPost.id) == post.id
                        }
                        else {
                            if let itemPost = item.jsonable as? Post {
                                expect(itemPost.id) != post.id
                            }
                        }
                    }
                }

                it("returns empty array if post not found") {
                    let randomPost: Post = stub(["id": "notfound"])
                    let items = subject.cellItems(for: randomPost)
                    expect(items.count) == 0
                }

                it("does not return cell items for other posts") {
                    let lastItem = subject.visibleCellItems.count - 1
                    let post = subject.post(at: IndexPath(item: lastItem, section: 0))!
                    let items = subject.cellItems(for: post)
                    expect(post.id) == "777"
                    expect(items.count) == 4
                }

            }

            describe("user(at:)") {
                context("Returning a user-jsonable subject") {
                    beforeEach {
                        let userStreamKind = StreamKind.simpleStream(endpoint: ElloAPI.userStream(userParam: "42"), title: "yup")
                        let cellItems = StreamCellItemParser().parse([User.stub(["id": "42"])], streamKind: userStreamKind)
                        subject.appendStreamCellItems(cellItems)
                    }

                    it("returns a user") {
                        expect(subject.user(at: indexPath0)).to(beAKindOf(User.self))
                    }
                    it("returns user 42") {
                        if let user = subject.user(at: indexPath0) {
                            expect(user.id) == "42"
                        }
                    }

                    it("returns nil when out of bounds") {
                        expect(subject.user(at: indexPathOutOfBounds)).to(beNil())
                    }

                    it("returns nil when invalid section") {
                        expect(subject.user(at: indexPathInvalidSection)).to(beNil())
                    }
                }

                context("Returning an author subject") {
                    beforeEach {
                        let cellItems = StreamCellItemParser().parse([Post.stub(["author": User.stub(["id": "42"])])], streamKind: .following)
                        subject.appendStreamCellItems(cellItems)
                    }

                    it("returns a user") {
                        expect(subject.user(at: indexPath0)).to(beAKindOf(User.self))
                    }
                    it("returns user 42") {
                        if let user = subject.user(at: indexPath0) {
                            expect(user.id) == "42"
                        }
                    }

                    it("returns nil when out of bounds") {
                        expect(subject.user(at: indexPathOutOfBounds)).to(beNil())
                    }

                    it("returns nil when invalid section") {
                        expect(subject.user(at: indexPathInvalidSection)).to(beNil())
                    }
                }

                context("Returning a repostAuthor subject") {
                    beforeEach {
                        let repost = Post.stub([
                            "id": "\(self.index)",
                            "repostAuthor": User.stub(["id": "42"]),
                            "repostContent": [TextRegion.stub([:]), TextRegion.stub([:])],
                            "content": [TextRegion.stub([:]), TextRegion.stub([:])]
                            ])

                        let cellItems = StreamCellItemParser().parse([repost], streamKind: .following)
                        subject.appendStreamCellItems(cellItems)
                    }

                    it("returns a user") {
                        expect(subject.user(at: indexPath0)).to(beAKindOf(User.self))
                    }
                    it("returns user 42") {
                        if let user = subject.user(at: indexPath0) {
                            expect(user.id) == "42"
                        }
                    }

                    it("returns nil when out of bounds") {
                        expect(subject.user(at: indexPathOutOfBounds)).to(beNil())
                    }

                    it("returns nil when invalid section") {
                        expect(subject.user(at: indexPathInvalidSection)).to(beNil())
                    }
                }
            }

            describe("commentIndexPaths(forPost:)") {

                beforeEach {
                    var cellItems = [StreamCellItem]()
                    let parser = StreamCellItemParser()
                    // creates 4 cells
                    let post1CellItems = parser.parse([Post.stub(["id": "666"])], streamKind: .following)
                    cellItems = post1CellItems
                    // creates 4 cells 2x2
                    let comment1CellItems = parser.parse([ElloComment.stub(["parentPostId": "666"]), ElloComment.stub(["parentPostId": "666"])], streamKind: .following)
                    cellItems += comment1CellItems
                    // one cell
                    let seeMoreCellItem = StreamCellItem(jsonable: ElloComment.stub(["parentPostId": "666"]), type: .seeMoreComments)
                    cellItems.append(seeMoreCellItem)
                    // creates 4 cells
                    let post2CellItems = parser.parse([Post.stub(["id": "777"])], streamKind: .following)
                    cellItems += post2CellItems
                    // creates 2 cells
                    let comment2CellItems = parser.parse([ElloComment.stub(["parentPostId": "777"])], streamKind: .following)
                    cellItems += comment2CellItems
                    // creates 5 cells
                    let post3CellItems = parser.parse([Post.stub(["id": "888", "contentWarning": "NSFW"])], streamKind: .following)
                    cellItems += post3CellItems
                    // create 1 cell
                    let createCommentCellItem = StreamCellItem(jsonable: ElloComment.stub(["parentPostId": "888"]), type: .createComment)
                    cellItems.append(createCommentCellItem)
                    // creates 2 cells
                    let comment3CellItems = parser.parse([ElloComment.stub(["parentPostId": "888"])], streamKind: .following)
                    cellItems += comment3CellItems
                    subject.appendStreamCellItems(cellItems)
                }

                it("returns an array of comment index paths") {
                    let post = subject.post(at: indexPath0)
                    let indexPaths = subject.commentIndexPaths(forPost: post!)

                    expect(indexPaths.count) == 5
                    expect(indexPaths[0].item) == 4
                    expect(indexPaths[1].item) == 5
                    expect(indexPaths[2].item) == 6
                    expect(indexPaths[3].item) == 7
                    expect(indexPaths[4].item) == 8
                }

                it("does not return index paths for comments from another post") {
                    let post = subject.post(at: IndexPath(item: 9, section: 0))
                    let indexPaths = subject.commentIndexPaths(forPost: post!)

                    expect(indexPaths.count) == 2
                    expect(indexPaths[0].item) == 13
                    expect(indexPaths[1].item) == 14
                }

                it("returns an array of comment index paths when collapsed") {
                    let post = subject.post(at: IndexPath(item: 16, section: 0))
                    let indexPaths = subject.commentIndexPaths(forPost: post!)

                    expect(indexPaths.count) == 3
                    expect(indexPaths[0].item) == 19
                    expect(indexPaths[1].item) == 20
                    expect(indexPaths[2].item) == 21
                }
            }

            describe("footerIndexPath(forPost:)") {
                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Post.stub(["id": "456"])], streamKind: .following)
                    subject.appendStreamCellItems(cellItems)
                }

                it("returns the index path of the footer associated with this post") {
                    let post = subject.post(at: indexPath0)
                    let indexPath = subject.footerIndexPath(forPost: post!)

                    expect(indexPath!.item) == 2
                    expect(subject.visibleCellItems[indexPath!.item].type) == StreamCellType.streamFooter
                }
            }


            describe("clientSidePostInsertIndexPath()") {
                let user = User.stub(["id": "12345"])
                let zero = IndexPath(item: 0, section: 0)
                let two = IndexPath(item: 2, section: 0)
                let tests: [(IndexPath?, StreamKind)] = [
                    (nil, .discover(type: .featured)),
                    (nil, .category(slug: "art")),
                    (zero, .following),
                    (nil, .simpleStream(endpoint: ElloAPI.loves(userId: "12345"), title: "NA")),
                    (nil, .notifications(category: "")),
                    (nil, .postDetail(postParam: "param")),
                    (nil, .unknown),
                    (nil, .userStream(userParam: "NA")),
                    (nil, .simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat")),
                    (nil, .simpleStream(endpoint: ElloAPI.userStreamFollowers(userId: "54321"), title: "")),
                    (two, .userStream(userParam: user.id)),
                    (nil, .simpleStream(endpoint: ElloAPI.userStream(userParam: "54321"), title: "")),
                    ]
                for (indexPath, streamKind) in tests {
                    it("is \(String(describing: indexPath)) for \(streamKind)") {
                        subject.streamKind = streamKind
                        subject.currentUser = user

                        if indexPath == nil {
                            expect(subject.clientSidePostInsertIndexPath()).to(beNil())
                        }
                        else {
                            expect(subject.clientSidePostInsertIndexPath()) == indexPath
                        }
                    }
                }
            }

            describe("modifyItems(_:change:streamViewController:)") {

                context("with comments") {

                    let stubCommentCellItems: (_ commentsVisible: Bool) -> Void = { (commentsVisible: Bool) in
                        let parser = StreamCellItemParser()
                        let postCellItems = parser.parse([Post.stub(["id": "456"])], streamKind: .following)
                        let commentButtonCellItem = [StreamCellItem(jsonable: ElloComment.stub(["parentPostId": "456"]), type: .createComment)]
                        let commentCellItems = parser.parse([ElloComment.stub(["parentPostId": "456", "id": "111"])], streamKind: .following)
                        var cellItems = postCellItems
                        if commentsVisible {
                            cellItems = cellItems + commentButtonCellItem + commentCellItems
                        }
                        subject.appendStreamCellItems(cellItems)
                    }

                    describe(".create") {

                        it("inserts the new comment") {
                            stubCommentCellItems(true)
                            expect(subject.allStreamCellItems.count) == 7
                            streamViewController.performDataReload()

                            subject.modifyItems(ElloComment.stub(["id": "new_comment", "parentPostId": "456"]), change: .create, streamViewController: streamViewController)
                            expect(subject.allStreamCellItems.count) == 9
                            expect(subject.comment(at: IndexPath(item: 5, section: 0))!.id) == "new_comment"
                        }

                        it("doesn't insert the new comment") {
                            stubCommentCellItems(false)
                            expect(subject.allStreamCellItems.count) == 4
                            subject.modifyItems(ElloComment.stub(["id": "new_comment", "parentPostId": "456"]), change: .create, streamViewController: streamViewController)
                            expect(subject.allStreamCellItems.count) == 4
                        }

                    }

                    describe(".delete") {

                        it("removes the deleted comment") {
                            stubCommentCellItems(true)
                            expect(subject.allStreamCellItems.count) == 7
                            streamViewController.performDataReload()

                            subject.modifyItems(ElloComment.stub(["id": "111", "parentPostId": "456"]), change: .delete, streamViewController: streamViewController)
                            expect(subject.allStreamCellItems.count) == 5

                        }

                        it("doesn't remove the deleted comment") {
                            stubCommentCellItems(false)
                            expect(subject.allStreamCellItems.count) == 4
                            streamViewController.performDataReload()

                            subject.modifyItems(ElloComment.stub(["id": "111", "parentPostId": "456"]), change: .delete, streamViewController: streamViewController)
                            expect(subject.allStreamCellItems.count) == 4
                        }

                    }
                }

                context("with posts") {

                    beforeEach {
                        var posts = [Post]()
                        for index in 1...5 {
                            posts.append(Post.stub([
                                "id": "\(index)",
                                "commentsCount": 5,
                                "content": [TextRegion.stub([:])]
                                ])
                            )
                        }

                        let cellItems = StreamCellItemParser().parse(posts, streamKind: .following)
                        subject.appendStreamCellItems(cellItems)
                    }

                    describe(".create") {

                        context("StreamKind.following") {

                            it("inserts the new post at 1, 0") {
                                subject.streamKind = .following
                                expect(subject.allStreamCellItems.count) == 20
                                streamViewController.performDataReload()

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .create, streamViewController: streamViewController)
                                expect(subject.post(at: indexPath1)!.id) == "new_post"
                                expect(subject.allStreamCellItems.count) == 24
                            }

                        }

                        context("StreamKind.profile") {

                            it("inserts the new post at 4, 0") {
                                let currentUser = User.stub([:])
                                subject.currentUser = currentUser
                                subject.streamKind = .userStream(userParam: currentUser.id)
                                expect(subject.allStreamCellItems.count) == 20
                                streamViewController.performDataReload()

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .create, streamViewController: streamViewController)
                                expect(subject.post(at: indexPath0)!.id) == "1"
                                expect(subject.post(at: IndexPath(item: 4, section: 0))!.id) == "new_post"
                                expect(subject.allStreamCellItems.count) == 24
                            }

                        }

                        context("StreamKind.userStream") {

                            it("inserts the new post at 4, 0") {
                                subject.currentUser = User.stub(["id": "user-id-here"])
                                subject.streamKind = .userStream(userParam: "user-id-here")
                                expect(subject.allStreamCellItems.count) == 20
                                streamViewController.performDataReload()

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .create, streamViewController: streamViewController)

                                expect(subject.post(at: indexPath0)!.id) == "1"
                                expect(subject.post(at: IndexPath(item: 4, section: 0))!.id) == "new_post"
                                expect(subject.allStreamCellItems.count) == 24
                            }

                            it("does not insert a post in other user's profiles") {
                                subject.currentUser = User.stub(["id": "not-current-user-id-here"])
                                subject.streamKind = .userStream(userParam: "user-id-here")
                                expect(subject.allStreamCellItems.count) == 20
                                streamViewController.performDataReload()

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .create, streamViewController: streamViewController)
                                expect(subject.allStreamCellItems.count) == 20
                            }
                        }

                        context("StreamKind.loves") {

                            it("adds the newly loved post") {
                                subject.streamKind = .simpleStream(endpoint: .loves(userId: "fake-id"), title: "Loves")
                                let love: Love = stub(["id": "love1", "postId": "post1"])
                                expect(subject.allStreamCellItems.count) == 20
                                streamViewController.performDataReload()

                                subject.modifyItems(love, change: .create, streamViewController: streamViewController)
                                expect(subject.post(at: indexPath1)!.id) == "post1"
                                expect(subject.allStreamCellItems.count) == 24
                            }
                        }
                    }

                    describe(".delete") {

                        beforeEach {
                            subject.streamKind = .following
                        }

                        it("removes the deleted post") {
                            expect(subject.allStreamCellItems.count) == 20
                            streamViewController.performDataReload()

                            subject.modifyItems(Post.stub(["id": "1"]), change: .delete, streamViewController: streamViewController)
                            expect(subject.allStreamCellItems.count) == 16
                        }

                        it("doesn't remove the deleted comment") {
                            expect(subject.allStreamCellItems.count) == 20
                            streamViewController.performDataReload()

                            subject.modifyItems(Post.stub(["id": "not-present"]), change: .delete, streamViewController: streamViewController)
                            expect(subject.allStreamCellItems.count) == 20
                        }
                    }

                    describe(".update") {

                        beforeEach {
                            subject.streamKind = .following
                        }

                        it("updates the updated post") {
                            expect(subject.post(at: IndexPath(item: 4, section: 0))!.commentsCount) == 5
                            streamViewController.performDataReload()

                            subject.modifyItems(Post.stub(["id": "2", "commentsCount": 9]), change: .update, streamViewController: streamViewController)
                            expect(subject.post(at: IndexPath(item: 4, section: 0))!.commentsCount) == 9
                        }

                        it("doesn't update the updated post") {
                            subject.modifyItems(Post.stub(["id": "not-present", "commentsCount": 88]), change: .update, streamViewController: streamViewController)

                            for item in subject.allStreamCellItems {
                                // this check gets around the fact that there are spacers in posts
                                if let post = item.jsonable as? Post {
                                    expect(post.commentsCount) == 5
                                }
                            }
                        }

                        context("StreamKind.loves") {

                            beforeEach {
                                subject.streamKind = StreamKind.simpleStream(endpoint: ElloAPI.loves(userId: "fake-id"), title: "Loves")
                            }

                            it("removes the unloved post") {
                                expect(subject.allStreamCellItems.count) == 20
                                streamViewController.performDataReload()

                                subject.modifyItems(Post.stub(["id": "2", "commentsCount": 9, "loved": false]), change: .update, streamViewController: streamViewController)
                                expect(subject.allStreamCellItems.count) == 16
                            }
                        }
                    }
                }
            }

            describe("modifyUserRelationshipItems(_:streamViewController:)") {

                let stubCellItems: (_ streamKind: StreamKind) -> Void = { streamKind in
                    let user1: User = stub(["id": "user1"])
                    let post1: Post = stub(["id": "post1", "authorId": "user1"])
                    let post1Comment1: ElloComment = stub([
                        "parentPost": post1,
                        "id": "comment1",
                        "authorId": "user1"
                        ])
                    let post1Comment2: ElloComment = stub([
                        "parentPost": post1,
                        "id": "comment2",
                        "authorId": "user2"
                        ])
                    let parser = StreamCellItemParser()
                    let userCellItems = parser.parse([user1], streamKind: streamKind)
                    let post1CellItems = parser.parse([post1], streamKind: streamKind)
                    let post1CommentCellItems = parser.parse([post1Comment1, post1Comment2], streamKind: streamKind)
                    let cellItems = userCellItems + post1CellItems + post1CommentCellItems
                    subject.streamKind = streamKind
                    subject.appendStreamCellItems(cellItems)
                }

                describe("blocking a user") {

                    context("blocked user is the post author") {
                        it("removes blocked user, their post and all comments on that post") {
                            stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.following, title: "some title"))
                            expect(subject.allStreamCellItems.count) == 9
                            streamViewController.performDataReload()

                            subject.modifyUserRelationshipItems(User.stub(["id": "user1", "relationshipPriority": RelationshipPriority.block.rawValue]), streamViewController: streamViewController)
                            expect(subject.allStreamCellItems.count) == 0
                        }
                    }

                    context("blocked user is not the post author") {
                        it("removes blocked user's comments") {
                            stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.following, title: "some title"))
                            expect(subject.allStreamCellItems.count) == 9
                            streamViewController.performDataReload()

                            subject.modifyUserRelationshipItems(User.stub(["id": "user2", "relationshipPriority": RelationshipPriority.block.rawValue]), streamViewController: streamViewController)
                            expect(subject.allStreamCellItems.count) == 7
                        }
                    }

                    it("does not remove cells tied to other users") {
                        stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.following, title: "some title"))
                        expect(subject.allStreamCellItems.count) == 9
                        streamViewController.performDataReload()

                        subject.modifyUserRelationshipItems(User.stub(["id": "unrelated-user", "relationshipPriority": RelationshipPriority.block.rawValue]), streamViewController: streamViewController)
                        expect(subject.allStreamCellItems.count) == 9
                    }

                }

                describe("friending/noising/inactivating a user") {

                    it("updates posts from that user") {
                        stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.following, title: "some title"))
                        var user1 = subject.user(at: indexPath0)!
                        expect(user1.followersCount) == "stub-user-followers-count"
                        expect(user1.relationshipPriority.rawValue) == RelationshipPriority.none.rawValue
                        streamViewController.performDataReload()

                        subject.modifyUserRelationshipItems(User.stub(["id": "user1", "followersCount": "2", "followingCount": 2, "relationshipPriority": RelationshipPriority.following.rawValue]), streamViewController: streamViewController)
                        user1 = subject.user(at: indexPath0)!
                        expect(user1.followersCount) == "2"
                        expect(user1.relationshipPriority.rawValue) == RelationshipPriority.following.rawValue
                    }
                }

                describe("muting a user") {

                    beforeEach {
                        let streamKind: StreamKind = .notifications(category: nil)
                        let user1: User = stub(["id": "user1"])
                        let post1: Post = stub(["id": "post1", "authorId": "other-user"])
                        let activity1: Activity = stub(["id": "activity1", "subject": user1])
                        let activity2: Activity = stub(["id": "activity2", "subject": post1])
                        let parser = StreamCellItemParser()
                        let notificationCellItems = parser.parse([activity1, activity2], streamKind: streamKind)
                        subject.streamKind = streamKind
                        subject.appendStreamCellItems(notificationCellItems)
                    }

                    it("clears out notifications from that user when on notifications") {
                        expect(subject.allStreamCellItems.count) == 2
                        streamViewController.performDataReload()

                        subject.modifyUserRelationshipItems(User.stub(["id": "user1", "relationshipPriority": RelationshipPriority.mute.rawValue]), streamViewController: streamViewController)
                        expect(subject.allStreamCellItems.count) == 1
                    }
                }

            }

            describe("modifyUserSettingsItems(_:streamViewController:)") {

                let stubCellItems: (_ streamKind: StreamKind) -> Void = { streamKind in
                    let user1: User = stub(["id": "user1", "username": "sweet"])
                    let user2: User = stub(["id": "user2", "username": "unsweet"])
                    let userCellItems = StreamCellItemParser().parse([user1, user2], streamKind: streamKind)
                    let cellItems = userCellItems
                    subject.streamKind = streamKind
                    subject.appendStreamCellItems(cellItems)
                }

                context("modifies a user when it is the currentUser") {
                    it("removes blocked user, their post and all comments on that post") {
                        stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.following, title: "some title"))
                        expect(subject.user(at: indexPath0)!.username) == "sweet"
                        streamViewController.performDataReload()

                        subject.modifyUserSettingsItems(User.stub(["id": "user1", "username": "sweetness"]), streamViewController: streamViewController)
                        expect(subject.user(at: indexPath0)!.username) == "sweetness"
                    }
                }
            }

            describe("-removeComments(forPost:)") {
                var post: Post!
                beforeEach {
                    var items = [StreamCellItem]()
                    let parser = StreamCellItemParser()
                    post = Post.stub(["id": "666"])
                    items += parser.parse([post], streamKind: .following)
                    items.append(StreamCellItem(jsonable: ElloComment.newCommentForPost(post, currentUser: User.stub([:])), type: .createComment))
                    items += parser.parse([ElloComment.stub(["parentPostId": "666"]), ElloComment.stub(["parentPostId": "666"])], streamKind: .following)
                    items += parser.parse([Post.stub(["id": "777"])], streamKind: .following)
                    items += parser.parse([ElloComment.stub(["parentPostId": "777"])], streamKind: .following)

                    subject.appendStreamCellItems(items)
                }

                it("removes comment index paths") {
                    let indexPaths = subject.removeComments(forPost: post)

                    expect(indexPaths.count) > 0
                    expect(subject.commentIndexPaths(forPost: post)).to(beEmpty())
                }

            }

            describe("-updateHeight:at: ") {
                beforeEach {
                    var items = [StreamCellItem]()
                    let parser = StreamCellItemParser()
                    items += parser.parse([Post.stub(["id": "666", "content": [TextRegion.stub([:])]])], streamKind: .following)

                    subject.appendStreamCellItems(items)
                }

                it("updates the height of an existing StreamCellItem") {
                    let indexPath = IndexPath(item: 1, section: 0)
                    subject.updateHeight(at: indexPath, height: 256)

                    let cellItem = subject.streamCellItem(at: indexPath)
                    expect(cellItem!.calculatedCellHeights.oneColumn!) == 256
                    expect(cellItem!.calculatedCellHeights.multiColumn!) == 256
                }

                it("handles non-existent index paths") {
                    expect(subject.updateHeight(at: indexPathOutOfBounds, height: 256))
                        .notTo(raiseException())
                }

                it("handles invalid section") {
                    expect(subject.updateHeight(at: indexPathInvalidSection, height: 256))
                        .notTo(raiseException())
                }
            }

            describe("removeItems(at: [IndexPath])") {
                let post = Post.stub([:])
                let items = [
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:])))
                ]
                beforeEach {
                    subject.appendStreamCellItems(items)
                }
                it("sanity check") {
                    expect(items[0]) == items[0]
                    expect(items[0]) != items[1]
                    expect(items[1]) == items[1]
                    expect(items[1]) != items[2]
                    expect(items[2]) == items[2]
                    expect(items[2]) != items[3]
                    expect(items[3]) == items[3]
                    expect(items[3]) != items[0]
                }
                it("should allow removing items from the beginning") {
                    subject.removeItems(at: [indexPath0, indexPath1])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        expect(item) == items[index + 2]
                    }
                }
                it("should allow removing items from the beginning, reverse order") {
                    subject.removeItems(at: [indexPath1, indexPath0])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        expect(item) == items[index + 2]
                    }
                }
                it("should allow removing items from the end") {
                    subject.removeItems(at: [IndexPath(item: items.count - 2, section: 0), IndexPath(item: items.count - 1, section: 0)])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        expect(item) == items[index]
                    }
                }
                it("should allow removing items from the end, reverse order") {
                    subject.removeItems(at: [IndexPath(item: items.count - 1, section: 0), IndexPath(item: items.count - 2, section: 0)])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        expect(item) == items[index]
                    }
                }
                it("should allow removing items from the middle") {
                    subject.removeItems(at: [indexPath1, IndexPath(item: 2, section: 0)])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        if index == 0 {
                            expect(item) == items[index]
                        }
                        else {
                            expect(item) == items[index + 2]
                        }
                    }
                }
                it("should allow removing items from the middle, reverse order") {
                    subject.removeItems(at: [IndexPath(item: 2, section: 0), indexPath1])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        if index == 0 {
                            expect(item) == items[index]
                        }
                        else {
                            expect(item) == items[index + 2]
                        }
                    }
                }
                it("should ignore removing invalid index paths") {
                    subject.removeItems(at: [indexPathOutOfBounds])
                    expect(subject.visibleCellItems.count) == items.count
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        expect(item) == items[index]
                    }
                }
            }

            describe("removeAllCellItems()") {

                beforeEach {
                    var items = [StreamCellItem]()
                    items.append(StreamCellItem(jsonable: ElloComment.stub([:]), type: .createComment))

                    subject.appendStreamCellItems(items)
                }

                it("sets the number of visible cell items to 0") {
                    expect(subject.visibleCellItems.count) > 0
                    subject.removeAllCellItems()
                    expect(subject.visibleCellItems.count) == 0
                }

                it("sets the number of cell items to 0") {
                    expect(subject.allStreamCellItems.count) > 0
                    subject.removeAllCellItems()
                    expect(subject.allStreamCellItems.count) == 0
                }
            }

            describe("-streamCellItem:") {

                beforeEach {
                    var items = [StreamCellItem]()
                    items.append(StreamCellItem(jsonable: ElloComment.stub([:]), type: .createComment))

                    subject.appendStreamCellItems(items)
                }

                it("returns the correct stream cell item") {
                    let item = subject.streamCellItem(at: IndexPath(item: 0, section: 0))
                    expect(item?.type.reuseIdentifier) == "StreamCreateCommentCell"
                }

                it("returns nil if indexpath does not exist") {
                    let item = subject.streamCellItem(at: IndexPath(item: 50, section: 0))
                    expect(item).to(beNil())
                }
            }

            describe("-toggleCollapsed(at:)") {
                var postToToggle: Post!
                var postNotToToggle: Post!

                beforeEach {
                    var items = [StreamCellItem]()
                    let parser = StreamCellItemParser()
                    postToToggle = Post.stub(["contentWarning": "warning! b000000bs!", "content": [ImageRegion.stub([:])]])
                    postNotToToggle = Post.stub(["contentWarning": "warning! b000000bs!", "content": [ImageRegion.stub([:])]])
                    items += parser.parse([postToToggle], streamKind: .following)
                    items += parser.parse([postNotToToggle], streamKind: .following)

                    subject.appendStreamCellItems(items)
                }

                it("toggles collapsed on the post at an indexPath") {
                    expect(postToToggle.isCollapsed).to(beTrue())
                    let toggledItems = subject.cellItems(for: postToToggle)
                    for item in toggledItems {
                        if item.type != .streamFooter {
                            expect(item.state) == StreamCellState.collapsed
                        }
                    }
                    subject.toggleCollapsed(at: indexPath0)
                    for item in toggledItems {
                        if item.type != .streamFooter {
                            expect(item.state) == StreamCellState.expanded
                        }
                    }
                }

                it("does not toggle collapsed on other posts") {
                    let indexPathToToggle = IndexPath(item: 0, section: 0)
                    let indexPathNotToToggle = IndexPath(item: 4, section: 0)

                    expect(postToToggle) == subject.post(at: indexPathToToggle)!
                    expect(postNotToToggle) == subject.post(at: indexPathNotToToggle)!

                    expect(postToToggle.isCollapsed).to(beTrue())
                    expect(postNotToToggle.isCollapsed).to(beTrue())

                    let toggledItems = subject.cellItems(for: postToToggle)
                    let notToggledItems = subject.cellItems(for: postNotToToggle)

                    for item in toggledItems + notToggledItems {
                        if item.type != .streamFooter {
                            expect(item.state) == StreamCellState.collapsed
                        }
                    }
                    subject.toggleCollapsed(at: indexPathToToggle)
                    for item in toggledItems {
                        if item.type != .streamFooter {
                            expect(item.state) != StreamCellState.collapsed
                        }
                    }
                    for item in notToggledItems {
                        if item.type != .streamFooter {
                            expect(item.state) == StreamCellState.collapsed
                        }
                    }
                }
            }

            describe("insertStreamCellItems(_:, withWidth:, startingIndexPath:)") {
                var post: Post!
                var newCellItem: StreamCellItem!

                beforeEach {
                    post = Post.stub([:])
                    let toggleCellItem = StreamCellItem(jsonable: post, type: .toggle)
                    let imageCellItem = StreamCellItem(jsonable: post, type: .image(data: ImageRegion.stub([:])))
                    let anotherImageCellItem = StreamCellItem(jsonable: Post.stub([:]), type: .image(data: ImageRegion.stub([:])))

                    let comment = ElloComment.newCommentForPost(post, currentUser: User.stub([:]))
                    newCellItem = StreamCellItem(jsonable: comment, type: .createComment)

                    subject.appendStreamCellItems([toggleCellItem, imageCellItem, anotherImageCellItem])
                }

                it("inserts the new cellitems in the correct position") {
                    let countWas = subject.visibleCellItems.count
                    let startingIndexPath = IndexPath(item: 1, section: 0)

                    subject.insertStreamCellItems([newCellItem], startingIndexPath: startingIndexPath)

                    let insertedCellItem = subject.visibleCellItems[1]

                    expect(subject.visibleCellItems.count) == countWas + 1
                    expect(insertedCellItem.type.reuseIdentifier) == "StreamCreateCommentCell"
                }

                it("inserts the new cellitems in final position") {
                    let countWas = subject.visibleCellItems.count
                    let startingIndexPath = IndexPath(item: countWas, section: 0)

                    subject.insertStreamCellItems([newCellItem], startingIndexPath: startingIndexPath)

                    let insertedCellItem = subject.visibleCellItems[countWas]

                    expect(subject.visibleCellItems.count) == countWas + 1
                    expect(insertedCellItem.type.reuseIdentifier) == "StreamCreateCommentCell"
                }
            }

            context("elementsForJSONAble(_:, change:)") {
                let user1 = User.stub([:])
                let post1 = Post.stub([:])
                let comment1 = ElloComment.stub(["parentPost": post1])
                let user2 = User.stub([:])
                let post2 = Post.stub([:])
                let comment2 = ElloComment.stub(["parentPost": post2])
                beforeEach {
                    let cellItems = StreamCellItemParser().parseAllForTesting([
                        user1, post1, comment1,
                        user2, post2, comment2
                        ])
                    subject.appendStreamCellItems(cellItems)
                }
                it("should return a post (object equality)") {
                    let items = subject.testingElementsFor(jsonable: post1, change: .create).1
                    for item in items {
                        expect(item.jsonable) == post1
                    }
                }
                it("should return a comment (object equality)") {
                    let items = subject.testingElementsFor(jsonable: comment1, change: .create).1
                    for item in items {
                        expect(item.jsonable) == comment1
                    }
                }
                it("should return post and comment (object equality, change = .Delete)") {
                    let items = subject.testingElementsFor(jsonable: post1, change: .delete).1
                    for item in items {
                        if item.jsonable is ElloComment {
                            expect(item.jsonable) == comment1
                        }
                        else {
                            expect(item.jsonable) == post1
                        }
                    }
                }
                it("should return a user (object equality)") {
                    let items = subject.testingElementsFor(jsonable: user1, change: .create).1
                    for item in items {
                        expect(item.jsonable) == user1
                    }
                }
                it("should return a post (id equality)") {
                    let items = subject.testingElementsFor(jsonable: Post.stub(["id": post1.id]), change: .create).1
                    for item in items {
                        expect(item.jsonable) == post1
                    }
                }
                it("should return a comment (id equality)") {
                    let items = subject.testingElementsFor(jsonable: ElloComment.stub(["id": comment1.id]), change: .create).1
                    for item in items {
                        expect(item.jsonable) == comment1
                    }
                }
                it("should return post and comment (id equality, change = .Delete)") {
                    let items = subject.testingElementsFor(jsonable: Post.stub(["id": post1.id]), change: .delete).1
                    for item in items {
                        if item.jsonable is ElloComment {
                            expect(item.jsonable) == comment1
                        }
                        else {
                            expect(item.jsonable) == post1
                        }
                    }
                }
                it("should return a user (id equality)") {
                    let items = subject.testingElementsFor(jsonable: User.stub(["id": user1.id]), change: .create).1
                    for item in items {
                        expect(item.jsonable) == user1
                    }
                }
                it("should return nothing (no matching post)") {
                    let items = subject.testingElementsFor(jsonable: Post.stub([:]), change: .create).1
                    expect(items) == []
                }
                it("should return nothing (no matching comment)") {
                    let items = subject.testingElementsFor(jsonable: ElloComment.stub([:]), change: .create).1
                    expect(items) == []
                }
                it("should return nothing (no matching user)") {
                    let items = subject.testingElementsFor(jsonable: User.stub([:]), change: .create).1
                    expect(items) == []
                }
            }

            describe("calculating heights early exit") {
                it("should call the calculatedCellItems(completion:) block immediately if no cells need to be calculated") {
                    subject = StreamDataSource(streamKind: .following)

                    let items: [StreamCellItem] = [
                        StreamCellItem(type: .categoryCard),
                        StreamCellItem(type: .selectableCategoryCard),
                        StreamCellItem(type: .categoryList),
                        StreamCellItem(type: .commentHeader),
                        StreamCellItem(type: .createComment),
                        StreamCellItem(type: .streamFooter),
                        StreamCellItem(type: .streamHeader),
                        StreamCellItem(type: .inviteFriends),
                        StreamCellItem(type: .onboardingInviteFriends),
                        StreamCellItem(type: .emptyStream(height: 10)),
                        StreamCellItem(type: .loadMoreComments),
                        StreamCellItem(type: .noPosts),
                        StreamCellItem(type: .placeholder),
                        StreamCellItem(type: .profileHeaderGhost),
                        StreamCellItem(type: .search(placeholder: "")),
                        StreamCellItem(type: .seeMoreComments),
                        StreamCellItem(type: .spacer(height: 10)),
                        StreamCellItem(type: .fullWidthSpacer(height: 10)),
                        StreamCellItem(type: .streamLoading),
                        StreamCellItem(type: .header(nil)),
                        StreamCellItem(type: .tallHeader(nil)),
                        StreamCellItem(type: .toggle),
                        StreamCellItem(type: .unknown),
                        StreamCellItem(type: .userAvatars),
                        StreamCellItem(type: .userListItem),
                    ]

                    var done = false
                    subject.calculateCellItems(items, withWidth: 375) { _ in
                        done = true
                    }
                    expect(done) == true
                }
            }
        }
    }
}
