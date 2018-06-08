////
///  StreamCreateCommentCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamCreateCommentCellPresenterSpec: QuickSpec {
    enum PostOwnership {
        case otherPost
        case myPost
        case myRepostOtherPost
        case otherRepostMyPost
        case otherRepostOtherPost
    }

    override func spec() {
        describe("StreamCreateCommentCellPresenter") {
            context("replyAll and watch button visibility") {
                let expectations: [(postOwner: PostOwnership, canWatch: Bool, canReplyAll: Bool)] = [
                    (postOwner: .otherPost, canWatch: true, canReplyAll: false),
                    (postOwner: .myPost, canWatch: false, canReplyAll: true),
                    (postOwner: .myRepostOtherPost, canWatch: false, canReplyAll: true),
                    (postOwner: .otherRepostMyPost, canWatch: false, canReplyAll: false),
                    (postOwner: .otherRepostOtherPost, canWatch: true, canReplyAll: false),
                ]
                for (postOwner, canWatch, canReplyAll) in expectations {
                    context("post owner \(postOwner)") {
                        let currentUser: User = stub(["id": "me"])
                        let otherUser: User = stub(["id": "other"])
                        var post: Post!
                        var comment: ElloComment!
                        var cell: StreamCreateCommentCell!
                        var item: StreamCellItem!
                        beforeEach {
                            switch postOwner {
                            case .otherPost:
                                post = Post.stub(["author": otherUser])
                            case .myPost:
                                post = Post.stub(["author": currentUser])
                            case .myRepostOtherPost:
                                post = Post.stub(["author": currentUser, "repostAuthor": otherUser, "repostContent": [TextRegion(content: "")]])
                            case .otherRepostMyPost:
                                post = Post.stub(["author": otherUser, "repostAuthor": currentUser, "repostContent": [TextRegion(content: "")]])
                            case .otherRepostOtherPost:
                                post = Post.stub(["author": otherUser, "repostAuthor": otherUser, "repostContent": [TextRegion(content: "")]])
                            }
                            comment = ElloComment.stub(["loadedFromPost": post])
                            item = StreamCellItem(jsonable: comment, type: .createComment)
                            cell = StreamCreateCommentCell()
                        }
                        it("cell \(canWatch ? "can" : "cannot") watch") {
                            StreamCreateCommentCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                            expect(cell.watchVisibility == .enabled) == canWatch
                        }
                        it("cell \(canReplyAll ? "can" : "cannot") reply all") {
                            StreamCreateCommentCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)
                            expect(cell.replyAllVisibility == .enabled) == canReplyAll
                        }
                    }
                }
            }
        }
    }
}
