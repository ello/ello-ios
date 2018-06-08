@testable import Ello
import Quick
import Nimble

class StreamFooterCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("StreamFooterCellPresenter") {
            var cell: StreamFooterCell!
            var item: StreamCellItem!
            var toolbar: PostToolbar!
            var post: Post!

            beforeEach {
                cell = StreamFooterCell()
                post = Post.stub([
                    "viewsCount": 9,
                    "repostsCount": 4,
                    "commentsCount": 6,
                    "lovesCount": 14
                ])
                item = StreamCellItem(jsonable: post, type: .streamFooter)
                toolbar = cell.specs().toolbar
            }

            context("single column view") {

                it("configures a stream footer cell") {
                    StreamKind.following.setIsGridView(false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.comments.isSelected).to(beFalse())
                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.views.title) == "9"
                    expect(cell.reposts.title) == "4"
                    expect(cell.comments.title) == "6"
                    expect(cell.loves.title) == "14"
                }
            }

            context("grid layout") {

                it("configures a thin stream footer cell") {
                    cell.frame = CGRect(origin: .zero, size: CGSize(width: 150, height: 60))

                    StreamKind.following.setIsGridView(true)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.comments.isSelected).to(beFalse())
                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.views.title) == ""
                    expect(cell.reposts.title) == ""
                    expect(cell.comments.title) == "6"
                    expect(cell.loves.title) == ""
                }

                it("configures a wide stream footer cell") {
                    cell.frame = CGRect(origin: .zero, size: CGSize(width: 180, height: 60))

                    StreamKind.following.setIsGridView(true)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.comments.isSelected).to(beFalse())
                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.views.title) == "9"
                    expect(cell.reposts.title) == "4"
                    expect(cell.comments.title) == "6"
                    expect(cell.loves.title) == "14"
                }
            }

            context("detail streamkind") {

                it("configures a stream footer cell") {
                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: post.id), indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.comments.isSelected).to(beTrue())
                    expect(cell.views.title) == "9"
                    expect(cell.reposts.title) == "4"
                    expect(cell.comments.title) == "6"
                    expect(cell.loves.title) == "14"

                    // details should have open comments
                    expect(cell.commentsOpened).to(beTrue())
                }
            }

            context("comment button") {

                it("usually enabled and visible") {
                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).to(contain(.comments))
                }

                it("shown if author allows it") {
                    let author: User = stub(["hasCommentingEnabled": true])
                    let post: Post = stub([
                        "author": author,
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).to(contain(.comments))
                }

                it("shown if author allows it in grid view") {
                    let author: User = stub(["hasCommentingEnabled": true])
                    let post: Post = stub([
                        "author": author,
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).to(contain(.comments))
                }

                it("hidden if author doesn't allow it") {
                    let author: User = stub(["hasCommentingEnabled": false])
                    let post: Post = stub([
                        "author": author,
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).toNot(contain(.comments))
                }

                it("hidden if author doesn't allow it in grid view") {
                    let author: User = stub(["hasCommentingEnabled": false])
                    let post: Post = stub([
                        "author": author,
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).toNot(contain(.comments))
                }
            }

            context("sharing button") {

                it("usually enabled and visible") {
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "lovesCount": 22
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamKind.following.setIsGridView(false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).to(contain(.share))
                }

                it("shown if author allows it") {
                    let author: User = stub(["hasSharingEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).to(contain(.share))
                }

                it("never shown in grid view") {
                    let author: User = stub(["hasSharingEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)
                    StreamKind.following.setIsGridView(true)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).notTo(contain(.share))
                }

                it("hidden if author doesn't allow it") {
                    let author: User = stub(["hasSharingEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).toNot(contain(.share))
                }

                it("hidden if author doesn't allow it in grid view") {
                    let author: User = stub(["hasSharingEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).toNot(contain(.share))
                }
            }

            context("repost button") {

                it("usually enabled and visible") {
                    let user: User = stub([:])
                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: user)

                    expect(cell.reposts.isEnabled).to(beTrue())
                    expect(toolbar.postItems).to(contain(.repost))
                }

                it("enabled if currentUser, post.author and post.repostAuthor are all nil") {
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "lovesCount": 55
                        ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.reposts.isEnabled).to(beTrue())
                    expect(toolbar.postItems).to(contain(.repost))
                }

                it("shown if author allows it") {
                    let author: User = stub(["hasRepostingEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).to(contain(.repost))
                }

                it("shown if author allows it, in grid view") {
                    let author: User = stub(["hasRepostingEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).to(contain(.repost))
                }

                it("disabled if current user already reposted") {
                    let author: User = stub(["hasRepostingEnabled": true])
                    let currentUser: User = stub([:])
                    let post: Post = stub([
                        "reposted": true,
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)

                    expect(cell.reposts.isEnabled).to(beFalse())
                    expect(toolbar.postItems).to(contain(.repost))
                }

                it("hidden if author doesn't allow it") {
                    let author: User = stub(["hasRepostingEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).toNot(contain(.repost))
                }

                it("hidden if author doesn't allow it, in grid view") {
                    let author: User = stub(["hasRepostingEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).toNot(contain(.repost))
                }

                it("disabled if author is current user") {
                    let author: User = stub(["hasRepostingEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.reposts.isEnabled).to(beFalse())
                    expect(toolbar.postItems).to(contain(.repost))
                }

                it("disabled if author is repost author") {
                    let author: User = stub(["hasRepostingEnabled": true])
                    let repostAuthor: User = stub(["hasRepostingEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "repostAuthor": repostAuthor,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: repostAuthor)

                    expect(cell.reposts.isEnabled).to(beFalse())
                    expect(toolbar.postItems).to(contain(.repost))
                }

                it("disabled if author is current user in grid view") {
                    let author: User = stub(["hasRepostingEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.reposts.isEnabled).to(beFalse())
                    expect(toolbar.postItems).to(contain(.repost))
                }

                it("hidden if author is current user, and reposting isn't allowed") {
                    let author: User = stub(["hasRepostingEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(toolbar.postItems).toNot(contain(.repost))
                }

                it("hidden if author is current user, and reposting isn't allowed in grid view") {
                    let author: User = stub(["hasRepostingEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(toolbar.postItems).toNot(contain(.repost))
                }
            }

            context("loves button") {

                it("usually enabled and visible") {
                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.loves.isEnabled).to(beTrue())
                    expect(toolbar.postItems).to(contain(.loves))
                }

                it("shown if author allows it") {
                    let author: User = stub(["hasLovesEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).to(contain(.loves))
                }

                it("shown if author allows it in grid view") {
                    let author: User = stub(["hasLovesEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).to(contain(.loves))
                }

                it("hidden if author doesn't allow it") {
                    let author: User = stub(["hasLovesEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).toNot(contain(.loves))
                }

                it("hidden if author doesn't allow it in grid view") {
                    let author: User = stub(["hasLovesEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(toolbar.postItems).toNot(contain(.loves))
                }

                it("enabled if author is current user") {
                    let author: User = stub(["hasLovesEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.loves.isEnabled) == true
                    expect(toolbar.postItems).to(contain(.loves))
                }

                it("enabled if author is current user in grid view") {
                    let author: User = stub(["hasLovesEnabled": true])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.loves.isEnabled) == true
                    expect(toolbar.postItems).to(contain(.loves))
                }

                it("hidden if author is current user, and loving isn't allowed") {
                    let author: User = stub(["hasLovesEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(toolbar.postItems).toNot(contain(.loves))
                }

                it("hidden if author is current user, and loving isn't allowed in grid view") {
                    let author: User = stub(["hasLovesEnabled": false])
                    let post: Post = stub([
                        "viewsCount": 9,
                        "repostsCount": 4,
                        "commentsCount": 6,
                        "author": author,
                        "lovesCount": 55
                    ])
                    item = StreamCellItem(jsonable: post, type: .streamFooter)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(toolbar.postItems).toNot(contain(.loves))
                }
            }

            context("loading") {

                it("configures a stream footer cell") {
                    // set the state to loading
                    item.state = .loading

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.views.title) == "9"
                    expect(cell.reposts.title) == "4"
                    expect(cell.comments.title) == "6"

                    // commentsButton should be selected when the state is loading
                    expect(cell.comments.isSelected).to(beTrue())
                }
            }

            context("not loading") {

                context("expanded") {

                    it("configures a stream footer cell") {
                        // set the state to expanded
                        item.state = .expanded

                        StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.commentsOpened).to(beTrue())
                        expect(cell.views.title) == "9"
                        expect(cell.reposts.title) == "4"
                        expect(cell.comments.title) == "6"

                        // commentsButton should be selected when expanded
                        expect(cell.comments.isSelected).to(beTrue())
                    }

                }

                context("not expanded") {

                    it("configures a stream footer cell") {
                        // set the state to none
                        item.state = .none

                        StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.commentsOpened).to(beFalse())
                        expect(item.state) == StreamCellState.collapsed
                        expect(cell.views.title) == "9"
                        expect(cell.reposts.title) == "4"
                        expect(cell.comments.title) == "6"
                        expect(cell.comments.isSelected).to(beFalse())
                    }
                }
            }
        }
    }
}
