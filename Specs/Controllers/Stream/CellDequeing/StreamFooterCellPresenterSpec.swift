@testable import Ello
import Quick
import Nimble


class StreamFooterCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {

            context("single column view") {

                it("configures a stream footer cell") {
                    GroupDefaults["FollowingIsGridView"] = false
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsControl.isSelected).to(beFalse())
                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.views) == "9"
                    expect(cell.reposts) == "4"
                    expect(cell.comments) == "6"
                    expect(cell.loves) == "14"
                }
            }

            context("grid layout") {

                it("configures a thin stream footer cell") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    cell.frame = CGRect(origin: .zero, size: CGSize(width: 150, height: 60))
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    GroupDefaults["StarredIsGridView"] = true
                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsControl.isSelected).to(beFalse())
                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.views) == ""
                    expect(cell.reposts) == ""
                    expect(cell.comments) == "6"
                    expect(cell.loves) == ""
                }

                it("configures a wide stream footer cell") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    cell.frame = CGRect(origin: .zero, size: CGSize(width: 180, height: 60))
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    GroupDefaults["StarredIsGridView"] = true
                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsControl.isSelected).to(beFalse())
                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.views) == "9"
                    expect(cell.reposts) == "4"
                    expect(cell.comments) == "6"
                    expect(cell.loves) == "14"
                }
            }

            context("detail streamkind") {

                it("configures a stream footer cell") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 22
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .postDetail(postParam: "768"), indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsControl.isSelected).to(beTrue())
                    expect(cell.views) == "9"
                    expect(cell.reposts) == "4"
                    expect(cell.comments) == "6"
                    expect(cell.loves) == "22"

                    // details should have open comments
                    expect(cell.commentsOpened).to(beTrue())
                }
            }

            context("comment button") {

                it("usually enabled and visible") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 22
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsItem.customView).to(beVisibleIn(cell))
                }

                it("shown if author allows it") {
                    let author: User = stub(["id" : "1", "hasCommentingEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsItem.customView).to(beVisibleIn(cell))
                }

                it("shown if author allows it in grid view") {
                    let author: User = stub(["id" : "1", "hasCommentingEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsItem.customView).to(beVisibleIn(cell))
                }

                it("hidden if author doesn't allow it") {
                    let author: User = stub(["id" : "1", "hasCommentingEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsItem.customView).toNot(beVisibleIn(cell))
                }

                it("hidden if author doesn't allow it in grid view") {
                    let author: User = stub(["id" : "1", "hasCommentingEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsItem.customView).toNot(beVisibleIn(cell))
                }
            }

            context("sharing button") {

                it("usually enabled and visible") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 22
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.shareItem.customView).to(beVisibleIn(cell))
                }

                it("shown if author allows it") {
                    let author: User = stub(["id" : "1", "hasSharingEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.shareItem.customView).to(beVisibleIn(cell))
                }

                it("never shown in grid view") {
                    let author: User = stub(["id" : "1", "hasSharingEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.shareItem.customView).notTo(beVisibleIn(cell))
                }

                it("hidden if author doesn't allow it") {
                    let author: User = stub(["id" : "1", "hasSharingEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.shareItem.customView).toNot(beVisibleIn(cell))
                }

                it("hidden if author doesn't allow it in grid view") {
                    let author: User = stub(["id" : "1", "hasSharingEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.shareItem.customView).toNot(beVisibleIn(cell))
                }
            }

            context("repost button") {

                it("usually enabled and visible") {
                    let user: User = stub([:])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: user)

                    expect(cell.repostControl.isEnabled).to(beTrue())
                    expect(cell.repostItem.customView).to(beVisibleIn(cell))
                }

                it("enabled if currentUser, post.author and post.repostAuthor are all nil") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 55
                        ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.repostControl.isEnabled).to(beTrue())
                    expect(cell.repostItem.customView).to(beVisibleIn(cell))
                }

                it("shown if author allows it") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.repostItem.customView).to(beVisibleIn(cell))
                }

                it("shown if author allows it, in grid view") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.repostItem.customView).to(beVisibleIn(cell))
                }

                it("disabled if current user already reposted") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : true])
                    let currentUser: User = stub(["id" : "2"])
                    let post: Post = stub([
                        "id" : "768",
                        "reposted": true,
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: currentUser)

                    expect(cell.repostControl.isEnabled).to(beFalse())
                    expect(cell.repostItem.customView).to(beVisibleIn(cell))
                }

                it("hidden if author doesn't allow it") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.repostItem.customView).toNot(beVisibleIn(cell))
                }

                it("hidden if author doesn't allow it, in grid view") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.repostItem.customView).toNot(beVisibleIn(cell))
                }

                it("disabled if author is current user") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.repostControl.isEnabled).to(beFalse())
                    expect(cell.repostItem.customView).to(beVisibleIn(cell))
                }

                it("disabled if author is repost author") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : true])
                    let repostAuthor: User = stub(["id" : "2", "hasRepostingEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "repostAuthor" : repostAuthor,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: repostAuthor)

                    expect(cell.repostControl.isEnabled).to(beFalse())
                    expect(cell.repostItem.customView).to(beVisibleIn(cell))
                }

                it("disabled if author is current user in grid view") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.repostControl.isEnabled).to(beFalse())
                    expect(cell.repostItem.customView).to(beVisibleIn(cell))
                }

                it("hidden if author is current user, and reposting isn't allowed") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.repostItem.customView).toNot(beVisibleIn(cell))
                }

                it("hidden if author is current user, and reposting isn't allowed in grid view") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.repostItem.customView).toNot(beVisibleIn(cell))
                }
            }

            context("loves button") {

                it("usually enabled and visible") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.lovesControl.isEnabled).to(beTrue())
                    expect(cell.lovesItem.customView).to(beVisibleIn(cell))
                }

                it("shown if author allows it") {
                    let author: User = stub(["id" : "1", "hasLovesEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.lovesItem.customView).to(beVisibleIn(cell))
                }

                it("shown if author allows it in grid view") {
                    let author: User = stub(["id" : "1", "hasLovesEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.lovesItem.customView).to(beVisibleIn(cell))
                }

                it("hidden if author doesn't allow it") {
                    let author: User = stub(["id" : "1", "hasLovesEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.lovesItem.customView).toNot(beVisibleIn(cell))
                }

                it("hidden if author doesn't allow it in grid view") {
                    let author: User = stub(["id" : "1", "hasLovesEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.lovesItem.customView).toNot(beVisibleIn(cell))
                }

                it("enabled if author is current user") {
                    let author: User = stub(["id" : "1", "hasLovesEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.lovesControl.isEnabled) == true
                    expect(cell.lovesItem.customView).to(beVisibleIn(cell))
                }

                it("enabled if author is current user in grid view") {
                    let author: User = stub(["id" : "1", "hasLovesEnabled" : true])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.lovesControl.isEnabled) == true
                    expect(cell.lovesItem.customView).to(beVisibleIn(cell))
                }

                it("hidden if author is current user, and loving isn't allowed") {
                    let author: User = stub(["id" : "1", "hasLovesEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.lovesItem.customView).toNot(beVisibleIn(cell))
                }

                it("hidden if author is current user, and loving isn't allowed in grid view") {
                    let author: User = stub(["id" : "1", "hasLovesEnabled" : false])
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "author" : author,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .starred, indexPath: IndexPath(item: 0, section: 0), currentUser: author)

                    expect(cell.lovesItem.customView).toNot(beVisibleIn(cell))
                }
            }

            context("loading") {

                it("configures a stream footer cell") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 55
                    ])
                    let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                    // set the state to loading
                    item.state = .loading

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.views) == "9"
                    expect(cell.reposts) == "4"
                    expect(cell.comments) == "6"

                    // commentsButton should be selected when the state is loading
                    expect(cell.commentsControl.isSelected).to(beTrue())
                }
            }

            context("not loading") {

                context("expanded") {

                    it("configures a stream footer cell") {
                        let post: Post = stub([
                            "id" : "768",
                            "viewsCount" : 9,
                            "repostsCount" : 4,
                            "commentsCount" : 6,
                            "lovesCount" : 55
                        ])
                        let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                        // set the state to expanded
                        item.state = .expanded

                        StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.commentsOpened).to(beTrue())
                        expect(cell.views) == "9"
                        expect(cell.reposts) == "4"
                        expect(cell.comments) == "6"

                        // commentsButton should be selected when expanded
                        expect(cell.commentsControl.isSelected).to(beTrue())
                    }

                }

                context("not expanded") {

                    it("configures a stream footer cell") {
                        let post: Post = stub([
                            "id" : "768",
                            "viewsCount" : 9,
                            "repostsCount" : 4,
                            "commentsCount" : 6,
                            "lovesCount" : 55
                        ])
                        let cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .footer)

                        // set the state to none
                        item.state = .none

                        StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.commentsOpened).to(beFalse())
                        expect(item.state) == StreamCellState.collapsed
                        expect(cell.views) == "9"
                        expect(cell.reposts) == "4"
                        expect(cell.comments) == "6"
                        expect(cell.commentsControl.isSelected).to(beFalse())
                    }
                }
            }
        }
    }
}
