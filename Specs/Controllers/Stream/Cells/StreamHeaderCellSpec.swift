////
///  StreamHeaderCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamHeaderCellSpec: QuickSpec {
    enum Owner {
        case me
        case other
    }
    enum Content {
        case post
        case repost
    }
    enum Style {
        case grid
        case list
        case detail
        case submission
    }
    override func spec() {
        describe("StreamHeaderCell") {
            describe("snapshots") {
                let me: User = stub(["username": "me"])
                let other: User = stub(["username": "other"])
                let reposter: User = stub(["username": "reposter"])
                let category: Ello.Category = stub(["name": "Illustrations"])
                let expectations: [
                    (String, owner: Owner, content: Content, category: Bool, follow: Bool, style: Style)
                ] = [
                    ("own post", owner: .me, content: .post, category: false, follow: false, style: .list),
                    ("own post in detail", owner: .me, content: .post, category: false, follow: false, style: .detail),
                    ("own post in grid", owner: .me, content: .post, category: false, follow: false, style: .grid),
                    ("own post w category", owner: .me, content: .post, category: true, follow: false, style: .list),
                    ("own post w category in detail", owner: .me, content: .post, category: true, follow: false, style: .detail),
                    ("own post w category in grid", owner: .me, content: .post, category: true, follow: false, style: .grid),
                    ("own repost", owner: .me, content: .repost, category: false, follow: false, style: .list),
                    ("own repost in detail", owner: .me, content: .repost, category: false, follow: false, style: .detail),
                    ("own repost in grid", owner: .me, content: .repost, category: false, follow: false, style: .grid),
                    ("own repost w category", owner: .me, content: .repost, category: true, follow: false, style: .list),
                    ("own repost w category in detail", owner: .me, content: .repost, category: true, follow: false, style: .detail),
                    ("own repost w category in grid", owner: .me, content: .repost, category: true, follow: false, style: .grid),
                    ("artist invite post", owner: .other, content: .post, category: false, follow: false, style: .submission),
                    ("other post", owner: .other, content: .post, category: false, follow: false, style: .list),
                    ("other post in detail", owner: .other, content: .post, category: false, follow: false, style: .detail),
                    ("other post in grid", owner: .other, content: .post, category: false, follow: false, style: .grid),
                    ("other post w follow in detail", owner: .other, content: .post, category: false, follow: true, style: .detail),
                    ("other post w category", owner: .other, content: .post, category: true, follow: false, style: .list),
                    ("other post w category in detail", owner: .other, content: .post, category: true, follow: false, style: .detail),
                    ("other post w category in grid", owner: .other, content: .post, category: true, follow: false, style: .grid),
                    ("other repost", owner: .other, content: .repost, category: false, follow: false, style: .list),
                    ("other repost in detail", owner: .other, content: .repost, category: false, follow: false, style: .detail),
                    ("other repost in grid", owner: .other, content: .repost, category: false, follow: false, style: .grid),
                    ("other repost w follow in detail", owner: .other, content: .repost, category: false, follow: true, style: .detail),
                    ("other repost w category", owner: .other, content: .repost, category: true, follow: false, style: .list),
                    ("other repost w category in detail", owner: .other, content: .repost, category: true, follow: false, style: .detail),
                    ("other repost w category in grid", owner: .other, content: .repost, category: true, follow: false, style: .grid),
                ]
                let detailFrame = CGRect(x: 0, y: 0, width: 320, height: StreamCellType.streamHeader.oneColumnHeight)
                let gridFrame = CGRect(x: 0, y: 0, width: 154, height: StreamCellType.streamHeader.multiColumnHeight)
                for (desc, owner, content, hasCategory, hasFollow, style) in expectations {
                    it("has valid screenshot for \(desc)") {
                        let inGrid: Bool
                        let inDetail: Bool
                        var isSubmission = false
                        switch style {
                            case .grid:
                                inGrid = true
                                inDetail = false
                            case .list:
                                inGrid = false
                                inDetail = false
                            case .detail:
                                inGrid = false
                                inDetail = true
                            case .submission:
                                inGrid = false
                                inDetail = true
                                isSubmission = true
                        }

                        let subject = StreamHeaderCell()
                        if inGrid {
                            subject.frame = gridFrame
                        }
                        else {
                            subject.frame = detailFrame
                        }
                        subject.isGridView = inGrid
                        subject.followButtonVisible = hasFollow

                        subject.showUsername = !inDetail
                        subject.chevronHidden = true

                        let user: User?
                        let repostedBy: User?
                        let cellCategory: Ello.Category?

                        if owner == .me {
                            user = me
                        }
                        else {
                            user = other
                        }

                        if content == .repost {
                            repostedBy = reposter
                        }
                        else {
                            repostedBy = nil
                        }

                        if hasCategory {
                            cellCategory = category
                        }
                        else {
                            cellCategory = nil
                        }

                        subject.timeStamp = "1m"
                        subject.setDetails(user: user, repostedBy: repostedBy, category: cellCategory, isSubmission: isSubmission)
                        subject.specs().avatarButton.setImage(specImage(named: "specs-avatar"), for: .normal)

                        expectValidSnapshot(subject)
                    }
                }
            }

            describe("avatarHeight") {

                it("is correct for list mode") {
                    expect(StreamHeaderCell.avatarHeight(isGridView: false)) == 40
                }

                it("is correct for grid mode") {
                    expect(StreamHeaderCell.avatarHeight(isGridView: true)) == 30
                }
            }
        }
    }
}
