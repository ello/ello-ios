////
///  CommentHeaderCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class CommentHeaderCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("CommentHeaderCellPresenter") {
            var currentUser: User!
            var cell: CommentHeaderCell!
            var item: StreamCellItem!

            beforeEach {
                currentUser = User.stub(["username": "ello"])
                cell = CommentHeaderCell()
            }

            context("when currentUser is not the author") {
                beforeEach {
                    let post: Post = stub([:])
                    let comment: ElloComment = stub([
                        "parentPost": post,
                    ])

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
                        ])
                    let comment: ElloComment = stub([
                        "loadedFromPost": post,
                        ])

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
                        "author": reposter,
                        "repostAuthor": currentUser,
                        ])
                    let comment: ElloComment = stub([
                        "parentPost": repost,
                        "loadedFromPost": repost,
                        ])

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
                        "author": currentUser,
                        "repostAuthor": originalAuthor,
                        ])
                    let comment: ElloComment = stub([
                        "parentPost": repost,
                        "loadedFromPost": repost,
                        ])

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
                    let post: Post = stub([:])
                    let comment: ElloComment = stub([
                        "author": currentUser,
                        "parentPost": post,
                        ])

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

                    let post: Post = stub([:])
                    let comment: ElloComment = stub([
                        "parentPost": post,
                        ])

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

            for _role in [CategoryUser.Role.featured, CategoryUser.Role.curator, CategoryUser.Role.moderator] {
                let role = _role
                context("when comment author is a \(role) of the post category") {
                    beforeEach {
                        let category: Ello.Category = stub([:])
                        let categoryUser: CategoryUser = stub(["category": category, "role": role])
                        let author: User = stub(["categoryUsers": [categoryUser]])
                        let post: Post = stub(["category": category])
                        let comment: ElloComment = stub([
                            "author": author,
                            "parentPost": post,
                            ])

                            item = StreamCellItem(jsonable: comment, type: .commentHeader)
                    }
                    it("role should be .curator") {
                        CommentHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                        expect(cell.config.role) == role
                    }
                }
            }
        }
    }
}
