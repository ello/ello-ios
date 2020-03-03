////
///  ContentFlaggerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class ContentFlaggerSpec: QuickSpec {

    override func spec() {
        describe("ContentFlagger") {
            var subject: ContentFlagger!
            var presentingController: UIViewController!
            beforeEach {
                presentingController = UIViewController()
                subject = ContentFlagger(
                    presentingController: presentingController,
                    flaggableId: "123",
                    contentType: .post,
                    commentPostId: nil
                )
                showController(presentingController)
            }

            context("post flagging") {
                it("the correct kind is associated with each flag type") {
                    subject.displayFlaggingSheet()
                    let presentedVC = subject.presentingController?.presentedViewController
                        as! AlertViewController

                    let actions = presentedVC.actions

                    let spamAction = actions[0]
                    let violenceAction = actions[1]
                    let copyrightAction = actions[2]
                    let threateningAction = actions[3]
                    let hateAction = actions[4]
                    let adultAction = actions[5]
                    let dontLikeAction = actions[6]

                    expect(UserFlag(rawValue: spamAction.title)) == UserFlag.spam
                    expect(UserFlag(rawValue: violenceAction.title)) == UserFlag.violence
                    expect(UserFlag(rawValue: copyrightAction.title)) == UserFlag.copyright
                    expect(UserFlag(rawValue: threateningAction.title)) == UserFlag.threatening
                    expect(UserFlag(rawValue: hateAction.title)) == UserFlag.hate
                    expect(UserFlag(rawValue: adultAction.title)) == UserFlag.adult
                    expect(UserFlag(rawValue: dontLikeAction.title)) == UserFlag.dontLike
                }
            }
        }
    }
}
