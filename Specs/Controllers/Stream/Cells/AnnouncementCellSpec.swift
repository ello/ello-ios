////
///  AnnouncementCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AnnouncementCellSpec: QuickSpec {
    override func spec() {
        describe("AnnouncementCell") {
            context("snapshots") {
                func config(
                    _ title: String,
                    _ body: String
                    ) -> AnnouncementCell.Config {
                    var config = AnnouncementCell.Config()
                    config.title = title
                    config.body = body
                    config.image = UIImage(named: "specs-avatar", in: Bundle(for: type(of: self)), compatibleWith: nil)!
                    config.callToAction = "Learn More"
                    return config
                }

                let expectations: [(String, AnnouncementCell.Config)] = [
                    ("short title, short description", config("short title", "short description")),
                    ("long title, short description", config("Lorem ipsum dolor sit amet, consectetur adipiscing elit", "short description")),
                    ("short title, long description", config("short title", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc consectetur molestie faucibus.")),
                    ("long title, long description", config("Lorem ipsum dolor sit amet, consectetur adipiscing elit", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc consectetur molestie faucibus.")),
                ]
                for (description, config) in expectations {
                    it("should have valid snapshot for \(description)") {
                        let announcement = Announcement(id: "1", header: config.title!, body: config.body!, ctaURL: nil, ctaCaption: config.callToAction!, createdAt: Date())
                        let width: CGFloat = 375
                        let height = AnnouncementCellSizeCalculator.calculateAnnouncementHeight(announcement, cellWidth: width)
                        let subject = AnnouncementCell()
                        subject.config = config
                        expectValidSnapshot(subject, device: .custom(CGSize(width: width, height: height)))
                    }
                }
            }
        }
    }
}
