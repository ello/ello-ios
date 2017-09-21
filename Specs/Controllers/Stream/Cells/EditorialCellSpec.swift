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
                func config(title: String = "Editorial title", subtitle: String = "Editorial subtitle", sent: Date? = nil, join: Bool = false, stream: Bool = false) -> EditorialCell.Config {
                    var config = EditorialCell.Config()
                    config.title = title
                    config.subtitle = subtitle
                    config.invite = (emails: "", sent: sent)
                    config.specsImage = specImage(named: "specs-avatar")

                    let author = User.stub([:])
                    let post = Post.stub(["author": author])
                    config.post = post

                    if join {
                        config.join = (email: "email@email.com", username: "username", password: "password", submitted: false)
                    }

                    if stream {
                        let author = User.stub(["username": "qwfpgjluyarstdhneiozxcvbkm"])
                        let post = Post.stub(["author": author])
                        let editorial = Editorial.stub([
                            title: title,
                            subtitle: subtitle,
                            ])
                        config.postStreamConfigs = [
                            EditorialCell.Config.fromPost(post, editorial: editorial),
                            EditorialCell.Config.fromPost(post, editorial: editorial),
                        ]
                    }

                    return config
                }

                let expectations: [(String, () -> EditorialCell.Config, EditorialCell.Type, CGFloat)] = [
                    ("invite sent",         { return config(sent: Globals.now) }, EditorialInviteCell.self, 375),
                    ("join",                { return config() }, EditorialJoinCell.self, 375),
                    ("join on iphone se",   { return config() }, EditorialJoinCell.self, 320),
                    ("join on iphone plus", { return config() }, EditorialJoinCell.self, 414),
                    ("join filled in",      { return config(join: true) }, EditorialJoinCell.self, 375),
                    ("post",                { return config() }, EditorialPostCell.self, 375),
                    ("post_stream",         { return config(stream: true) }, EditorialPostStreamCell.self, 375),
                ]
                for (description, configFn, cellClass, size) in expectations {
                    it("should have valid snapshot for \(description)") {
                        let subject = cellClass.init()
                        subject.frame.size = CGSize(width: size, height: size + 1)
                        subject.config = configFn()
                        expectValidSnapshot(subject)
                    }
                }
            }
        }
    }
}
