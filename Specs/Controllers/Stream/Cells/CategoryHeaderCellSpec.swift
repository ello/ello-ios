////
///  CategoryHeaderCellSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots
import PINRemoteImage
import PINCache

class CategoryHeaderCellSpec: QuickSpec {

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

        describe("CategoryHeaderCell") {
            var subject: CategoryHeaderCell!

            func setImages() {
                subject.postedByAvatar.setImage(UIImage(named: "specs-avatar", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                subject.setImage(UIImage(named: "specs-category-image.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!)
            }

            describe("snapshots") {

                let shortBody = "Aliquam erat volutpat. Vestibulum ante."
                let longBody = "Nullam scelerisque pulvinar enim. Aliquam erat volutpat. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis eleifend lobortis sapien vitae ultrices. Interdum et malesuada fames ac ante ipsum primis in faucibus. Mauris interdum accumsan laoreet. Mauris sed massa est."
                let shortCtaCaption = "tap for more"
                let longCtaCaption = "tap for more and then you should do something else"

                let expectations: [
                    (String, type: StreamCellType, name: String, isSponsored: Bool, body: String, ctaCaption: String, style: Style)
                ] = [
                    ("category not sponsored, narrow", type: .categoryPromotionalHeader, name: "A Longer Title Goes Here, does it wrap?", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("category not sponsored, wide", type: .categoryPromotionalHeader, name: "Art", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("category not sponsored, iPad", type: .categoryPromotionalHeader, name: "Art", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("category sponsored, narrow", type: .categoryPromotionalHeader, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("category sponsored, wide", type: .categoryPromotionalHeader, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("category sponsored, iPad", type: .categoryPromotionalHeader, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("category long body, narrow", type: .categoryPromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("category long body, wide", type: .categoryPromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("category long body, iPad", type: .categoryPromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("category long body, long cta caption, narrow", type: .categoryPromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: longCtaCaption, style: .narrow),
                    ("category long body, long cta caption, wide", type: .categoryPromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: longCtaCaption, style: .wide),
                    ("category long body, long cta caption, iPad", type: .categoryPromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: longCtaCaption, style: .iPad),

                    ("page not sponsored, narrow", type: .pagePromotionalHeader, name: "A Longer Title Goes Here, does it wrap?", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("page not sponsored, wide", type: .pagePromotionalHeader, name: "Art", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("page not sponsored, iPad", type: .pagePromotionalHeader, name: "Art", isSponsored: false, body: shortBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("page sponsored, narrow", type: .pagePromotionalHeader, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("page sponsored, wide", type: .pagePromotionalHeader, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("page sponsored, iPad", type: .pagePromotionalHeader, name: "Art", isSponsored: true, body: shortBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("page long body, narrow", type: .pagePromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: shortCtaCaption, style: .narrow),
                    ("page long body, wide", type: .pagePromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: shortCtaCaption, style: .wide),
                    ("page long body, iPad", type: .pagePromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: shortCtaCaption, style: .iPad),
                    ("page long body, long cta caption, narrow", type: .pagePromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: longCtaCaption, style: .narrow),
                    ("page long body, long cta caption, wide", type: .pagePromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: longCtaCaption, style: .wide),
                    ("page long body, long cta caption, iPad", type: .pagePromotionalHeader, name: "Art", isSponsored: true, body: longBody, ctaCaption: longCtaCaption, style: .iPad)
                ]
                for (desc, type, name, isSponsored, body, ctaCaption, style) in expectations {

                    it("has valid screenshot for \(desc)") {

                        let user: User = User.stub(["id": "fakeuser", "username" : "bob"])
                        let xhdpi = Attachment.stub([
                            "url": "http://ello.co/avatar.png",
                            "height": 0,
                            "width": 0,
                            "type": "png",
                            "size": 0]
                        )
                        let image = Asset.stub(["xhdpi": xhdpi])
                        let promotional = Promotional.stub([
                            "user" : user,
                            "userId" : user.id,
                            "categoryId" : "888",
                            "id" : "999",
                            "image" : image
                        ])

                        let pagePromotional = PagePromotional.stub([
                            "id" : "abc",
                            "header" : name,
                            "user" : user,
                            "subheader" : body,
                            "ctaCaption" : ctaCaption,
                            "ctaURL" : "http://google.com",
                            "image" : image
                        ])

                        let category = Ello.Category.stub([
                            "id" : "888",
                            "name" : name,
                            "body" : body,
                            "user" : user,
                            "ctaCaption" : ctaCaption,
                            "isSponsored" : isSponsored,
                            "promotionals" : [promotional]
                        ])

                        if type == .categoryPromotionalHeader {
                            let height = CategoryHeaderCellSizeCalculator.calculateCategoryHeight(category, cellWidth: style.width)
                            subject = CategoryHeaderCell(frame: style.frame(height))
                            let item = StreamCellItem(jsonable: category, type: .categoryPromotionalHeader)
                            CategoryHeaderCellPresenter.configure(subject, streamCellItem: item, streamKind: .category(slug: "Art"), indexPath: IndexPath(item: 0, section: 0), currentUser: nil)
                        }
                        else {
                            let height = CategoryHeaderCellSizeCalculator.calculatePagePromotionalHeight(pagePromotional, cellWidth: style.width)
                            subject = CategoryHeaderCell(frame: style.frame(height))
                            let item = StreamCellItem(jsonable: pagePromotional, type: .pagePromotionalHeader)
                            PagePromotionalHeaderCellPresenter.configure(subject, streamCellItem: item, streamKind: .category(slug: "Design"), indexPath: IndexPath(item: 0, section: 0), currentUser: nil)
                        }
                        setImages()

                        subject.layoutIfNeeded()
                        showView(subject)
                        expect(subject).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
