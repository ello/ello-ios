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
                subject.frame = CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: StreamCellType.createComment.oneColumnHeight)
                )
                subject.avatarView.image = UIImage.imageWithColor(.blue)!
            }
            describe("snapshots") {
                it("has a valid default") {
                    subject.watchVisibility = .hidden
                    subject.replyAllVisibility = .hidden
                    expectValidSnapshot(subject)
                }
                it("has a valid reply all button") {
                    subject.watchVisibility = .hidden
                    subject.replyAllVisibility = .enabled
                    expectValidSnapshot(subject)
                }
                it("has a valid not-watching button") {
                    subject.watchVisibility = .enabled
                    subject.replyAllVisibility = .hidden
                    subject.isWatching = false
                    expectValidSnapshot(subject)
                }
                it("has a valid watching button") {
                    subject.watchVisibility = .enabled
                    subject.replyAllVisibility = .hidden
                    subject.isWatching = true
                    expectValidSnapshot(subject)
                }
            }
        }
    }
}
