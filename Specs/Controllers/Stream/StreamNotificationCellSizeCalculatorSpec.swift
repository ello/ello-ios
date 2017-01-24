////
///  StreamNotificationCellSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamNotificationCellSizeCalculatorSpec : QuickSpec {
    class MockUIWebView: UIWebView {
        var mockHeight: CGFloat = 50

        override func loadHTMLString(_ html: String, baseURL: URL?) {
            delegate?.webViewDidFinishLoad?(self)
        }

        override func stringByEvaluatingJavaScript(from js: String) -> String? {
            if js.contains("offsetWidth") { return "\(frame.size.width)" }
            if js.contains("offsetHeight") { return "\(mockHeight)" }
            return super.stringByEvaluatingJavaScript(from: js)
        }
    }

    override func spec() {
        describe("StreamNotificationCellSizeCalculator") {
            let user: User = stub([:])
            let text: TextRegion = stub(["content": "Lorem ipsum dolor sit amet."])
            let image: ImageRegion = stub(["asset": Asset.stub(["attachment": Attachment.stub(["width": 2000, "height": 2000])])])
            let postWithText: Post = stub(["summary": [text], "content": [text], "author": user])
            let postWithImage: Post = stub(["summary": [image], "content": [image], "author": user])
            let postWithTextAndImage: Post = stub(["summary": [text, image], "content": [text, image], "author": user])
            let commentWithText: ElloComment = stub([
                "parentPost": postWithText,
                "content": text,
                "author": user,
                ])
            var subject: StreamNotificationCellSizeCalculator!
            beforeEach {
                subject = StreamNotificationCellSizeCalculator(webView: MockUIWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 568)))
            }

            it("should return minimum size") {
                let activity: Activity = stub(["kind": "new_follower_post", "subject": user])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                subject.processCells([item], withWidth: 320) { }
                expect(item.calculatedCellHeights.webContent) == 0
                expect(item.calculatedCellHeights.oneColumn) == 69
                expect(item.calculatedCellHeights.multiColumn) == 69
            }
            it("should return size that accounts for a message") {
                let activity: Activity = stub(["kind": "repost_notification", "subject": postWithText])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                subject.processCells([item], withWidth: 320) { }
                expect(item.calculatedCellHeights.oneColumn) == 119
                expect(item.calculatedCellHeights.multiColumn) == 119
            }
            it("should return size that accounts for an image") {
                let activity: Activity = stub(["kind": "repost_notification", "subject": postWithImage])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                subject.processCells([item], withWidth: 320) { }
                expect(item.calculatedCellHeights.oneColumn) == 136
                expect(item.calculatedCellHeights.multiColumn) == 136
            }
            it("should return size that accounts for an image with text") {
                let activity: Activity = stub(["kind": "repost_notification", "subject": postWithTextAndImage])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                subject.processCells([item], withWidth: 320) { }
                expect(item.calculatedCellHeights.webContent) == 50
                expect(item.calculatedCellHeights.oneColumn) == 136
                expect(item.calculatedCellHeights.multiColumn) == 136
            }
            it("should return size that accounts for a reply button") {
                let activity: Activity = stub(["kind": "comment_notification", "subject": commentWithText])
                let notification: Ello.Notification = stub(["activity": activity])
                let item = StreamCellItem(jsonable: notification, type: .notification)
                subject.processCells([item], withWidth: 320) { }
                expect(item.calculatedCellHeights.webContent) == 50
                expect(item.calculatedCellHeights.oneColumn) == 159
                expect(item.calculatedCellHeights.multiColumn) == 159
            }
        }
    }
}
