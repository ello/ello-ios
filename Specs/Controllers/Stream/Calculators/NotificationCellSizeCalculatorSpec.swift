////
///  NotificationCellSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class NotificationCellSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("NotificationCellSizeCalculator") {
            var user: User!
            var text: TextRegion!
            var image: ImageRegion!
            var postWithText: Post!
            var postWithImage: Post!
            var postWithTextAndImage: Post!
            var commentWithText: ElloComment!

            beforeEach {
                user = User.stub([:])
                text = TextRegion.stub(["content": "Lorem ipsum dolor sit amet."])
                image = ImageRegion.stub(["asset": Asset.stub(["attachment": Attachment.stub(["width": 2000, "height": 2000])])])
                postWithText = Post.stub(["summary": [text], "content": [text], "author": user])
                postWithImage = Post.stub(["summary": [image], "content": [image], "author": user])
                postWithTextAndImage = Post.stub(["summary": [text, image], "content": [text, image], "author": user])
                commentWithText = ElloComment.stub([
                   "parentPost": postWithText,
                   "content": text,
                   "author": user,
               ])
            }

            it("should return minimum size") {
                let activity: Activity = stub(["kind": "new_follower_post", "subject": user])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                let calculator = item.sizeCalculator(streamKind: .notifications(category: nil), width: 320, columnCount: 1) as! NotificationCellSizeCalculator
                calculator.webView = MockUIWebView()
                calculator.begin {}
                expect(item.calculatedCellHeights.webContent) == 0
                expect(item.calculatedCellHeights.oneColumn) == 69
                expect(item.calculatedCellHeights.multiColumn) == 69
            }
            it("should return size that accounts for a message") {
                let activity: Activity = stub(["kind": "repost_notification", "subject": postWithText])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                let calculator = item.sizeCalculator(streamKind: .notifications(category: nil), width: 320, columnCount: 1) as! NotificationCellSizeCalculator
                calculator.webView = MockUIWebView()
                calculator.begin {}
                expect(item.calculatedCellHeights.oneColumn) == 119
                expect(item.calculatedCellHeights.multiColumn) == 119
            }
            it("should return size that accounts for an image") {
                let activity: Activity = stub(["kind": "repost_notification", "subject": postWithImage])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                let calculator = item.sizeCalculator(streamKind: .notifications(category: nil), width: 320, columnCount: 1) as! NotificationCellSizeCalculator
                calculator.webView = MockUIWebView()
                calculator.begin {}
                expect(item.calculatedCellHeights.oneColumn) == 136
                expect(item.calculatedCellHeights.multiColumn) == 136
            }
            it("should return size that accounts for an image with text") {
                let activity: Activity = stub(["kind": "repost_notification", "subject": postWithTextAndImage])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                let calculator = item.sizeCalculator(streamKind: .notifications(category: nil), width: 320, columnCount: 1) as! NotificationCellSizeCalculator
                calculator.webView = MockUIWebView()
                calculator.begin {}
                expect(item.calculatedCellHeights.webContent) == 50
                expect(item.calculatedCellHeights.oneColumn) == 136
                expect(item.calculatedCellHeights.multiColumn) == 136
            }
            it("should return size that accounts for a reply button") {
                let activity: Activity = stub(["kind": "comment_notification", "subject": commentWithText])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                let calculator = item.sizeCalculator(streamKind: .notifications(category: nil), width: 320, columnCount: 1) as! NotificationCellSizeCalculator
                calculator.webView = MockUIWebView()
                calculator.begin {}
                expect(item.calculatedCellHeights.webContent) == 50
                expect(item.calculatedCellHeights.oneColumn) == 159
                expect(item.calculatedCellHeights.multiColumn) == 159
            }
        }
    }
}
