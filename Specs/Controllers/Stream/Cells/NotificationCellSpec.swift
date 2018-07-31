////
///  NotificationCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class NotificationCellSpec: QuickSpec {
    override func spec() {
        describe("NotificationCell") {
            it("should set its titleTextView height") {
                let subject = NotificationCell()
                subject.frame.size = CGSize(width: 320, height: 40)
                let author: User = .stub(["username": "ello"])
                let post: Post = .stub(["author": author])
                let notification: Notification = stub([
                    "kind": Notification.Kind.postMentionNotification,
                    "subject": post,
                    ])
                subject.title = NotificationAttributedTitle.from(notification: notification)
                subject.layoutIfNeeded()

                expect(subject.titleTextView.frame.size.height) == 17
            }

            it("should set its titleTextView height") {
                let subject = NotificationCell()
                subject.frame.size = CGSize(width: 160, height: 40)
                let author: User = .stub(["username": "ello"])
                let post: Post = .stub(["author": author])
                let notification: Notification = stub([
                    "kind": Notification.Kind.postMentionNotification,
                    "subject": post,
                    ])
                subject.title = NotificationAttributedTitle.from(notification: notification)
                subject.layoutIfNeeded()

                expect(subject.titleTextView.frame.size.height) == 51
            }

            context("snapshots") {
                var author: User!
                var post: Post!
                var notification: Notification!
                var title: NSAttributedString!
                var createdAt: Date!
                var aspectRatio: CGFloat!
                var image: UIImage!

                beforeEach {
                    author = User.stub(["username": "ello"])
                    post = Post.stub(["author": author])
                    notification = Notification.stub([
                        "kind": Notification.Kind.postMentionNotification,
                        "subject": post,
                        ])
                    title = NotificationAttributedTitle.from(notification: notification)
                    createdAt = Date(timeIntervalSinceNow: -86_460)
                    aspectRatio = 1
                    image = UIImage.imageWithColor(.blue, size: CGSize(width: 300, height: 300))!
                }

                let expectations: [(hasImage: Bool, canReply: Bool, buyButton: Bool)] = [
                    (hasImage: true, canReply: false, buyButton: false),
                    (hasImage: true, canReply: false, buyButton: true),
                    (hasImage: true, canReply: true, buyButton: false),
                    (hasImage: true, canReply: true, buyButton: true),
                ]
                for (hasImage, canReply, buyButton) in expectations {
                    it("notification\(hasImage ? " with image" : "")\(canReply ? " with reply button" : "")\(buyButton ? " with buy button" : "")") {
                        let subject = NotificationCell()
                        subject.title = title
                        subject.createdAt = createdAt
                        subject.user = author
                        subject.canReplyToComment = canReply
                        subject.canBackFollow = false
                        subject.post = post
                        subject.comment = nil
                        subject.aspectRatio = aspectRatio
                        subject.buyButtonVisible = buyButton
                        if hasImage {
                            subject.imageURL = URL(string: "http://ello.co/image.png")
                            subject.notificationImageView.image = image
                        }

                        expectValidSnapshot(subject, device: .phone6_Portrait)
                    }
                }
            }
        }
    }
}
