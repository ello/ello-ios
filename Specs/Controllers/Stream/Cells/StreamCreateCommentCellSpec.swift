////
///  StreamCreateCommentCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamCreateCommentCellSpec: QuickSpec {
    override func spec() {
        describe("StreamCreateCommentCell") {
            var subject: StreamCreateCommentCell!
            beforeEach {
                subject = StreamCreateCommentCell()
                subject.avatarView.image = UIImage.imageWithColor(.blue)!
            }
            describe("snapshots") {
                it("has a valid default") {
                    subject.watchVisibility = .hidden
                    subject.replyAllVisibility = .hidden
                    expectValidSnapshot(subject, device: .custom(CGSize(width: 375, height: StreamCellType.createComment.oneColumnHeight)))
                }
                it("has a valid reply all button") {
                    subject.watchVisibility = .hidden
                    subject.replyAllVisibility = .enabled
                    expectValidSnapshot(subject, device: .custom(CGSize(width: 375, height: StreamCellType.createComment.oneColumnHeight)))
                }
                it("has a valid not-watching button") {
                    subject.watchVisibility = .enabled
                    subject.replyAllVisibility = .hidden
                    subject.watching = false
                    expectValidSnapshot(subject, device: .custom(CGSize(width: 375, height: StreamCellType.createComment.oneColumnHeight)))
                }
                it("has a valid watching button") {
                    subject.watchVisibility = .enabled
                    subject.replyAllVisibility = .hidden
                    subject.watching = true
                    expectValidSnapshot(subject, device: .custom(CGSize(width: 375, height: StreamCellType.createComment.oneColumnHeight)))
                }
            }
        }
    }
}
