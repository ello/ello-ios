////
///  StreamHeaderCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamHeaderCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("StreamHeaderCellPresenter") {
            let currentUser: User = stub(["username": "ello"])
            var cell: StreamHeaderCell!
            var item: StreamCellItem!

            beforeEach {
                StreamKind.following.setIsGridView(false)
            }

            context("when item is a Post Header") {
                beforeEach {
                    let post: Post = stub([
                        "author": currentUser,
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "lovesCount": 14,
                        "createdAt": Date(timeIntervalSinceNow: -1000),
                    ])

                    cell = StreamHeaderCell()
                    item = StreamCellItem(jsonable: post, type: .streamHeader)
                }

                it("sets timeStamp") {
                    cell.timeStamp = ""
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.timeStamp) == "17m"
                }
                it("sets usernameButton title") {
                    cell.specs().usernameButton.title = ""
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.specs().usernameButton.currentTitle) == "@ello"
                }
                it("hides repostAuthor") {
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.specs().repostedByButton.isHidden) == true
                    expect(cell.specs().repostIconView.isHidden) == true
                }

                context("gridLayout streamKind") {

                    beforeEach {
                        StreamKind.following.setIsGridView(true)
                    }

                    it("sets isGridView") {
                        cell.isGridView = false
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.isGridView) == true
                    }
                }

                context("not-gridLayout streamKind") {
                    it("sets isGridView") {
                        cell.isGridView = true
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.isGridView) == false
                    }
                }
            }

            context("when item is a Post Header with repostAuthor") {
                beforeEach {
                    let repostAuthor: User = stub([
                        "id": "reposterId",
                        "username": "reposter",
                        "relationshipPriority": RelationshipPriority.following.rawValue,
                    ])
                    let post: Post = stub([
                        "author": currentUser,
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "lovesCount": 14,
                        "repostAuthor": repostAuthor,
                    ])

                    cell = StreamHeaderCell()
                    item = StreamCellItem(jsonable: post, type: .streamHeader)
                }
                it("sets relationshipControl properties") {
                    cell.specs().relationshipControl.userId = ""
                    cell.specs().relationshipControl.userAtName = ""
                    cell.specs().relationshipControl.relationshipPriority = RelationshipPriority.null
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.specs().relationshipControl.userId) == "reposterId"
                    expect(cell.specs().relationshipControl.userAtName) == "@reposter"
                    expect(cell.specs().relationshipControl.relationshipPriority) == RelationshipPriority.following
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                }

                context("gridLayout streamKind") {
                    it("shows reposter and author") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.specs().repostedByButton.isHidden) == false
                        expect(cell.specs().repostIconView.isHidden) == false
                    }
                }

                context("not-gridLayout streamKind") {
                    it("shows author and repostAuthor") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.specs().repostedByButton.currentTitle) == "by @ello"
                        expect(cell.specs().repostedByButton.isHidden) == false
                        expect(cell.specs().repostIconView.isHidden) == false
                    }
                }
            }

            context("when item is a Post Header with author and PostDetail streamKind") {
                let postId = "768"
                beforeEach {
                    let author: User = stub([
                        "id": "authorId",
                        "username": "author",
                        "relationshipPriority": RelationshipPriority.following.rawValue,
                    ])
                    let post: Post = stub([
                        "id": postId,
                        "author": author,
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "lovesCount": 14,
                    ])

                    cell = StreamHeaderCell()
                    item = StreamCellItem(jsonable: post, type: .streamHeader)
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: postId), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == true
                    expect(cell.specs().relationshipControl.userId) == "authorId"
                    expect(cell.specs().relationshipControl.userAtName) == "@author"
                    expect(cell.specs().relationshipControl.relationshipPriority) == RelationshipPriority.following
                }
            }

            context("when item is a Post Header with repostAuthor and PostDetail streamKind") {
                let postId = "768"
                beforeEach {
                    let repostAuthor: User = stub([
                        "id": "reposterId",
                        "username": "reposter",
                        "relationshipPriority": RelationshipPriority.following.rawValue,
                    ])
                    let post: Post = stub([
                        "id": postId,
                        "repostAuthor": repostAuthor,
                    ])

                    cell = StreamHeaderCell()
                    item = StreamCellItem(jsonable: post, type: .streamHeader)
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: postId), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == true
                    expect(cell.specs().relationshipControl.userId) == "reposterId"
                    expect(cell.specs().relationshipControl.userAtName) == "@reposter"
                    expect(cell.specs().relationshipControl.relationshipPriority) == RelationshipPriority.following
                }
            }

            context("when item is a Post Header with Category and PostDetail streamKind") {
                beforeEach {
                    let category: Ello.Category = stub(["name": "Art"])
                    let post: Post = stub([
                        "author": currentUser,
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "lovesCount": 14,
                        "categories": [category],
                    ])

                    cell = StreamHeaderCell()
                    item = StreamCellItem(jsonable: post, type: .streamHeader)
                }
                it("sets categoryButton in .Featured stream") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .category(.all, .featured), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                    expect(cell.specs().relationshipControl.isHidden) == true
                    expect(cell.specs().categoryButton.title) == "in Art"
                    expect(cell.specs().categoryButton.isHidden) == false
                }
                it("hides categoryButton if not in .Featured stream") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: ""), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                    expect(cell.specs().relationshipControl.isHidden) == true
                    expect(cell.specs().categoryButton.isHidden) == true
                }
            }

            context("when item is a Post Header with author and PostDetail streamKind, but currentUser is the author") {
                beforeEach {
                    let post: Post = stub([
                        "author": currentUser,
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "lovesCount": 14,
                        ])

                    cell = StreamHeaderCell()
                    item = StreamCellItem(jsonable: post, type: .streamHeader)
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: ""), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                }
            }

            context("when item is an Artist Invite Submission Post Header in Featured Category") {
                beforeEach {
                    let post: Post = stub(["artistInviteId": "12345"])

                    cell = StreamHeaderCell()
                    item = StreamCellItem(jsonable: post, type: .streamHeader)
                }
                it("shows artistInviteSubmissionButton") {
                    cell.specs().artistInviteSubmissionButton.isHidden = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .category(.all, .featured), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.specs().artistInviteSubmissionButton.isHidden) == false
                }
            }
        }
    }
}
