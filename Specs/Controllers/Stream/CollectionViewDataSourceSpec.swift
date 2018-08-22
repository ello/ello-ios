////
///  CollectionViewDataSourceSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CollectionViewDataSourceSpec: QuickSpec {
    override func spec() {
        let indexPath0 = IndexPath(item: 0, section: 0)
        let indexPath1 = IndexPath(item: 1, section: 0)
        let indexPathOutOfBounds = IndexPath(item: 1000, section: 0)
        let indexPathInvalidSection = IndexPath(item: 0, section: 10)

        var streamViewController: StreamViewController!
        var subject: CollectionViewDataSource!

        beforeEach {
            subject = CollectionViewDataSource(streamKind: .following)
            streamViewController = StreamViewController()
            streamViewController.streamKind = .following
        }

        describe("CollectionViewDataSource") {
            describe("collectionView(_:numberOfItemsInSection:)") {
                var cellItems: [StreamCellItem]!

                context("with posts") {
                    beforeEach {
                        // there should be 10 posts
                        // 10 * 3(number of cells for a post w/ 1 region) = 30
                        var posts = [Post]()
                        for index in 1...10 {
                            posts.append(Post.stub(["id": "\(index)"]))
                        }
                        cellItems = StreamCellItemParser().parse(posts, streamKind: .following)
                        subject.visibleCellItems = cellItems
                    }

                    it("returns the correct number of rows") {
                        let rowCount = subject.collectionView(streamViewController.collectionView, numberOfItemsInSection: 0)
                        expect(rowCount) == cellItems.count
                    }
                }
            }

            describe("-height(at:numberOfColumns:)") {
                beforeEach {
                    var items = [StreamCellItem]()
                    items.append(StreamCellItem(jsonable: ElloComment.stub([:]), type: .createComment))

                    subject.visibleCellItems = items
                }
                it("returns the correct height") {
                    expect(subject.height(at: indexPath0, numberOfColumns: 1)) == 75
                    expect(subject.height(at: indexPath0, numberOfColumns: 2)) == 75
                }

                it("returns 0 when out of bounds") {
                    expect(subject.height(at: indexPathOutOfBounds, numberOfColumns: 0)) == 0
                }

                it("returns 0 when invalid section") {
                    expect(subject.height(at: indexPathInvalidSection, numberOfColumns: 0)) == 0
                }
            }

            describe("-isFullWidth(at:)") {

                beforeEach {
                    StreamKind.following.setIsGridView(true)
                    let items = [
                        StreamCellItem(jsonable: ElloComment.stub([:]), type: .createComment),
                        StreamCellItem(jsonable: ElloComment.stub([:]), type: .streamHeader)
                    ]
                    subject.visibleCellItems = items
                }

                it("returns true for full width items") {
                    let isFullWidth = subject.isFullWidth(at: indexPath0)
                    expect(isFullWidth) == true
                }

                it("returns false for all other items") {
                    let isFullWidth = subject.isFullWidth(at: indexPath1)
                    expect(isFullWidth) == false
                }

                it("returns true when out of bounds") {
                    expect(subject.isFullWidth(at: indexPathOutOfBounds)) == true
                }

                it("returns true when invalid section") {
                    expect(subject.isFullWidth(at: indexPathInvalidSection)) == true
                }

            }

            describe("-isTappable(at:)") {

                beforeEach {
                    let items = [
                        StreamCellItem(jsonable: ElloComment.stub([:]), type: .createComment),
                        StreamCellItem(jsonable: Notification.stub([:]), type: .notification),
                        StreamCellItem(jsonable: ElloComment.stub([:]), type: .commentHeader)
                    ]
                    subject.visibleCellItems = items
                }

                it("returns true for Full Width items") {
                    let isTappable = subject.isTappable(at: indexPath0)
                    expect(isTappable) == true
                }

                it("returns true for Selectable items") {
                    let isTappable = subject.isTappable(at: indexPath1)
                    expect(isTappable) == true
                }

                it("returns false for all other items") {
                    StreamKind.following.setIsGridView(false)
                    let indexPath = IndexPath(item: 2, section: 0)
                    let isTappable = subject.isTappable(at: indexPath)
                    expect(isTappable) == false
                }

                it("returns false when out of bounds") {
                    expect(subject.isTappable(at: indexPathOutOfBounds)) == false
                }

                it("returns false when invalid section") {
                    expect(subject.isTappable(at: indexPathInvalidSection)) == false
                }

            }

            describe("-group(at:)") {
                var post: Post!
                beforeEach {
                    var items = [StreamCellItem]()
                    let parser = StreamCellItemParser()
                    post = Post.stub(["id": "666", "content": [TextRegion.stub([:])]])
                    items += parser.parse([post], streamKind: .following)
                    items.append(StreamCellItem(jsonable: ElloComment.newCommentForPost(post, currentUser: User.stub([:])), type: .createComment))
                    items += parser.parse([ElloComment.stub(["parentPostId": "666"]), ElloComment.stub(["parentPostId": "666"])], streamKind: .following)

                    subject.visibleCellItems = items
                }

                it("returns the same value for a post and it's comments") {
                    for (index, item) in subject.visibleCellItems.enumerated() {
                        let indexPath = IndexPath(item: index, section: 0)
                        let groupId = subject.group(at: indexPath)
                        if item.jsonable is Post || item.jsonable is ElloComment {
                            expect(groupId).to(equal("Post-\(post.id)"))
                        }
                    }
                }

                it("does not return the same value for two different posts") {
                    let firstPostIndexPath = IndexPath(item: 0, section: 0)

                    let parser = StreamCellItemParser()
                    let post1 = Post.stub(["id": "111"])
                    let post2 = Post.stub(["id": "555"])
                    let items = parser.parse([post1, post2], streamKind: .following)
                    subject.visibleCellItems = items
                    let secondPostIndexPath = IndexPath(item: subject.visibleCellItems.count - 1, section: 0)

                    let firstGroupId = subject.group(at: firstPostIndexPath)
                    let secondGroupId = subject.group(at: secondPostIndexPath)

                    expect(firstGroupId) != secondGroupId
                }

                it("returns nil if indexPath out of bounds") {
                    expect(subject.group(at: indexPathOutOfBounds)).to(beNil())
                }

                it("returns nil if invalid section") {
                    expect(subject.group(at: indexPathInvalidSection)).to(beNil())
                }

                it("returns nil if StreamCellItem's jsonable is not Groupable") {
                    let lastIndexPath = IndexPath(item: subject.visibleCellItems.count, section: 0)
                    let nonGroupable: Asset = stub(["id": "123"])

                    let item = StreamCellItem(jsonable: nonGroupable, type: .image(data: ImageRegion.stub([:])))

                    subject.visibleCellItems = [item]

                    expect(subject.group(at: lastIndexPath)).to(beNil())
                }
            }
        }
    }
}
