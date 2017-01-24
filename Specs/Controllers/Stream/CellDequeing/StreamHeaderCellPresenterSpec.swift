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
            let textRegion: TextRegion = stub(["content" : "I am your comment's content"])
            let content = [textRegion]

            var cell: StreamHeaderCell!
            var item: StreamCellItem!

            beforeEach {
                StreamKind.starred.setIsGridView(true)
                StreamKind.following.setIsGridView(false)
            }

            context("when item is a Post Header") {
                beforeEach {
                    let post: Post = stub([
                        "id" : "768",
                        "author": currentUser,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        "createdAt": Date(timeIntervalSinceNow: -1000),
                    ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .header)
                }

                it("starts out closed") {
                    cell.scrollView.contentOffset = CGPoint(x: 20, y: 0)
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.scrollView.contentOffset) == CGPoint.zero
                }
                it("ownPost should be false") {
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.ownPost) == false
                }
                it("ownComment should be false") {
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.ownComment) == false
                }
                it("sets scrollView.scrollEnabled") {
                    cell.scrollView.isScrollEnabled = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.scrollView.isScrollEnabled) == false
                }
                it("sets chevronHidden") {
                    cell.chevronHidden = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.chevronHidden) == true
                }
                it("sets goToPostView.isHidden") {
                    cell.goToPostView.isHidden = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.goToPostView.isHidden) == false
                }
                it("sets canReply") {
                    cell.canReply = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.canReply) == false
                }
                it("sets timeStamp") {
                    cell.timeStamp = ""
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.timeStamp) == "17m"
                }
                it("sets usernameButton title") {
                    cell.usernameButton.setTitle("", for: .normal)
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.usernameButton.currentTitle) == "@ello"
                }
                it("hides repostAuthor") {
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.repostedByButton.isHidden) == true
                    expect(cell.repostIconView.isHidden) == true
                }

                context("gridLayout streamKind") {
                    it("sets isGridLayout") {
                        cell.isGridLayout = false
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.isGridLayout) == true
                    }

                    it("sets avatarHeight") {
                        cell.avatarHeight = 0
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.avatarHeight) == 30.0
                    }
                }

                context("not-gridLayout streamKind") {
                    it("sets isGridLayout") {
                        cell.isGridLayout = true
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.isGridLayout) == false
                    }

                    it("sets avatarHeight") {
                        cell.avatarHeight = 0
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.avatarHeight) == 40
                    }
                }
            }

            context("when item is a Post Header with repostAuthor") {
                beforeEach {
                    let repostAuthor: User = stub([
                        "id": "reposterId",
                        "username": "reposter",
                        "relationshipPriority": RelationshipPriority.starred.rawValue,
                    ])
                    let post: Post = stub([
                        "id" : "768",
                        "author": currentUser,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        "repostAuthor": repostAuthor,
                    ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .header)
                }
                it("sets relationshipControl properties") {
                    cell.relationshipControl.userId = ""
                    cell.relationshipControl.userAtName = ""
                    cell.relationshipControl.relationshipPriority = RelationshipPriority.null
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.relationshipControl.userId) == "reposterId"
                    expect(cell.relationshipControl.userAtName) == "@reposter"
                    expect(cell.relationshipControl.relationshipPriority) == RelationshipPriority.starred
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                }

                context("gridLayout streamKind") {
                    it("shows reposter and author") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.repostedByButton.isHidden) == false
                        expect(cell.repostIconView.isHidden) == false
                    }
                }

                context("not-gridLayout streamKind") {
                    it("shows author and repostAuthor") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.repostedByButton.currentTitle) == "by @ello"
                        expect(cell.repostedByButton.isHidden) == false
                        expect(cell.repostIconView.isHidden) == false
                    }
                }
            }

            context("when item is a Post Header with author and PostDetail streamKind") {
                beforeEach {
                    let author: User = stub([
                        "id": "authorId",
                        "username": "author",
                        "relationshipPriority": RelationshipPriority.following.rawValue,
                    ])
                    let post: Post = stub([
                        "id" : "768",
                        "author": author,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                    ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .header)
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: "768"), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == true
                    expect(cell.relationshipControl.userId) == "authorId"
                    expect(cell.relationshipControl.userAtName) == "@author"
                    expect(cell.relationshipControl.relationshipPriority) == RelationshipPriority.following
                }
            }

            context("when item is a Post Header with repostAuthor and PostDetail streamKind") {
                beforeEach {
                    let repostAuthor: User = stub([
                        "id": "reposterId",
                        "username": "reposter",
                        "relationshipPriority": RelationshipPriority.starred.rawValue,
                    ])
                    let post: Post = stub([
                        "id" : "768",
                        "author": currentUser,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        "repostAuthor": repostAuthor,
                    ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .header)
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: "768"), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == true
                    expect(cell.relationshipControl.userId) == "reposterId"
                    expect(cell.relationshipControl.userAtName) == "@reposter"
                    expect(cell.relationshipControl.relationshipPriority) == RelationshipPriority.starred
                }
            }

            context("when item is a Post Header with Category and PostDetail streamKind") {
                beforeEach {
                    let category: Ello.Category = stub(["name": "Art"])
                    let post: Post = stub([
                        "id" : "768",
                        "author": currentUser,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        "categories": [category],
                    ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .header)
                }
                it("sets categoryButton in .Featured stream") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .discover(type: .featured), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                    expect(cell.relationshipControl.isHidden) == true
                    expect(cell.categoryButton.currentTitle) == "in Art"
                    expect(cell.categoryButton.isHidden) == false
                }
                it("hides categoryButton if not in .Featured stream") {
                    cell.followButtonVisible = false
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: "768"), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                    expect(cell.relationshipControl.isHidden) == true
                    expect(cell.categoryButton.isHidden) == true
                }
            }

            context("when item is a Post Header with author and PostDetail streamKind, but currentUser is the author") {
                beforeEach {
                    let post: Post = stub([
                        "id" : "768",
                        "author": currentUser,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        ])

                    cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                    item = StreamCellItem(jsonable: post, type: .header)
                }
                it("sets followButtonVisible") {
                    cell.followButtonVisible = true
                    StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: "768"), indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                    expect(cell.followButtonVisible) == false
                }
            }

            context("when item is a CommentHeader") {
                context("when currentUser is not the author") {
                    beforeEach {
                        let post: Post = stub([
                            "id" : "768",
                            "viewsCount" : 9,
                            "repostsCount" : 4,
                            "commentsCount" : 6,
                            "lovesCount" : 14,
                        ])
                        let comment: ElloComment = stub([
                            "id" : "362",
                            "parentPost" : post,
                            "content" : content
                        ])

                        cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("sets avatarHeight") {
                        cell.avatarHeight = 0
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.avatarHeight) == 30.0
                    }
                    it("sets scrollView.scrollEnabled") {
                        cell.scrollView.isScrollEnabled = false
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.scrollView.isScrollEnabled) == true
                    }
                    it("sets chevronHidden") {
                        cell.chevronHidden = true
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.chevronHidden) == false
                    }
                    it("sets goToPostView.isHidden") {
                        cell.goToPostView.isHidden = false
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.goToPostView.isHidden) == true
                    }
                    it("sets canReply") {
                        cell.canReply = false
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.canReply) == true
                    }
                    it("ownPost should be false") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.ownPost) == false
                    }
                    it("ownComment should be false") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.ownComment) == false
                    }
                }
                context("when currentUser is the post author") {
                    beforeEach {
                        let post: Post = stub([
                            "id" : "768",
                            "author": currentUser,
                            "viewsCount" : 9,
                            "repostsCount" : 4,
                            "commentsCount" : 6,
                            "lovesCount" : 14,
                            ])
                        let comment: ElloComment = stub([
                            "id" : "362",
                            "loadedFromPost" : post,
                            "content" : content
                            ])

                        cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("ownPost should be true") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.ownPost) == true
                    }
                    it("ownComment should be false") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.ownComment) == false
                    }
                }
                context("when currentUser is the repost author") {
                    beforeEach {
                        let reposter: User = stub([:])
                        let repost: Post = stub([
                            "id" : "901",
                            "author": reposter,
                            "repostAuthor": currentUser,
                            "viewsCount" : 9,
                            "repostsCount" : 4,
                            "commentsCount" : 6,
                            "lovesCount" : 14,
                            ])
                        let comment: ElloComment = stub([
                            "id" : "362",
                            "parentPost" : repost,
                            "loadedFromPost": repost,
                            "content" : content
                            ])

                        cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("ownPost should be true") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.ownPost) == true
                    }
                    it("ownComment should be false") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.ownComment) == false
                    }
                }
                context("when currentUser is the comment author") {
                    beforeEach {
                        let post: Post = stub([
                            "id" : "768",
                            "viewsCount" : 9,
                            "repostsCount" : 4,
                            "commentsCount" : 6,
                            "lovesCount" : 14,
                            ])
                        let comment: ElloComment = stub([
                            "id" : "362",
                            "author": currentUser,
                            "parentPost" : post,
                            "content" : content
                            ])

                        cell = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("ownPost should be false") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.ownPost) == false
                    }
                    it("ownComment should be true") {
                        StreamHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.ownComment) == true
                    }
                }
            }
        }
    }
}
