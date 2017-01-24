////
///  StreamImageCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamImageCellSpec: QuickSpec {
    override func spec() {
        describe("StreamImageCell") {
            let image = UIImage.imageWithColor(.blue, size: CGSize(width: 500, height: 300))!

            let expectations: [(listView: Bool, isComment: Bool, isRepost: Bool, buyButton: Bool)] = [
                (listView: true, isComment: false, isRepost: false, buyButton: false),
                (listView: true, isComment: false, isRepost: false, buyButton: true),
                (listView: true, isComment: false, isRepost: true, buyButton: false),
                (listView: true, isComment: false, isRepost: true, buyButton: true),
                (listView: true, isComment: true, isRepost: false, buyButton: false),
                (listView: false, isComment: false, isRepost: false, buyButton: false),
                (listView: false, isComment: false, isRepost: false, buyButton: true),
                (listView: false, isComment: false, isRepost: true, buyButton: false),
                (listView: false, isComment: false, isRepost: true, buyButton: true),
                (listView: false, isComment: true, isRepost: false, buyButton: false),
            ]
            for (listView, isComment, isRepost, buyButton) in expectations {
                it("\(listView ? "list" : "grid") view \(isComment ? "comment" : (isRepost ? "repost" : "post"))\(buyButton ? " with buy button" : "") should match snapshot") {
                    let subject = StreamImageCell.loadFromNib() as StreamImageCell
                    subject.isGridView = !listView
                    subject.marginType = (isComment ? .comment : (isRepost ? .repost : .post))
                    subject.setImage(image)
                    if buyButton {
                        subject.buyButtonURL = URL(string: "http://ello.co")
                    }
                    expectValidSnapshot(subject, device: .custom(CGSize(width: 375, height: 225)))
                }
            }
        }
    }
}
