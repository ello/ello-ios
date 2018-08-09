////
///  HireScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class HireScreenSpec: QuickSpec {
    override func spec() {
        describe("HireScreen") {
            describe("snapshots, keyboard hidden") {
                validateAllSnapshots { return HireScreen() }
            }
            describe("snapshots, keyboard shown") {
                var subject: HireScreen!
                beforeEach {
                    subject = HireScreen()
                    Keyboard.shared.isActive = true
                    Keyboard.shared.bottomInset = 216
                    subject.toggleKeyboard(visible: true)
                }
                afterEach {
                    Keyboard.shared.isActive = false
                    Keyboard.shared.bottomInset = 0
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                }

                describe("submit button enabled") {
                    beforeEach {
                        let textView: UITextView! = subject.findSubview()
                        textView.text = "has text"
                        subject.textViewDidChange(textView)
                    }
                    it("should have a valid snapshot") {
                        expectValidSnapshot(subject, device: .phone6_Portrait)
                    }
                }
            }
            context("text is empty") {
                var subject: HireScreen!
                var submitButton: UIButton?
                beforeEach {
                    subject = HireScreen()
                    submitButton = subject.findSubview { $0.tag == HireScreen.Specs.successButtonTag }
                }
                it("submitButton is disabled") {
                    let textView: UITextView! = subject.findSubview()
                    textView.text = ""
                    subject.textViewDidChange(textView)
                    expect(submitButton?.isEnabled) == false
                }
            }
            context("text set") {
                var subject: HireScreen!
                var submitButton: UIButton?
                beforeEach {
                    subject = HireScreen()
                    submitButton = subject.findSubview()
                    let textView: UITextView! = subject.findSubview()
                    textView.text = "hey there!"
                    subject.textViewDidChange(textView)
                }
                it("submitButton is enabled") {
                    expect(submitButton?.isEnabled) == true
                }
            }
        }
    }
}
