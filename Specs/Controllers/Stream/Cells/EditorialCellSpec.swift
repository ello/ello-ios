////
///  EditorialCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class EditorialCellSpec: QuickSpec {
    override func spec() {
        describe("EditorialCell") {
            context("snapshots") {
                func config(title: String = "Editorial title", subtitle: String = "Editorial subtitle", sent: Bool = false, join: Bool = false) -> EditorialCell.Config {
                    var config = EditorialCell.Config()
                    config.title = title
                    config.subtitle = subtitle
                    config.invite = (emails: "", sent: sent)
                    config.specsImage = specImage(named: "specs-avatar")

                    if join {
                        config.join = (email: "email@email.com", username: "username", password: "password")
                    }

                    return config
                }

                let expectations: [(String, EditorialCell.Config, EditorialCell.Type, CGFloat)] = [
                    ("invite sent", config(sent: true), EditorialInviteCell.self, 375),
                    ("join", config(), EditorialJoinCell.self, 375),
                    ("join on iphone se", config(), EditorialJoinCell.self, 320),
                    ("join on iphone plus", config(), EditorialJoinCell.self, 414),
                    ("join filled in", config(join: true), EditorialJoinCell.self, 375),
                    ("post", config(), EditorialPostCell.self, 375),
                    ("post_stream", config(), EditorialPostStreamCell.self, 375),
                ]
                for (description, config, cellClass, size) in expectations {
                    it("should have valid snapshot for \(description)") {
                        let subject = cellClass.init()
                        subject.frame.size = CGSize(width: size, height: size + 1)
                        subject.config = config
                        expectValidSnapshot(subject)
                    }
                }
            }
        }
    }
}
