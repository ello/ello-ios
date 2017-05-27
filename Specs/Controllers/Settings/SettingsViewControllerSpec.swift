////
///  SettingsViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class SettingsViewControllerSpec: QuickSpec {
    override func spec() {
        describe("initialization") {
            var subject: SettingsViewController!
            beforeEach {
                subject = UIStoryboard.storyboardWithId("SettingsViewController", storyboardName: "Settings") as! SettingsViewController
            }

            describe("storyboard") {
                beforeEach {
                    _ = subject.view
                }

                it("IBOutlets are not nil") {
                    expect(subject.avatarImageView).notTo(beNil())
                    expect(subject.avatarImage).notTo(beNil())
                    expect(subject.coverImage).notTo(beNil())
                    expect(subject.profileDescription).notTo(beNil())
                    expect(subject.nameTextFieldView).notTo(beNil())
                    expect(subject.linksTextFieldView).notTo(beNil())
                    expect(subject.bioTextView).notTo(beNil())
                    expect(subject.bioTextCountLabel).notTo(beNil())
                    expect(subject.bioTextStatusImage).notTo(beNil())
                }
            }
        }
    }
}
