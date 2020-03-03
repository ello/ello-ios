////
///  EditorialCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class EditorialCellSpec: QuickSpec {
    override func spec() {
        describe("EditorialCellContent") {
            context("snapshots") {
                func config(
                    title: String = "Editorial title",
                    subtitle: String = "Editorial subtitle",
                    sent: Date? = nil,
                    join: Bool = false,
                    stream: Bool = false
                ) -> EditorialCellContent.Config {
                    var config = EditorialCellContent.Config()
                    config.title = title
                    config.subtitle = subtitle
                    config.invite = (emails: "", sent: sent)
                    config.specsImage = specImage(named: "specs-avatar")

                    let author = User.stub([:])
                    let post = Post.stub(["author": author])
                    config.post = post

                    if join {
                        config.join = (
                            email: "email@email.com", username: "username", password: "password",
                            submitted: false
                        )
                    }

                    if stream {
                        let author = User.stub(["username": "qwfpgjluyarstdhneiozxcvbkm"])
                        let post = Post.stub(["author": author])
                        let editorial = Editorial.stub([
                            title: title,
                            subtitle: subtitle,
                        ])
                        config.postStreamConfigs = [
                            EditorialCellContent.Config.fromPost(post, editorial: editorial),
                            EditorialCellContent.Config.fromPost(post, editorial: editorial),
                        ]
                    }

                    return config
                }

                let expectations:
                    [(
                        String, () -> EditorialCellContent.Config, () -> EditorialCellContent,
                        CGFloat
                    )] = [
                        (
                            "invite sent", { return config(sent: Globals.now) },
                            EditorialInviteCell.init, 375
                        ),
                        ("join", { return config() }, EditorialJoinCell.init, 375),
                        ("join on iphone se", { return config() }, EditorialJoinCell.init, 320),
                        ("join on iphone plus", { return config() }, EditorialJoinCell.init, 414),
                        (
                            "join filled in", { return config(join: true) }, EditorialJoinCell.init,
                            375
                        ),
                        ("post", { return config() }, EditorialPostCell.init, 375),
                        (
                            "post_stream", { return config(stream: true) },
                            EditorialPostStreamCell.init, 375
                        ),
                    ]
                for (description, configFn, cell, size) in expectations {
                    it("should have valid snapshot for \(description)") {
                        let actualSize = CGSize(width: size, height: size + 1)
                        let subject = cell()
                        subject.frame.size = actualSize
                        subject.config = configFn()
                        expectValidSnapshot(subject)
                    }
                }
            }
        }
    }
}
