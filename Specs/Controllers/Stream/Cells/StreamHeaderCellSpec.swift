////
///  StreamHeaderCellSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots


class StreamHeaderCellSpec: QuickSpec {
    enum Owner {
        case me
        case other
    }
    enum Content {
        case post
        case repost
        case comment
    }
    enum Style {
        case grid
        case wide
        case detail
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
                    ("own post", owner: .me, content: .post, category: false, follow: false, style: .wide),
                    ("own post in detail", owner: .me, content: .post, category: false, follow: false, style: .detail),
                    ("own post in grid", owner: .me, content: .post, category: false, follow: false, style: .grid),
                    ("own post w category", owner: .me, content: .post, category: true, follow: false, style: .wide),
                    ("own post w category in detail", owner: .me, content: .post, category: true, follow: false, style: .detail),
                    ("own post w category in grid", owner: .me, content: .post, category: true, follow: false, style: .grid),
                    ("own repost", owner: .me, content: .repost, category: false, follow: false, style: .wide),
                    ("own repost in detail", owner: .me, content: .repost, category: false, follow: false, style: .detail),
                    ("own repost in grid", owner: .me, content: .repost, category: false, follow: false, style: .grid),
                    ("own repost w category", owner: .me, content: .repost, category: true, follow: false, style: .wide),
                    ("own repost w category in detail", owner: .me, content: .repost, category: true, follow: false, style: .detail),
                    ("own repost w category in grid", owner: .me, content: .repost, category: true, follow: false, style: .grid),
                    ("own comment", owner: .me, content: .comment, category: false, follow: false, style: .wide),
                    ("own comment in detail", owner: .me, content: .comment, category: false, follow: false, style: .detail),
                    ("own comment in grid", owner: .me, content: .comment, category: false, follow: false, style: .grid),
                    ("other post", owner: .other, content: .post, category: false, follow: false, style: .wide),
                    ("other post in detail", owner: .other, content: .post, category: false, follow: false, style: .detail),
                    ("other post in grid", owner: .other, content: .post, category: false, follow: false, style: .grid),
                    ("other post w follow in detail", owner: .other, content: .post, category: false, follow: true, style: .detail),
                    ("other post w category", owner: .other, content: .post, category: true, follow: false, style: .wide),
                    ("other post w category in detail", owner: .other, content: .post, category: true, follow: false, style: .detail),
                    ("other post w category in grid", owner: .other, content: .post, category: true, follow: false, style: .grid),
                    ("other repost", owner: .other, content: .repost, category: false, follow: false, style: .wide),
                    ("other repost in detail", owner: .other, content: .repost, category: false, follow: false, style: .detail),
                    ("other repost in grid", owner: .other, content: .repost, category: false, follow: false, style: .grid),
                    ("other repost w follow in detail", owner: .other, content: .repost, category: false, follow: true, style: .detail),
                    ("other repost w category", owner: .other, content: .repost, category: true, follow: false, style: .wide),
                    ("other repost w category in detail", owner: .other, content: .repost, category: true, follow: false, style: .detail),
                    ("other repost w category in grid", owner: .other, content: .repost, category: true, follow: false, style: .grid),
                    ("other comment", owner: .other, content: .comment, category: false, follow: false, style: .wide),
                    ("other comment in detail", owner: .other, content: .comment, category: false, follow: false, style: .detail),
                    ("other comment in grid", owner: .other, content: .comment, category: false, follow: false, style: .grid),
                ]
                let detailFrame = CGRect(x: 0, y: 0, width: 320, height: StreamCellType.header.oneColumnHeight)
                let commentFrame = CGRect(x: 0, y: 0, width: 320, height: StreamCellType.commentHeader.oneColumnHeight)
                let gridFrame = CGRect(x: 0, y: 0, width: 154, height: StreamCellType.header.multiColumnHeight)
                for (desc, owner, content, hasCategory, hasFollow, style) in expectations {
                    it("has valid screenshot for \(desc)") {
                        let inGrid: Bool
                        let inDetail: Bool
                        switch style {
                            case .grid:
                                inGrid = true
                                inDetail = false
                            case .detail:
                                inGrid = false
                                inDetail = true
                            case .wide:
                                inGrid = false
                                inDetail = false
                        }

                        let subject = StreamHeaderCell.loadFromNib() as StreamHeaderCell
                        if inGrid {
                            subject.frame = gridFrame
                        }
                        else if content == .comment {
                            subject.frame = commentFrame
                        }
                        else {
                            subject.frame = detailFrame
                        }
                        subject.ownPost = false
                        subject.ownComment = false
                        subject.isGridLayout = inGrid
                        subject.followButtonVisible = hasFollow

                        if content == .comment {
                            subject.showUsername = true
                            subject.avatarHeight = 30.0
                            subject.chevronHidden = false
                            subject.goToPostView.isHidden = true
                            subject.canReply = true
                        }
                        else {
                            subject.showUsername = !inDetail
                            subject.avatarHeight = inGrid ? 30 : 40
                            subject.chevronHidden = true
                            subject.goToPostView.isHidden = false
                            subject.canReply = false
                        }

                        let user: User?
                        let repostedBy: User?
                        let cellCategory: Ello.Category?

                        if owner == .me {
                            user = me
                            switch content {
                            case .post:
                                subject.ownPost = true
                            case .repost:
                                subject.ownPost = true
                            case .comment:
                                subject.ownComment = true
                            }
                        }
                        else {
                            user = other
                        }

                        if content == .comment {
                            subject.showUsername = true
                            subject.avatarHeight = 30.0
                            subject.chevronHidden = false
                            subject.goToPostView.isHidden = true
                            subject.canReply = true
                        }
                        else {
                            subject.showUsername = !inDetail
                            subject.avatarHeight = inGrid ? 30 : 40
                            subject.chevronHidden = true
                            subject.goToPostView.isHidden = false
                            subject.canReply = false
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
                        subject.setDetails(user: user, repostedBy: repostedBy, category: cellCategory)
                        subject.avatarButton.setImage(UIImage(named: "specs-avatar", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)

                        subject.layoutIfNeeded()
                        showView(subject)
                        expect(subject).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
