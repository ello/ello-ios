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
        let webWidth: CGFloat = 320
        let indexPath0 = IndexPath(item: 0, section: 0)
        let indexPath1 = IndexPath(item: 1, section: 0)
        let indexPathOutOfBounds = IndexPath(item: 1000, section: 0)
        let indexPathInvalidSection = IndexPath(item: 0, section: 10)

        var vc: StreamViewController!
        var subject: StreamDataSource!
        var fakeCollectionView: FakeCollectionView!

        describe("StreamDataSourceSpec") {
            beforeEach {
                let textSizeCalculator = FakeStreamTextCellSizeCalculator(webView: UIWebView())
                let notificationSizeCalculator = FakeStreamNotificationCellSizeCalculator(webView: UIWebView())
                let announcementSizeCalculator = FakeAnnouncementCellSizeCalculator()
                let profileHeaderSizeCalculator = FakeProfileHeaderCellSizeCalculator()
                let imageSizeCalculator = StreamImageCellSizeCalculator()
                let categoryHeaderSizeCalculator = CategoryHeaderCellSizeCalculator()

                StreamKind.following.setIsGridView(true)
                StreamKind.starred.setIsGridView(false)
                vc = StreamViewController.instantiateFromStoryboard()
                vc.streamKind = StreamKind.following
                subject = StreamDataSource(streamKind: .following,
                                           textSizeCalculator: textSizeCalculator,
                                           notificationSizeCalculator: notificationSizeCalculator,
                                           announcementSizeCalculator: announcementSizeCalculator,
                                           profileHeaderSizeCalculator: profileHeaderSizeCalculator,
                                           imageSizeCalculator: imageSizeCalculator,
                                           categoryHeaderSizeCalculator: categoryHeaderSizeCalculator
                )
                vc.dataSource = subject
                vc.collectionView.dataSource = vc.dataSource

                subject.streamCollapsedFilter = { item in
                    if !item.type.collapsable {
                        return true
                    }
                    if let post = item.jsonable as? Post {
                        return !post.collapsed
                    }
                    return true
                }
                showController(vc)
                fakeCollectionView = FakeCollectionView(frame: vc.collectionView.frame, collectionViewLayout: vc.collectionView.collectionViewLayout)
            }

            afterEach {
                subject.removeAllCellItems()
            }

            describe("init(streamKind:textSizeCalculator:notificationSizeCalculator:profileHeaderSizeCalculator:)") {

                it("has streamKind") {
                    expect(subject.streamKind).toNot(beNil())
                }

                it("has textSizeCalculator") {
                    expect(subject.textSizeCalculator).toNot(beNil())
                }

                it("has notificationSizeCalculator") {
                    expect(subject.notificationSizeCalculator).toNot(beNil())
                }

                it("has profileHeaderSizeCalculator") {
                    expect(subject.profileHeaderSizeCalculator).toNot(beNil())
                }
            }

            context("appendUnsizedCellItems(_:, withWidth:, completion:)") {
                let post = Post.stub([:])
                let cellItems = [
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:])))
                ]

                beforeEach {
                    subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in }
                }
                it("adds items") {
                    expect(subject.visibleCellItems.count) == cellItems.count
                }
                it("sizes the items") {
                    for item in cellItems {
                        expect(item.calculatedCellHeights.oneColumn!) == AppSetup.Size.calculatorHeight
                    }
                }
            }

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

            context("insertStreamCellItems(_:, startingIndexPath:)") {
                let post1 = Post.stub([:])
                let post2 = Post.stub([:])
                let firstCellItems = [
                    StreamCellItem(jsonable: post1, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post1, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post1, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post1, type: .text(data: TextRegion.stub([:])))
                ]
                let secondCellItems = [
                    StreamCellItem(jsonable: post2, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post2, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post2, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post2, type: .text(data: TextRegion.stub([:])))
                ]

                beforeEach {
                    subject.appendStreamCellItems(secondCellItems)
                    subject.insertStreamCellItems(firstCellItems, startingIndexPath: indexPath0)
                }
                it("inserts items") {
                    for (index, item) in (firstCellItems + secondCellItems).enumerated() {
                        expect(subject.visibleCellItems[index]) == item
                    }
                }
            }

            describe("collectionView(_:numberOfItemsInSection:)") {
                context("with posts") {
                    beforeEach {
                        // there should be 10 posts
                        // 10 * 3(number of cells for a post w/ 1 region) = 30
                        var posts = [Post]()
                        for index in 1...10 {
                            posts.append(Post.stub(["id": "\(index)"]))
                        }
                        let cellItems = StreamCellItemParser().parse(posts, streamKind: .following)
                        subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                            vc.collectionView.reloadData()
                        }
                    }

                    it("returns the correct number of rows") {
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 40
                    }
                }

                context("isValidIndexPath(_:)") {
                    beforeEach {
                        let item = StreamCellItem(jsonable: ElloComment.newCommentForPost(Post.stub([:]), currentUser: User.stub([:])), type: .createComment)
                        subject.appendStreamCellItems([item])
                    }
                    it("returns true for valid path (0, 0)") {
                        expect(subject.isValidIndexPath(IndexPath(item: 0, section: 0))) == true
                    }
                    it("returns true for valid path (items.count - 1, 0)") {
                        let idx = subject.visibleCellItems.count
                        expect(subject.isValidIndexPath(IndexPath(item: idx - 1, section: 0))) == true
                    }
                    it("returns false for invalid path (-1, 0)") {
                        expect(subject.isValidIndexPath(IndexPath(item: -1, section: 0))) == false
                    }
                    it("returns false for invalid path (items.count, 0)") {
                        let idx = subject.visibleCellItems.count
                        expect(subject.isValidIndexPath(IndexPath(item: idx, section: 0))) == false
                    }
                    it("returns false for invalid path (0, 1)") {
                        expect(subject.isValidIndexPath(IndexPath(item: 0, section: 1))) == false
                    }
                }

                context("with reposts") {
                    var posts = [Post]()
                    for index in 1...10 {
                        posts.append(Post.stub([
                            "id": "\(index)",
                            "repostContent": [TextRegion.stub([:]), TextRegion.stub([:])],
                            "content": [TextRegion.stub([:]), TextRegion.stub([:])]
                            ])
                        )
                    }
                    context("Following stream") {
                        beforeEach {
                            let cellItems = StreamCellItemParser().parse(posts, streamKind: .following)
                            subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                                vc.collectionView.reloadData()
                            }
                        }
                        it("returns the correct number of rows") {
                            // there should be 10 reposts
                            // 10 * 4(number of cells for a repost w/ 2 regions) = 40
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 40
                        }
                    }

                    context("Starred stream") {
                        beforeEach {
                            let cellItems = StreamCellItemParser().parse(posts, streamKind: .starred)
                            subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                                vc.collectionView.reloadData()
                            }
                        }

                        it("returns the correct number of rows") {
                            // there should be 10 reposts
                            // 10 * 7(number of cells for a repost w/ 2 regions) = 70
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 70
                        }
                    }
                }


                context("with collapsed and non collapsed posts") {
                    beforeEach {
                        var posts = [Post]()
                        // there should be 5 collapsed and 5 non collapsed
                        // 5 * 5(number of cells for non collapsed w/ 3 regions) = 25
                        // 5 * 3(number of cells for collapsed) = 15
                        // thus the 40
                        for index in 1...10 {
                            posts.append(Post.stub([
                                "id": "\(index)",
                                "contentWarning": index % 2 == 0 ? "" : "NSFW",
                                "summary": [TextRegion.stub([:]), TextRegion.stub([:]), TextRegion.stub([:])],
                                "content": [TextRegion.stub([:]), TextRegion.stub([:]), TextRegion.stub([:])],
                                ])
                            )
                        }
                        let cellItems = StreamCellItemParser().parse(posts, streamKind: .starred)
                        subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                            vc.collectionView.reloadData()
                        }
                    }

                    it("returns the correct number of rows") {
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 50
                    }
                }
            }

            describe("indexPathForItem(_:)") {
                var postItem: StreamCellItem!
                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Post.stub([:])], streamKind: .following)
                    postItem = cellItems[0]
                    subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an indexPath") {
                    expect(subject.indexPathForItem(postItem)).notTo(beNil())
                }

                it("returns nil when cell doesn't exist") {
                    let anyItem = StreamCellItem(jsonable: ElloComment.stub([:]), type: .seeMoreComments)
                    expect(subject.indexPathForItem(anyItem)).to(beNil())
                }

                it("returns nil when cell is hidden") {
                    subject.streamFilter = { postItem in return false }
                    expect(subject.indexPathForItem(postItem)).to(beNil())
                }

                it("returns the correct indexPath for same StreamCellItem Placeholder Types") {
                    let testItem = StreamCellItem(type: .placeholder)
                    testItem.placeholderType = .postHeader
                    let testItem2 = StreamCellItem(type: .placeholder)
                    testItem2.placeholderType = .postHeader

                    subject.removeAllCellItems()
                    subject.appendStreamCellItems([testItem])

                    expect(subject.indexPathForItem(testItem2)?.item) == 0
                }

                it("returns nil for same StreamCellItem Placeholder Types that are not the same") {
                    let testItem = StreamCellItem(type: .placeholder)
                    testItem.placeholderType = .postHeader
                    let testItem2 = StreamCellItem(type: .placeholder)
                    testItem2.placeholderType = .categoryList
                    subject.removeAllCellItems()
                    subject.appendStreamCellItems([testItem])

                    expect(subject.indexPathForItem(testItem2)).to(beNil())
                }
            }

            describe("indpexPathsForPlaceholderType(_:)") {

                beforeEach {
                    let user = User.stub([:])

                    let profileHeaderItems = [
                        StreamCellItem(jsonable: user, type: .profileHeader, placeholderType: .profileHeader),
                        StreamCellItem(jsonable: user, type: .fullWidthSpacer(height: 5), placeholderType: .profileHeader),
                        ]

                    let postItems = [
                        StreamCellItem(type: .header, placeholderType: .profilePosts),
                        StreamCellItem(type: .footer, placeholderType: .profilePosts),
                        ]


                    subject.removeAllCellItems()
                    subject.appendStreamCellItems(profileHeaderItems + postItems)
                }

                it("returns the correct indexPaths for profile header") {
                    let headerIndexPaths = subject.indexPathsForPlaceholderType(.profileHeader)

                    expect(headerIndexPaths[0].item) == 0
                    expect(headerIndexPaths[1].item) == 1
                }

                it("returns the correct indexPaths for profile posts") {
                    let postIndexPaths = subject.indexPathsForPlaceholderType(.profilePosts)

                    expect(postIndexPaths[0].item) == 2
                    expect(postIndexPaths[1].item) == 3
                }
            }

            describe("postForIndexPath(_:)") {

                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Post.stub([:])], streamKind: .following)
                    subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns a post") {
                    expect(subject.postForIndexPath(indexPath0)).to(beAKindOf(Post.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.postForIndexPath(indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.postForIndexPath(indexPathInvalidSection)).to(beNil())
                }
            }

            describe("imageAssetForIndexPath(_:)") {

                beforeEach {
                    let asset = Asset.stub([:])
                    let region = ImageRegion.stub(["asset": asset])
                    let post = Post.stub([
                        "summary": [region],
                        "content": [region],
                        ])
                    let cellItems = StreamCellItemParser().parse([post], streamKind: .following)
                    subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an image asset") {
                    expect(subject.imageAssetForIndexPath(IndexPath(item: 1, section: 0))).to(beAKindOf(Asset.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.imageAssetForIndexPath(indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.imageAssetForIndexPath(indexPathInvalidSection)).to(beNil())
                }
            }

            describe("commentForIndexPath(_:)") {

                beforeEach {
                    let cellItems = StreamCellItemParser().parse([ElloComment.stub([:])], streamKind: .following)
                    subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns a comment") {
                    expect(subject.commentForIndexPath(indexPath0)).to(beAKindOf(ElloComment.self))
                }

                it("returns nil when out of bounds") {
                    expect(subject.commentForIndexPath(indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil when invalid section") {
                    expect(subject.commentForIndexPath(indexPathInvalidSection)).to(beNil())
                }
            }

            describe("cellItemsForPost(_:)") {

                beforeEach {
                    let parser = StreamCellItemParser()
                    let postCellItems = parser.parse([Post.stub(["id": "666"])], streamKind: .following)
                    let commentCellItems = parser.parse([ElloComment.stub(["parentPostId": "666"]), ElloComment.stub(["parentPostId": "666"])], streamKind: .following)
                    let otherPostCellItems = parser.parse([Post.stub(["id": "777"])], streamKind: .following)
                    let cellItems = postCellItems + commentCellItems + otherPostCellItems
                    subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an array of StreamCellItems") {
                    let post = subject.postForIndexPath(indexPath0)!
                    let items = subject.cellItemsForPost(post)
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
                    let items = subject.cellItemsForPost(randomPost)
                    expect(items.count) == 0
                }

                it("does not return cell items for other posts") {
                    let post = subject.postForIndexPath(IndexPath(item: 9, section: 0))!
                    let items = subject.cellItemsForPost(post)
                    expect(post.id) == "777"
                    expect(items.count) == 4
                }

            }

            describe("userForIndexPath(_:)") {
                context("Returning a user-jsonable subject") {
                    beforeEach {
                        let userStreamKind = StreamKind.simpleStream(endpoint: ElloAPI.userStream(userParam: "42"), title: "yup")
                        let cellItems = StreamCellItemParser().parse([User.stub(["id": "42"])], streamKind: userStreamKind)
                        subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                            vc.collectionView.reloadData()
                        }
                    }

                    it("returns a user") {
                        expect(subject.userForIndexPath(indexPath0)).to(beAKindOf(User.self))
                    }
                    it("returns user 42") {
                        if let user = subject.userForIndexPath(indexPath0) {
                            expect(user.id) == "42"
                        }
                    }

                    it("returns nil when out of bounds") {
                        expect(subject.userForIndexPath(indexPathOutOfBounds)).to(beNil())
                    }

                    it("returns nil when invalid section") {
                        expect(subject.userForIndexPath(indexPathInvalidSection)).to(beNil())
                    }
                }
                context("Returning an author subject") {
                    beforeEach {
                        let cellItems = StreamCellItemParser().parse([Post.stub(["author": User.stub(["id": "42"])])], streamKind: .following)
                        subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                            vc.collectionView.reloadData()
                        }
                    }

                    it("returns a user") {
                        expect(subject.userForIndexPath(indexPath0)).to(beAKindOf(User.self))
                    }
                    it("returns user 42") {
                        if let user = subject.userForIndexPath(indexPath0) {
                            expect(user.id) == "42"
                        }
                    }

                    it("returns nil when out of bounds") {
                        expect(subject.userForIndexPath(indexPathOutOfBounds)).to(beNil())
                    }

                    it("returns nil when invalid section") {
                        expect(subject.userForIndexPath(indexPathInvalidSection)).to(beNil())
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
                        subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                            vc.collectionView.reloadData()
                        }
                    }

                    it("returns a user") {
                        expect(subject.userForIndexPath(indexPath0)).to(beAKindOf(User.self))
                    }
                    it("returns user 42") {
                        if let user = subject.userForIndexPath(indexPath0) {
                            expect(user.id) == "42"
                        }
                    }

                    it("returns nil when out of bounds") {
                        expect(subject.userForIndexPath(indexPathOutOfBounds)).to(beNil())
                    }

                    it("returns nil when invalid section") {
                        expect(subject.userForIndexPath(indexPathInvalidSection)).to(beNil())
                    }
                }
            }

            describe("commentIndexPathsForPost(_:)") {

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
                    subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns an array of comment index paths") {
                    let post = subject.postForIndexPath(indexPath0)
                    let indexPaths = subject.commentIndexPathsForPost(post!)

                    expect(indexPaths.count) == 5
                    expect(indexPaths[0].item) == 4
                    expect(indexPaths[1].item) == 5
                    expect(indexPaths[2].item) == 6
                    expect(indexPaths[3].item) == 7
                    expect(indexPaths[4].item) == 8
                }

                it("does not return index paths for comments from another post") {
                    let post = subject.postForIndexPath(IndexPath(item: 9, section: 0))
                    let indexPaths = subject.commentIndexPathsForPost(post!)

                    expect(indexPaths.count) == 2
                    expect(indexPaths[0].item) == 13
                    expect(indexPaths[1].item) == 14
                }

                it("returns an array of comment index paths when collapsed") {
                    let post = subject.postForIndexPath(IndexPath(item: 16, section: 0))
                    let indexPaths = subject.commentIndexPathsForPost(post!)

                    expect(indexPaths.count) == 3
                    expect(indexPaths[0].item) == 19
                    expect(indexPaths[1].item) == 20
                    expect(indexPaths[2].item) == 21
                }
            }

            describe("footerIndexPathForPost(_:)") {
                beforeEach {
                    let cellItems = StreamCellItemParser().parse([Post.stub(["id": "456"])], streamKind: .following)
                    subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns the index path of the footer associated with this post") {
                    let post = subject.postForIndexPath(indexPath0)
                    let indexPath = subject.footerIndexPathForPost(post!)

                    expect(indexPath!.item) == 2
                    expect(subject.visibleCellItems[indexPath!.item].type) == StreamCellType.footer
                }
            }


            describe("clientSidePostInsertIndexPath()") {
                let zero = IndexPath(item: 0, section: 0)
                let two = IndexPath(item: 2, section: 0)
                let tests: [(IndexPath?, StreamKind)] = [
                    (nil, .discover(type: .featured)),
                    (nil, .categoryPosts(slug: "art")),
                    (zero, .following),
                    (nil, .starred),
                    (nil, .simpleStream(endpoint: ElloAPI.loves(userId: "12345"), title: "NA")),
                    (nil, .notifications(category: "")),
                    (nil, .postDetail(postParam: "param")),
                    (two, .currentUserStream),
                    (nil, .unknown),
                    (nil, .userStream(userParam: "NA")),
                    (nil, .simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat")),
                    (nil, .simpleStream(endpoint: ElloAPI.userStreamFollowers(userId: "54321"), title: "")),
                    (two, .userStream(userParam: "12345")),
                    (nil, .simpleStream(endpoint: ElloAPI.userStream(userParam: "54321"), title: "")),
                    ]
                for (indexPath, streamKind) in tests {
                    it("is \(indexPath) for \(streamKind)") {
                        subject.streamKind = streamKind
                        subject.currentUser = User.stub(["id": "12345"])

                        if indexPath == nil {
                            expect(subject.clientSidePostInsertIndexPath()).to(beNil())
                        }
                        else {
                            expect(subject.clientSidePostInsertIndexPath()) == indexPath
                        }
                    }
                }
            }

            describe("clientSideLoveInsertIndexPath()") {
                let one = IndexPath(item: 1, section: 0)
                let tests: [(IndexPath?, StreamKind)] = [
                    (nil, .discover(type: .featured)),
                    (nil, .categoryPosts(slug: "art")),
                    (nil, .following),
                    (nil, .starred),
                    (one, .simpleStream(endpoint: ElloAPI.loves(userId: "12345"), title: "NA")),
                    (nil, .notifications(category: "")),
                    (nil, .postDetail(postParam: "param")),
                    (nil, .currentUserStream),
                    (nil, .unknown),
                    (nil, .userStream(userParam: "NA")),
                    (nil, .simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat")),
                    (nil, .simpleStream(endpoint: ElloAPI.userStreamFollowers(userId: "54321"), title: "")),
                    (nil, .userStream(userParam: "12345")),
                    (nil, .simpleStream(endpoint: ElloAPI.userStream(userParam: "54321"), title: "")),
                    ]
                for (indexPath, streamKind) in tests {
                    it("is \(indexPath) for \(streamKind)") {
                        subject.streamKind = streamKind

                        if indexPath == nil {
                            expect(subject.clientSideLoveInsertIndexPath()).to(beNil())
                        }
                        else {
                            expect(subject.clientSideLoveInsertIndexPath()) == indexPath
                        }
                    }
                }
            }


            describe("modifyItems(_:change:collectionView:)") {

                context("with comments") {

                    let stubCommentCellItems: (_ commentsVisible: Bool) -> Void = { (commentsVisible: Bool) in
                        let parser = StreamCellItemParser()
                        let postCellItems = parser.parse([Post.stub(["id": "456"])], streamKind: .following)
                        let commentButtonCellItem = [StreamCellItem(jsonable: ElloComment.stub(["parentPostId": "456"]), type: .createComment)]
                        let commentCellItems = parser.parse([ElloComment.stub(["parentPostId": "456", "id" : "111"])], streamKind: .following)
                        var cellItems = postCellItems
                        if commentsVisible {
                            cellItems = cellItems + commentButtonCellItem + commentCellItems
                        }
                        subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                            vc.collectionView.reloadData()
                        }
                    }

                    describe(".Create") {

                        it("inserts the new comment") {
                            stubCommentCellItems(true)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 7
                            subject.modifyItems(ElloComment.stub(["id": "new_comment", "parentPostId": "456"]), change: .create, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 9
                            expect(subject.commentForIndexPath(IndexPath(item: 5, section: 0))!.id) == "new_comment"
                        }

                        it("doesn't insert the new comment") {
                            stubCommentCellItems(false)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 4
                            subject.modifyItems(ElloComment.stub(["id": "new_comment", "parentPostId": "456"]), change: .create, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 4
                        }

                    }

                    describe(".Delete") {

                        it("removes the deleted comment") {
                            stubCommentCellItems(true)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 7
                            subject.modifyItems(ElloComment.stub(["id": "111", "parentPostId": "456"]), change: .delete, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 5

                        }

                        it("doesn't remove the deleted comment") {
                            stubCommentCellItems(false)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 4
                            subject.modifyItems(ElloComment.stub(["id": "111", "parentPostId": "456"]), change: .delete, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 4
                        }

                    }
                }

                context("with posts") {

                    beforeEach {
                        var posts = [Post]()
                        for index in 1...5 {
                            posts.append(Post.stub([
                                "id": "\(index)",
                                "commentsCount" : 5,
                                "content": [TextRegion.stub([:])]
                                ])
                            )
                        }

                        let cellItems = StreamCellItemParser().parse(posts, streamKind: .following)
                        subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                            vc.collectionView.reloadData()
                        }
                    }

                    describe(".Create") {

                        context("StreamKind.following") {

                            it("inserts the new post at 1, 0") {
                                subject.streamKind = .following
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20
                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .create, collectionView: fakeCollectionView)
                                expect(subject.postForIndexPath(indexPath1)!.id) == "new_post"
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 24
                            }

                        }

                        context("StreamKind.profile") {

                            it("inserts the new post at 4, 0") {
                                subject.streamKind = .currentUserStream
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20
                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .create, collectionView: fakeCollectionView)
                                expect(subject.postForIndexPath(indexPath0)!.id) == "1"
                                expect(subject.postForIndexPath(IndexPath(item: 4, section: 0))!.id) == "new_post"
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 24
                            }

                        }

                        context("StreamKind.userStream") {

                            it("inserts the new post at 4, 0") {
                                subject.currentUser = User.stub(["id" : "user-id-here"])
                                subject.streamKind = .userStream(userParam: "user-id-here")

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .create, collectionView: fakeCollectionView)

                                expect(subject.postForIndexPath(indexPath0)!.id) == "1"
                                expect(subject.postForIndexPath(IndexPath(item: 4, section: 0))!.id) == "new_post"
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 24
                            }

                            it("does not insert a post in other user's profiles") {
                                subject.currentUser = User.stub(["id" : "not-current-user-id-here"])
                                subject.streamKind = .userStream(userParam: "user-id-here")

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .create, collectionView: fakeCollectionView)

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20
                            }
                        }

                        context("StreamKind.starred") {

                            it("does not insert a post") {
                                subject.streamKind = .starred

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20

                                subject.modifyItems(Post.stub(["id": "new_post"]), change: .create, collectionView: fakeCollectionView)

                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20
                            }
                        }

                        context("StreamKind.loves") {

                            it("adds the newly loved post") {
                                subject.streamKind = StreamKind.simpleStream(endpoint: ElloAPI.loves(userId: "fake-id"), title: "Loves")
                                let love: Love = stub(["id": "love1", "postId": "post1"])
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20

                                subject.modifyItems(love, change: .create, collectionView: fakeCollectionView)

                                expect(subject.postForIndexPath(indexPath1)!.id) == "post1"
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 24
                            }
                        }
                    }

                    describe(".Delete") {

                        beforeEach {
                            subject.streamKind = .following
                        }

                        it("removes the deleted post") {
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20
                            subject.modifyItems(Post.stub(["id": "1"]), change: .delete, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 16
                        }

                        it("doesn't remove the deleted comment") {
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20
                            subject.modifyItems(Post.stub(["id": "not-present"]), change: .delete, collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20
                        }
                    }

                    describe(".Update") {

                        beforeEach {
                            subject.streamKind = .following
                        }

                        it("updates the updated post") {
                            expect(subject.postForIndexPath(IndexPath(item: 4, section: 0))!.commentsCount) == 5
                            subject.modifyItems(Post.stub(["id": "2", "commentsCount" : 9]), change: .update, collectionView: fakeCollectionView)
                            expect(subject.postForIndexPath(IndexPath(item: 4, section: 0))!.commentsCount) == 9
                        }

                        it("doesn't update the updated post") {
                            subject.modifyItems(Post.stub(["id": "not-present", "commentsCount" : 88]), change: .update, collectionView: fakeCollectionView)

                            for item in subject.streamCellItems {
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
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 20
                                subject.modifyItems(Post.stub(["id": "2", "commentsCount" : 9, "loved" : false]), change: .update, collectionView: fakeCollectionView)
                                expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 16
                            }
                        }
                    }
                }
            }

            describe("modifyUserRelationshipItems(_:collectionView:)") {

                let stubCellItems: (_ streamKind: StreamKind) -> Void = { streamKind in
                    let user1: User = stub(["id": "user1"])
                    let post1: Post = stub(["id": "post1", "authorId" : "user1"])
                    let post1Comment1: ElloComment = stub([
                        "parentPost": post1,
                        "id" : "comment1",
                        "authorId": "user1"
                        ])
                    let post1Comment2: ElloComment = stub([
                        "parentPost": post1,
                        "id" : "comment2",
                        "authorId": "user2"
                        ])
                    let parser = StreamCellItemParser()
                    let userCellItems = parser.parse([user1], streamKind: streamKind)
                    let post1CellItems = parser.parse([post1], streamKind: streamKind)
                    let post1CommentCellItems = parser.parse([post1Comment1, post1Comment2], streamKind: streamKind)
                    let cellItems = userCellItems + post1CellItems + post1CommentCellItems
                    subject.streamKind = streamKind
                    subject.appendUnsizedCellItems(cellItems, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                describe("blocking a user") {

                    context("blocked user is the post author") {
                        it("removes blocked user, their post and all comments on that post") {
                            stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.friendStream, title: "some title"))
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 9
                            subject.modifyUserRelationshipItems(User.stub(["id": "user1", "relationshipPriority": RelationshipPriority.block.rawValue]), collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 0
                        }
                    }

                    context("blocked user is not the post author") {
                        it("removes blocked user's comments") {
                            stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.friendStream, title: "some title"))
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 9
                            subject.modifyUserRelationshipItems(User.stub(["id": "user2", "relationshipPriority": RelationshipPriority.block.rawValue]), collectionView: fakeCollectionView)
                            expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 7
                        }
                    }

                    it("does not remove cells tied to other users") {
                        stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.friendStream, title: "some title"))
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 9
                        subject.modifyUserRelationshipItems(User.stub(["id": "unrelated-user", "relationshipPriority": RelationshipPriority.block.rawValue]), collectionView: fakeCollectionView)
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 9
                    }

                }

                describe("friending/noising/inactivating a user") {

                    it("updates posts from that user") {
                        stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.friendStream, title: "some title"))
                        var user1 = subject.userForIndexPath(indexPath0)!
                        expect(user1.followersCount) == "stub-user-followers-count"
                        expect(user1.relationshipPriority.rawValue) == RelationshipPriority.none.rawValue
                        subject.modifyUserRelationshipItems(User.stub(["id": "user1", "followersCount": "2", "followingCount": 2, "relationshipPriority": RelationshipPriority.following.rawValue]), collectionView: fakeCollectionView)
                        user1 = subject.userForIndexPath(indexPath0)!
                        expect(user1.followersCount) == "2"
                        expect(user1.relationshipPriority.rawValue) == RelationshipPriority.following.rawValue
                    }

                    it("shows the star on the avatarButton") {
                        stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.friendStream, title: "some title"))
                        subject.modifyUserRelationshipItems(User.stub(["id": "user1", "followersCount": "2", "followingCount": 2, "relationshipPriority": RelationshipPriority.starred.rawValue]), collectionView: fakeCollectionView)
                        let indexPath = IndexPath(item: 1, section: 0)
                        let headerCellItem = subject.visibleStreamCellItem(at: indexPath)!
                        let post = headerCellItem.jsonable as? Post
                        expect(post?.author?.relationshipPriority) == .starred
                    }

                    xit("updates comments from that user") {
                        // comments are not yet affected by User.RelationshipPriority changes
                        // left intentionally empty for documentation
                    }

                    it("updates cells tied to that user") {

                    }
                }

                describe("muting a user") {

                    beforeEach {
                        let streamKind: StreamKind = .notifications(category: nil)
                        let user1: User = stub(["id": "user1"])
                        let post1: Post = stub(["id": "post1", "authorId" : "other-user"])
                        let activity1: Activity = stub(["id": "activity1", "subject" : user1])
                        let activity2: Activity = stub(["id": "activity2", "subject" : post1])
                        let parser = StreamCellItemParser()
                        let notificationCellItems = parser.parse([activity1, activity2], streamKind: streamKind)
                        subject.streamKind = streamKind
                        subject.appendUnsizedCellItems(notificationCellItems, withWidth: webWidth) { cellCount in
                            vc.collectionView.reloadData()
                        }
                    }

                    it("clears out notifications from that user when on notifications") {
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 2
                        subject.modifyUserRelationshipItems(User.stub(["id": "user1", "relationshipPriority": RelationshipPriority.mute.rawValue]), collectionView: fakeCollectionView)
                        expect(subject.collectionView(vc.collectionView, numberOfItemsInSection: 0)) == 1
                    }

                    it("does not clear out content from that user when elsewhere") {

                    }
                }

            }

            describe("modifyUserSettingsItems(_:collectionView:)") {

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
                        stubCellItems(StreamKind.simpleStream(endpoint: ElloAPI.friendStream, title: "some title"))
                        expect(subject.userForIndexPath(indexPath0)!.username) == "sweet"
                        subject.modifyUserSettingsItems(User.stub(["id": "user1", "username": "sweetness"]), collectionView: fakeCollectionView)
                        expect(subject.userForIndexPath(indexPath0)!.username) == "sweetness"
                    }
                }
            }

            describe("createCommentIndexPathForPost(_:)") {
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

                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("points to a create-comment-item") {
                    if let path = subject.createCommentIndexPathForPost(post),
                        let item = subject.visibleStreamCellItem(at: path)
                    {
                        expect(item.type).to(equal(StreamCellType.createComment))
                    }
                    else {
                        fail("no CreateComment StreamCellItem found")
                    }
                }

            }

            describe("-removeCommentsForPost:") {
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

                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("removes comment index paths") {
                    let indexPaths = subject.removeCommentsFor(post: post)

                    expect(indexPaths.count) > 0
                    expect(subject.commentIndexPathsForPost(post)).to(beEmpty())
                }

            }

            describe("-updateHeightForIndexPath:") {
                beforeEach {
                    var items = [StreamCellItem]()
                    let parser = StreamCellItemParser()
                    items += parser.parse([Post.stub(["id": "666", "content": [TextRegion.stub([:])]])], streamKind: .following)

                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("updates the height of an existing StreamCellItem") {
                    let indexPath = IndexPath(item: 1, section: 0)
                    subject.updateHeightForIndexPath(indexPath, height: 256)

                    let cellItem = subject.visibleStreamCellItem(at: indexPath)
                    expect(cellItem!.calculatedCellHeights.oneColumn!) == 256
                    expect(cellItem!.calculatedCellHeights.multiColumn!) == 256
                }

                it("handles non-existent index paths") {
                    expect(subject.updateHeightForIndexPath(indexPathOutOfBounds, height: 256))
                        .notTo(raiseException())
                }

                it("handles invalid section") {
                    expect(subject.updateHeightForIndexPath(indexPathInvalidSection, height: 256))
                        .notTo(raiseException())
                }
            }

            describe("-heightForIndexPath:numberOfColumns") {
                beforeEach {
                    var items = [StreamCellItem]()
                    items.append(StreamCellItem(jsonable: ElloComment.stub([:]), type: .createComment))

                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }
                it("returns the correct height") {
                    expect(subject.heightForIndexPath(indexPath0, numberOfColumns: 1)) == 75.0
                    expect(subject.heightForIndexPath(indexPath0, numberOfColumns: 2)) == 75.0
                }

                it("returns 0 when out of bounds") {
                    expect(subject.heightForIndexPath(indexPathOutOfBounds, numberOfColumns: 0)) == 0
                }

                it("returns 0 when invalid section") {
                    expect(subject.heightForIndexPath(indexPathInvalidSection, numberOfColumns: 0)) == 0
                }
            }

            describe("removeItemsAtIndexPaths(_: [IndexPath])") {
                let post = Post.stub([:])
                let items = [
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:]))),
                    StreamCellItem(jsonable: post, type: .text(data: TextRegion.stub([:])))
                ]
                beforeEach {
                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in }
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
                    subject.removeItemsAtIndexPaths([indexPath0, indexPath1])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        expect(item) == items[index + 2]
                    }
                }
                it("should allow removing items from the beginning, reverse order") {
                    subject.removeItemsAtIndexPaths([indexPath1, indexPath0])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        expect(item) == items[index + 2]
                    }
                }
                it("should allow removing items from the end") {
                    subject.removeItemsAtIndexPaths([IndexPath(item: items.count - 2, section: 0), IndexPath(item: items.count - 1, section: 0)])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        expect(item) == items[index]
                    }
                }
                it("should allow removing items from the end, reverse order") {
                    subject.removeItemsAtIndexPaths([IndexPath(item: items.count - 1, section: 0), IndexPath(item: items.count - 2, section: 0)])
                    expect(subject.visibleCellItems.count) == items.count - 2
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        expect(item) == items[index]
                    }
                }
                it("should allow removing items from the middle") {
                    subject.removeItemsAtIndexPaths([indexPath1, IndexPath(item: 2, section: 0)])
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
                    subject.removeItemsAtIndexPaths([IndexPath(item: 2, section: 0), indexPath1])
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
                    subject.removeItemsAtIndexPaths([indexPathOutOfBounds])
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

                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("sets the number of visible cell items to 0") {
                    expect(subject.visibleCellItems.count) > 0
                    subject.removeAllCellItems()
                    expect(subject.visibleCellItems.count) == 0
                }

                it("sets the number of cell items to 0") {
                    expect(subject.streamCellItems.count) > 0
                    subject.removeAllCellItems()
                    expect(subject.streamCellItems.count) == 0
                }
            }

            describe("-visibleStreamCellItem:") {

                beforeEach {
                    var items = [StreamCellItem]()
                    items.append(StreamCellItem(jsonable: ElloComment.stub([:]), type: .createComment))

                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns the correct stream cell item") {
                    let item = subject.visibleStreamCellItem(at: IndexPath(item: 0, section: 0))
                    expect(item?.type.name) == "StreamCreateCommentCell"
                }

                it("returns nil if indexpath does not exist") {
                    let item = subject.visibleStreamCellItem(at: IndexPath(item: 50, section: 0))
                    expect(item).to(beNil())
                }

                it("returns nil if a filter (returns false) is active") {
                    subject.streamFilter = { _ in return false }
                    let itemExists = subject.streamCellItems[0]
                    expect(itemExists.type.name) == "StreamCreateCommentCell"
                    let itemHidden = subject.visibleStreamCellItem(at: IndexPath(item: 0, section: 0))
                    expect(itemHidden).to(beNil())
                }

                it("returns item if a filter (returns true) is active") {
                    subject.streamFilter = { _ in return true }
                    let itemExists = subject.streamCellItems[0]
                    expect(itemExists.type.name) == "StreamCreateCommentCell"
                    let itemHidden = subject.visibleStreamCellItem(at: IndexPath(item: 0, section: 0))
                    expect(itemHidden?.type.name) == "StreamCreateCommentCell"
                }
            }

            describe("-toggleCollapsedForIndexPath:") {
                var postToToggle: Post!
                var postNotToToggle: Post!

                beforeEach {
                    var items = [StreamCellItem]()
                    let parser = StreamCellItemParser()
                    postToToggle = Post.stub(["contentWarning" : "warning! b000000bs!", "content": [ImageRegion.stub([:])]])
                    postNotToToggle = Post.stub(["contentWarning" : "warning! b000000bs!", "content": [ImageRegion.stub([:])]])
                    items += parser.parse([postToToggle], streamKind: .following)
                    items += parser.parse([postNotToToggle], streamKind: .following)

                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("toggles collapsed on the post at an indexPath") {
                    expect(postToToggle.collapsed).to(beTrue())
                    let toggledItems = subject.cellItemsForPost(postToToggle)
                    for item in toggledItems {
                        if item.type != .footer {
                            expect(item.state) == StreamCellState.collapsed
                        }
                    }
                    subject.toggleCollapsedForIndexPath(indexPath0)
                    for item in toggledItems {
                        if item.type != .footer {
                            expect(item.state) == StreamCellState.expanded
                        }
                    }
                }

                it("does not toggle collapsed on other posts") {
                    let indexPathToToggle = IndexPath(item: 0, section: 0)
                    let indexPathNotToToggle = IndexPath(item: 4, section: 0)

                    expect(postToToggle) == subject.postForIndexPath(indexPathToToggle)!
                    expect(postNotToToggle) == subject.postForIndexPath(indexPathNotToToggle)!

                    expect(postToToggle.collapsed).to(beTrue())
                    expect(postNotToToggle.collapsed).to(beTrue())

                    let toggledItems = subject.cellItemsForPost(postToToggle)
                    let notToggledItems = subject.cellItemsForPost(postNotToToggle)

                    for item in toggledItems + notToggledItems {
                        if item.type != .footer {
                            expect(item.state) == StreamCellState.collapsed
                        }
                    }
                    subject.toggleCollapsedForIndexPath(indexPathToToggle)
                    for item in toggledItems {
                        if item.type != .footer {
                            expect(item.state) != StreamCellState.collapsed
                        }
                    }
                    for item in notToggledItems {
                        if item.type != .footer {
                            expect(item.state) == StreamCellState.collapsed
                        }
                    }
                }
            }

            describe("-isFullWidthAtIndexPath:") {

                beforeEach {
                    let items = [
                        StreamCellItem(jsonable: ElloComment.stub([:]), type: .createComment),
                        StreamCellItem(jsonable: ElloComment.stub([:]), type: .commentHeader)
                    ]
                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns true for Full Width items") {
                    let isFullWidth = subject.isFullWidthAtIndexPath(indexPath0)
                    expect(isFullWidth) == true
                }

                it("returns false for all other items") {
                    let indexPath = IndexPath(item: 1, section: 0)
                    let isFullWidth = subject.isFullWidthAtIndexPath(indexPath)
                    expect(isFullWidth) == false
                }

                it("returns true when out of bounds") {
                    expect(subject.isFullWidthAtIndexPath(indexPathOutOfBounds)) == true
                }

                it("returns true when invalid section") {
                    expect(subject.isFullWidthAtIndexPath(indexPathInvalidSection)) == true
                }

            }

            describe("-groupForIndexPath:") {
                var post: Post!
                beforeEach {
                    var items = [StreamCellItem]()
                    let parser = StreamCellItemParser()
                    post = Post.stub(["id": "666", "content": [TextRegion.stub([:])]])
                    items += parser.parse([post], streamKind: .following)
                    items.append(StreamCellItem(jsonable: ElloComment.newCommentForPost(post, currentUser: User.stub([:])), type: .createComment))
                    items += parser.parse([ElloComment.stub(["parentPostId": "666"]), ElloComment.stub(["parentPostId": "666"])], streamKind: .following)

                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("returns the same value for a post and it's comments") {
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        let indexPath = IndexPath(item: index, section: 0)
                        let groupId = subject.groupForIndexPath(indexPath)
                        if item.jsonable is Post || item.jsonable is ElloComment {
                            expect(groupId) == post.groupId
                        }
                    }
                }

                it("does not return the same value for two different posts") {
                    let firstPostIndexPath = IndexPath(item: 0, section: 0)
                    let secondPostIndexPath = IndexPath(item: subject.visibleCellItems.count, section: 0)

                    let parser = StreamCellItemParser()
                    let post2 = Post.stub(["id": "555"])
                    let items = parser.parse([post2], streamKind: .following)
                    subject.appendUnsizedCellItems(items, withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }

                    let firstGroupId = subject.groupForIndexPath(firstPostIndexPath)
                    let secondGroupId = subject.groupForIndexPath(secondPostIndexPath)

                    expect(firstGroupId) != secondGroupId
                }

                it("returns nil if indexPath out of bounds") {
                    expect(subject.groupForIndexPath(indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil if invalid section") {
                    expect(subject.groupForIndexPath(indexPathInvalidSection)).to(beNil())
                }

                it("returns nil if StreamCellItem's jsonable is not Groupable") {
                    let lastIndexPath = IndexPath(item: subject.visibleCellItems.count, section: 0)
                    let nonGroupable: Asset = stub(["id": "123"])

                    let item = StreamCellItem(jsonable: nonGroupable, type: .image(data: ImageRegion.stub([:])))

                    subject.appendUnsizedCellItems([item], withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }

                    expect(subject.groupForIndexPath(lastIndexPath)).to(beNil())
                }
            }

            describe("insertUnsizedCellItems(_:, withWidth:, startingIndexPath:, completion:)") {
                var post: Post!
                var newCellItem: StreamCellItem!

                beforeEach {
                    post = Post.stub([:])
                    let toggleCellItem = StreamCellItem(jsonable: post, type: .toggle)
                    let imageCellItem = StreamCellItem(jsonable: post, type: .image(data: ImageRegion.stub([:])))
                    let anotherImageCellItem = StreamCellItem(jsonable: Post.stub([:]), type: .image(data: ImageRegion.stub([:])))

                    let comment = ElloComment.newCommentForPost(post, currentUser: User.stub([:]))
                    newCellItem = StreamCellItem(jsonable: comment, type: .createComment)

                    subject.appendUnsizedCellItems([toggleCellItem, imageCellItem, anotherImageCellItem], withWidth: webWidth) { cellCount in
                        vc.collectionView.reloadData()
                    }
                }

                it("inserts the new cellitems in the correct position") {
                    let countWas = subject.visibleCellItems.count
                    let startingIndexPath = IndexPath(item: 1, section: 0)

                    subject.insertUnsizedCellItems([newCellItem], withWidth: 10.0, startingIndexPath: startingIndexPath ){ _ in
                    }

                    let insertedCellItem = subject.visibleCellItems[1]

                    expect(subject.visibleCellItems.count) == countWas + 1
                    expect(insertedCellItem.type.name) == "StreamCreateCommentCell"
                }

                it("inserts the new cellitems in final position") {
                    let countWas = subject.visibleCellItems.count
                    let startingIndexPath = IndexPath(item: countWas, section: 0)

                    subject.insertUnsizedCellItems([newCellItem], withWidth: 10.0, startingIndexPath: startingIndexPath ){ _ in

                    }

                    let insertedCellItem = subject.visibleCellItems[countWas]

                    expect(subject.visibleCellItems.count) == countWas + 1
                    expect(insertedCellItem.type.name) == "StreamCreateCommentCell"
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
                    subject.appendUnsizedCellItems(cellItems, withWidth: 10.0) { (indexPaths) in
                    }
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
            //
            //            xdescribe("-collectionView:cellForItemAtIndexPath:") {
            //
            //                beforeEach {
            //                    subject = StreamDataSource(streamKind: .Following,
            //                        textSizeCalculator: textSizeCalculator,
            //                        notificationSizeCalculator: notificationSizeCalculator,
            //                        profileHeaderSizeCalculator: profileHeaderSizeCalculator)
            //
            //                    subject.appendUnsizedCellItems(ModelHelper.allCellTypes(), withWidth: webWidth) { cellCount in
            //                        vc.collectionView.reloadData()
            //                    }
            //                }
            //
            //                describe("with posts") {
            //                    it("returns a StreamHeaderCell") {
            //                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 0, section: 0))
            //                        expect(cell).to(beAnInstanceOf(StreamHeaderCell.self))
            //                    }
            //
            //                    it("returns a StreamTextCell") {
            //                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 1, section: 0))
            //                        expect(cell).to(beAnInstanceOf(StreamToggleCell.self))
            //                    }
            //
            //                    it("returns a StreamFooterCell") {
            //                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 2, section: 0))
            //                        expect(cell).to(beAnInstanceOf(StreamTextCell.self))
            //                    }
            //                }
            //
            //                describe("with comments") {
            //                    it("returns a StreamHeaderCell") {
            //                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 3, section: 0))
            //                        expect(cell).to(beAnInstanceOf(StreamFooterCell.self))
            //                    }
            //
            //                    it("returns a StreamTextCell") {
            //                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 4, section: 0))
            //                        expect(cell).to(beAnInstanceOf(StreamHeaderCell.self))
            //                    }
            //                }
            //
            //                describe("with users") {
            //                    it("returns a ProfileHeaderCell") {
            //                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 5, section: 0))
            //                        expect(cell).to(beAnInstanceOf(StreamTextCell.self))
            //                    }
            //
            //                    it("returns a UserListItemCell") {
            //                        let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 6, section: 0))
            //                        expect(cell).to(beAnInstanceOf(ProfileHeaderCell.self))
            //                    }
            //                }
            //
            //                it("returns a NotificationCell") {
            //                    let notification: Notification = stub([:])
            //                    let cellItem = StreamCellItem(jsonable: notification, type: .Notification)
            //                    subject.appendUnsizedCellItems([cellItem], withWidth: webWidth) { cellCount in
            //                        vc.collectionView.reloadData()
            //                    }
            //
            //                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 0, section: 0))
            //                    expect(cell).to(beAnInstanceOf(NotificationCell.self))
            //                }
            //
            //                it("returns a StreamImageCell") {
            //                    let post: Post = stub([:])
            //                    let imageRegion: ImageRegion = stub([:])
            //                    let cellItem = StreamCellItem(jsonable: post, type: .Image)
            //                    subject.appendUnsizedCellItems([cellItem], withWidth: webWidth) { cellCount in
            //                        vc.collectionView.reloadData()
            //                    }
            //
            //                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 0, section: 0))
            //                    expect(cell).to(beAnInstanceOf(StreamImageCell.self))
            //                }
            //
            //                it("returns a StreamToggleCell") {
            //                    // Xcode is unable to compile the specs with all the cell types that are generated by the "allCellTypes()" helper in Model Helper
            //                    let post: Post = stub([:])
            //                    let cellItem = StreamCellItem(jsonable: post, type: .Toggle)
            //                    subject.appendUnsizedCellItems([cellItem], withWidth: webWidth) { cellCount in
            //                        vc.collectionView.reloadData()
            //                    }
            //
            //                    let cell = subject.collectionView(vc.collectionView, cellForItemAtIndexPath: IndexPath(item: 0, section: 0))
            //                    expect(cell).to(beAnInstanceOf(StreamToggleCell.self))
            //                }
            //            }
        }
    }
}
