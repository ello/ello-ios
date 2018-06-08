////
///  CommentHeaderCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CommentHeaderCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("CommentHeaderCellPresenter") {
            let currentUser: User = stub(["username": "ello"])
            var cell: CommentHeaderCell!
            var item: StreamCellItem!
            let textRegion: TextRegion = stub(["content": "I am your comment's content"])
            let content = [textRegion]

            context("when item is a CommentHeader") {
                context("when currentUser is not the author") {
                    beforeEach {
                        let post: Post = stub([
                            "viewsCount": 9,
                            "repostsCount": 4,
                            "commentsCount": 6,
                            "lovesCount": 14,
                        ])
                        let comment: ElloComment = stub([
                            "id": "362",
                            "parentPost": post,
                            "content": content
                        ])

                        cell = CommentHeaderCell()
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("canReply should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canReplyAndFlag) == true
                    }
                    it("canEdit should be false") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canEdit) == false
                    }
                    it("canDelete should be false") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canDelete) == false
                    }
                }
                context("when currentUser is the post author") {
                    beforeEach {
                        let post: Post = stub([
                            "author": currentUser,
                            "viewsCount": 9,
                            "repostsCount": 4,
                            "commentsCount": 6,
                            "lovesCount": 14,
                            ])
                        let comment: ElloComment = stub([
                            "id": "362",
                            "loadedFromPost": post,
                            "content": content
                            ])

                        cell = CommentHeaderCell()
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("canReply should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canReplyAndFlag) == true
                    }
                    it("canEdit should be false") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canEdit) == false
                    }
                    it("canDelete should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canDelete) == true
                    }
                }
                context("when currentUser is the repost author") {
                    beforeEach {
                        let reposter: User = stub([:])
                        let repost: Post = stub([
                            "id": "901",
                            "author": reposter,
                            "repostAuthor": currentUser,
                            "viewsCount": 9,
                            "repostsCount": 4,
                            "commentsCount": 6,
                            "lovesCount": 14,
                            ])
                        let comment: ElloComment = stub([
                            "id": "362",
                            "parentPost": repost,
                            "loadedFromPost": repost,
                            "content": content
                            ])

                        cell = CommentHeaderCell()
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("canReply should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canReplyAndFlag) == true
                    }
                    it("canEdit should be false") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canEdit) == false
                    }
                    it("canDelete should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canDelete) == true
                    }
                }
                context("when currentUser is the reposter") {
                    beforeEach {
                        let originalAuthor: User = stub([:])
                        let repost: Post = stub([
                            "id": "901",
                            "author": currentUser,
                            "repostAuthor": originalAuthor,
                            "viewsCount": 9,
                            "repostsCount": 4,
                            "commentsCount": 6,
                            "lovesCount": 14,
                            ])
                        let comment: ElloComment = stub([
                            "id": "362",
                            "parentPost": repost,
                            "loadedFromPost": repost,
                            "content": content
                            ])

                        cell = CommentHeaderCell()
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("canReply should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canReplyAndFlag) == true
                    }
                    it("canEdit should be false") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canEdit) == false
                    }
                    it("canDelete should be false") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canDelete) == false
                    }
                }
                context("when currentUser is the comment author") {
                    beforeEach {
                        let post: Post = stub([
                            "viewsCount": 9,
                            "repostsCount": 4,
                            "commentsCount": 6,
                            "lovesCount": 14,
                            ])
                        let comment: ElloComment = stub([
                            "id": "362",
                            "author": currentUser,
                            "parentPost": post,
                            "content": content
                            ])

                        cell = CommentHeaderCell()
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("canReply should be false") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canReplyAndFlag) == false
                    }
                    it("canEdit should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canEdit) == true
                    }
                    it("canDelete should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canDelete) == true
                    }
                }
                context("when currentUser is staff") {
                    beforeEach {
                        AuthToken.sharedKeychain.isStaff = true

                        let post: Post = stub([
                            "viewsCount": 9,
                            "repostsCount": 4,
                            "commentsCount": 6,
                            "lovesCount": 14,
                            ])
                        let comment: ElloComment = stub([
                            "id": "362",
                            "parentPost": post,
                            "content": content
                            ])

                        cell = CommentHeaderCell()
                        item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("canReply should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canReplyAndFlag) == true
                    }
                    it("canEdit should be false") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canEdit) == false
                    }
                    it("canDelete should be true") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.canDelete) == true
                    }
                }
            }
        }
    }
}
