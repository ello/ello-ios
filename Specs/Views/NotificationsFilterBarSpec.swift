////
///  NotificationsFilterBar.swift
//

@testable import Ello
import Quick
import Nimble


class NotificationsFilterBarSpec: QuickSpec {
    override func spec() {
        var subject: NotificationsFilterBar!
        var button1: UIButton!
        var button2: UIButton!
        var button3: UIButton!
        var buttons: [UIButton]!
        var rect = CGRect(x: 0, y: 0, width: 0, height: 0)

        beforeEach {
            subject = NotificationsFilterBar()
            button1 = UIButton()
            button2 = UIButton()
            button3 = UIButton()
            buttons = []
        }

        describe("NotificationsFilterBar") {
            describe("Can contain buttons") {

                beforeEach() {
                    subject = NotificationsFilterBar(
                        frame: CGRect(x: 0, y: 0, width: 92, height: 50)
                    )
                    button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                    button2 = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                    button3 = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                    buttons = [button1, button2, button3]
                    for button in buttons {
                        subject.addSubview(button)
                    }
                    subject.layoutIfNeeded()
                }

                describe("-layoutSubviews") {
                    describe("should layout button1") {
                        beforeEach() {
                            rect = CGRect(x: 0, y: 20, width: 30, height: 30)
                        }

                        it("should set rect") {
                            expect(button1.frame).to(equal(rect))
                        }
                    }

                    describe("should layout button2") {
                        beforeEach() {
                            rect = CGRect(x: 31, y: 20, width: 30, height: 30)
                        }

                        it("should set rect") {
                            expect(button2.frame).to(equal(rect))
                        }
                    }

                    describe("should layout button3") {
                        beforeEach() {
                            rect = CGRect(x: 62, y: 20, width: 30, height: 30)
                        }

                        it("should set rect") {
                            expect(button3.frame).to(equal(rect))
                        }
                    }
                }

                it("selectButton") {
                    subject.selectButton(button1)
                    expect(button1.isSelected).to(equal(true))
                    expect(button2.isSelected).to(equal(false))
                    expect(button3.isSelected).to(equal(false))
                }
            }
        }

    }
}
