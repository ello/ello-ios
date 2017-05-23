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
                    config.invite = EditorialCell.Config.Invite(emails: "", sent: sent)
                    config.specsImage = UIImage(named: "specs-avatar", in: Bundle(for: type(of: self)), compatibleWith: nil)!

                    if join {
                        config.join = EditorialCell.Config.Join(email: "email@email.com", username: "username", password: "password")
                    }

                    return config
                }

                let expectations: [(String, EditorialCell.Config, EditorialCell.Type)] = [
                    ("invite sent", config(sent: true), EditorialInviteCell.self),
                    ("join", config(), EditorialJoinCell.self),
                    ("join filled in", config(join: true), EditorialJoinCell.self),
                    ("post", config(), EditorialPostCell.self),
                    ("post_stream", config(), EditorialPostStreamCell.self),
                ]
                for (description, config, cellClass) in expectations {
                    it("should have valid snapshot for \(description)") {
                        let subject = cellClass.init()
                        subject.frame.size = CGSize(width: 375, height: 376)
                        subject.config = config
                        expectValidSnapshot(subject, record: true)
                    }
                }
            }
        }
    }
}
