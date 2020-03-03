////
///  EditorialsViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class EditorialsViewControllerSpec: QuickSpec {
    override func spec() {
        describe("EditorialsViewController") {
            var subject: EditorialsViewController!

            beforeEach {
                subject = EditorialsViewController(usage: .loggedIn)
            }

            let setupEditorialCell: (Editorial) -> EditorialCell = { editorial in
                let item = StreamCellItem(jsonable: editorial, type: .editorial(editorial.kind))
                subject.streamViewController.appendStreamCellItems([item])
                return subject.streamViewController.collectionView.cellForItem(
                    at: IndexPath(row: 0, section: 0)
                ) as! EditorialCell
            }

            describe("opening EditorialCells") {
                it("can open internal links") {
                    let editorial = Editorial.stub([
                        "kind": "internal",
                        "url": "https://ello.co",
                    ])
                    var posted = false
                    let observer = NotificationObserver(notification: InternalWebNotification) {
                        _ in
                        posted = true
                    }
                    let cell = setupEditorialCell(editorial)
                    subject.editorialTapped(cellContent: cell.editorialContentView!)
                    observer.removeObserver()
                    expect(posted) == true
                }
                it("can open external links") {
                    let editorial = Editorial.stub([
                        "kind": "external",
                        "url": "https://test.com",
                    ])
                    var posted = false
                    let observer = NotificationObserver(notification: ExternalWebNotification) {
                        _ in
                        posted = true
                    }
                    let cell = setupEditorialCell(editorial)
                    subject.editorialTapped(cellContent: cell.editorialContentView!)
                    observer.removeObserver()
                    expect(posted) == true
                }
                it("can open a post") {
                    let postId = "postId"
                    let editorial = Editorial.stub([
                        "kind": "post",
                        "post": Post.stub(["id": postId]),
                    ])
                    let nav = FakeNavigationController(rootViewController: subject)
                    let cell = setupEditorialCell(editorial)
                    subject.editorialTapped(cellContent: cell.editorialContentView!)
                    let postController = nav.pushedViewController as? PostDetailViewController
                    expect(postController).notTo(beNil())
                    expect(postController?.postParam) == postId
                }
                it("can open a post within a post stream") {
                    let postId = "postId"
                    let editorial = Editorial.stub([
                        "kind": "post_stream",
                        "posts": [Post.stub(["id": "0"]), Post.stub(["id": postId])],
                    ])
                    let nav = FakeNavigationController(rootViewController: subject)
                    let cell = setupEditorialCell(editorial)
                    subject.editorialTapped(index: 1, cell: cell)
                    let postController = nav.pushedViewController as? PostDetailViewController
                    expect(postController).notTo(beNil())
                    expect(postController?.postParam) == postId
                }
                it("sets invite info after submitting invitations") {
                    let editorial = Editorial.stub([
                        "kind": "invite",
                    ])
                    editorial.invite = (emails: "emails", sent: nil)
                    let cell = setupEditorialCell(editorial)
                    subject.submitInvite(cell: cell, emails: "email@email.com")
                    expect(editorial.invite?.emails) == ""
                    expect(editorial.invite?.sent).notTo(beNil())
                }
                it("shows the join controller on invalid inputs") {
                    let editorial = Editorial.stub([
                        "kind": "join",
                    ])
                    let cell = setupEditorialCell(editorial)
                    let nav = FakeNavigationController(rootViewController: subject)
                    subject.submitJoin(cell: cell, email: "email", username: "", password: "")
                    let joinController = nav.pushedViewController as? JoinViewController
                    expect(joinController).notTo(beNil())
                    expect(joinController?.screen.email) == "email"
                }
                describe("lots of ways to show a post") {
                    var content: EditorialPostCell!
                    var post: Post!

                    beforeEach {
                        let postId = "postId"
                        post = Post.stub(["id": postId])
                        let editorial = Editorial.stub([
                            "kind": "post",
                            "post": post,
                        ])
                        let cell = setupEditorialCell(editorial)
                        content = cell.editorialContentView as? EditorialPostCell
                    }
                    it("tapping comments") {
                        let nav = FakeNavigationController(rootViewController: subject)
                        subject.commentTapped(post: post, cell: content)
                        let postController = nav.pushedViewController as? PostDetailViewController
                        expect(postController).notTo(beNil())
                    }
                    it("tapping repost") {
                        let nav = FakeNavigationController(rootViewController: subject)
                        subject.repostTapped(post: post, cell: content)
                        let postController = nav.pushedViewController as? PostDetailViewController
                        expect(postController).notTo(beNil())
                    }
                }
            }
        }
    }
}
