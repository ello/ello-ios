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
                func config(title: String, sent: Bool = false, invite: Bool = false, join: Bool = false) -> EditorialCell.Config {
                    var config = EditorialCell.Config()
                    config.title = title
                    if sent {
                        config.invite = EditorialCell.Config.Invite(emails: "", sent: sent)
                    }
                    else if invite {
                        config.invite = EditorialCell.Config.Invite(emails: "email@email.com", sent: sent)
                    }

                    if join {
                        config.join = EditorialCell.Config.Join(email: "email@email.com", username: "username", password: "password")
                    }
                    return config
                }

                let expectations: [(String, EditorialCell.Config, EditorialCell.Type)] = [
                    ("external", config(title: "Editorial title"), EditorialExternalCell.self),
                    ("invite", config(title: "Editorial title"), EditorialInviteCell.self),
                    ("invite filled in", config(title: "Editorial title", invite: true), EditorialInviteCell.self),
                    ("invite sent", config(title: "Editorial title", sent: true), EditorialInviteCell.self),
                    ("join", config(title: "Editorial title"), EditorialJoinCell.self),
                    ("join filled in", config(title: "Editorial title", join: true), EditorialJoinCell.self),
                    ("post", config(title: "Editorial title"), EditorialPostCell.self),
                    ("post_stream", config(title: "Editorial title"), EditorialPostStreamCell.self),
                ]
                for (description, config, cellClass) in expectations {
                    it("should have valid snapshot for \(description)") {
                        let subject = cellClass.init()
                        subject.frame.size = CGSize(width: 375, height: 375)
                        subject.config = config
                        expectValidSnapshot(subject, record: true)
                    }
                }
            }
        }
    }
}
