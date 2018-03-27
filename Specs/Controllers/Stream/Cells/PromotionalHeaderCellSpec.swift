////
///  PromotionalHeaderCellSpec.swift
//

@testable import Ello
import Quick
import Nimble
import PINRemoteImage
import PINCache

class PromotionalHeaderCellSpec: QuickSpec {

    enum Style {
        case narrow
        case wide
        case iPad

        var width: CGFloat {
            switch self {
            case .narrow: return 320
            case .wide: return 375
            case .iPad: return 768
            }
        }

        func frame(_ height: CGFloat)  -> CGRect {
            return CGRect(x: 0, y: 0, width: self.width, height: height)
        }
    }

    override func spec() {
        describe("PromotionalHeaderCell") {
            var subject: PromotionalHeaderCell!

            func setImages() {
                subject.specs().postedByAvatar.setImage(specImage(named: "specs-avatar"), for: .normal)
                subject.setImage(specImage(named: "specs-category-image.jpg")!)
            }

            describe("snapshots") {

                let shortBody = "Aliquam erat volutpat. Vestibulum ante."
                let longBody = "Nullam scelerisque pulvinar enim. Aliquam erat volutpat. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis eleifend lobortis sapien vitae ultrices. Interdum et malesuada fames ac ante ipsum primis in faucibus. Mauris interdum accumsan laoreet. Mauris sed massa est."
                let shortCtaCaption = "tap for more"
                let longCtaCaption = "tap for more and then you should do something else"

                let expectations: [
                    (String, kind: PageHeader.Kind, name: String, isSponsored: Bool, body: String, ctaCaption: String, style: Style)
                ] = [
                    ("category not sponsored, narrow", kind: .category, name: "A Longer Title Goes Here, does it wrap?", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("category not sponsored, wide", kind: .category, name: "Art", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("category not sponsored, iPad", kind: .category, name: "Art", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("category sponsored, narrow", kind: .category, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("category sponsored, wide", kind: .category, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("category sponsored, iPad", kind: .category, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("category long body, narrow", kind: .category, name: "Art", isSponsored: true, body: longBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("category long body, wide", kind: .category, name: "Art", isSponsored: true, body: longBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("category long body, iPad", kind: .category, name: "Art", isSponsored: true, body: longBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("category long body, long cta caption, narrow", kind: .category, name: "Art", isSponsored: true, body: longBody, ctaCaption: longCtaCaption, style: .narrow),
                    ("category long body, long cta caption, wide", kind: .category, name: "Art", isSponsored: true, body: longBody, ctaCaption: longCtaCaption, style: .wide),
                    ("category long body, long cta caption, iPad", kind: .category, name: "Art", isSponsored: true, body: longBody, ctaCaption: longCtaCaption, style: .iPad),

                    ("generic not sponsored, narrow", kind: .generic, name: "A Longer Title Goes Here, does it wrap?", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("generic not sponsored, wide", kind: .generic, name: "Art", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("generic not sponsored, iPad", kind: .generic, name: "Art", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("generic sponsored, narrow", kind: .generic, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("generic sponsored, wide", kind: .generic, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("generic sponsored, iPad", kind: .generic, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("generic long body, narrow", kind: .generic, name: "Art", isSponsored: false, body: longBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("generic long body, wide", kind: .generic, name: "Art", isSponsored: false, body: longBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("generic long body, iPad", kind: .generic, name: "Art", isSponsored: false, body: longBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("generic long body, long cta caption, narrow", kind: .generic, name: "Art", isSponsored: false, body: longBody, ctaCaption: longCtaCaption, style: .narrow),
                    ("generic long body, long cta caption, wide", kind: .generic, name: "Art", isSponsored: false, body: longBody, ctaCaption: longCtaCaption, style: .wide),
                    ("generic long body, long cta caption, iPad", kind: .generic, name: "Art", isSponsored: false, body: longBody, ctaCaption: longCtaCaption, style: .iPad)
                ]
                for (desc, kind, name, isSponsored, body, ctaCaption, style) in expectations {

                    it("has valid screenshot for \(desc)") {

                        let user: User = User.stub(["username" : "bob"])
                        let xhdpi = Attachment.stub([
                            "url": "http://ello.co/avatar.png",
                            "height": 0,
                            "width": 0,
                            "type": "png",
                            "size": 0]
                        )
                        let image = Asset.stub(["xhdpi": xhdpi])

                        let pageHeader = PageHeader.stub([
                            "header": name,
                            "user": user,
                            "subheader": body,
                            "ctaCaption": ctaCaption,
                            "ctaURL": "http://google.com",
                            "image": image,
                            "kind": kind,
                        ])
                        pageHeader.isSponsored = isSponsored

                        let height = PromotionalHeaderCellSizeCalculator.calculatePageHeaderHeight(pageHeader, htmlHeight: nil, cellWidth: style.width)
                        subject = PromotionalHeaderCell(frame: style.frame(height))
                        let item = StreamCellItem(jsonable: pageHeader, type: .promotionalHeader)
                        PromotionalHeaderCellPresenter.configure(subject, streamCellItem: item, streamKind: .category(.category("Design"), .featured), indexPath: IndexPath(item: 0, section: 0), currentUser: nil)
                        setImages()

                        expectValidSnapshot(subject)
                    }
                }
            }
        }
    }
}
