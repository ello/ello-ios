////
///  ContentFlaggerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class ContentFlaggerSpec: QuickSpec {

    override func spec() {

        var subject: ContentFlagger!
        var presentingController: UIViewController!
        beforeEach {
            presentingController = UIViewController()
            subject = ContentFlagger(presentingController: presentingController,
                flaggableId: "123",
                contentType: .post,
                commentPostId: nil)
            showController(presentingController)
        }

        context("post flagging") {
            it("presents an AlertViewController") {
                subject.displayFlaggingSheet()
                let presentedVC = subject.presentingController?.presentedViewController as! AlertViewController

                expect(presentedVC).to(beAKindOf(AlertViewController.self))
            }

            it("the correct kind is associated with each flag type") {
                subject.displayFlaggingSheet()
                let presentedVC = subject.presentingController?.presentedViewController as! AlertViewController

                let actions = presentedVC.actions

                let spamAction = actions[0]
                let violenceAction = actions[1]
                let copyrightAction = actions[2]
                let threateningAction = actions[3]
                let hateAction = actions[4]
                let adultAction = actions[5]
                let dontLikeAction = actions[6]

                expect(ContentFlagger.AlertOption(rawValue: spamAction.title)) == ContentFlagger.AlertOption.spam
                expect(ContentFlagger.AlertOption(rawValue: violenceAction.title)) == ContentFlagger.AlertOption.violence
                expect(ContentFlagger.AlertOption(rawValue: copyrightAction.title)) == ContentFlagger.AlertOption.copyright
                expect(ContentFlagger.AlertOption(rawValue: threateningAction.title)) == ContentFlagger.AlertOption.threatening
                expect(ContentFlagger.AlertOption(rawValue: hateAction.title)) == ContentFlagger.AlertOption.hate
                expect(ContentFlagger.AlertOption(rawValue: adultAction.title)) == ContentFlagger.AlertOption.adult
                expect(ContentFlagger.AlertOption(rawValue: dontLikeAction.title)) == ContentFlagger.AlertOption.dontLike
            }
        }
    }
}
