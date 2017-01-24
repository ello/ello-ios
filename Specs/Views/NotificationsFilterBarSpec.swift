////
///  NotificationsFilterBar.swift
//

@testable import Ello
import Quick
import Nimble


class NotificationsFilterBarSpec: QuickSpec {
    override func spec() {
        var subject = NotificationsFilterBar()
        var button1 = UIButton()
        var button2 = UIButton()
        var button3 = UIButton()
        var buttons : [UIButton] = []
        var rect = CGRect(x:0,y:0,width:0,height:0)

        describe("Is not broken") {
            it("can be created") {
                expect(NotificationsFilterBar()).notTo(beNil())
            }

            it("is a UIView") {
                expect(NotificationsFilterBar()).to(beAKindOf(UIView.self))
            }
        }

        describe("Can contain buttons") {

            beforeEach() {
                subject = NotificationsFilterBar(frame: CGRect(x: 0, y: 0, width: 92, height: 50))
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

                    it("should set x") {
                        expect(button1.frame.origin.x).to(equal(rect.origin.x))
                    }

                    it("should set y") {
                        expect(button1.frame.origin.y).to(equal(rect.origin.y))
                    }

                    it("should set width") {
                        expect(button1.frame.size.width).to(equal(rect.size.width))
                    }

                    it("should set height") {
                        expect(button1.frame.size.height).to(equal(rect.size.height))
                    }
                }

                describe("should layout button2") {
                    beforeEach() {
                        rect = CGRect(x: 31, y: 20, width: 30, height: 30)
                    }

                    it("should set x") {
                        expect(button2.frame.origin.x).to(equal(rect.origin.x))
                    }

                    it("should set y") {
                        expect(button2.frame.origin.y).to(equal(rect.origin.y))
                    }

                    it("should set width") {
                        expect(button2.frame.size.width).to(equal(rect.size.width))
                    }

                    it("should set height") {
                        expect(button2.frame.size.height).to(equal(rect.size.height))
                    }
                }

                describe("should layout button3") {
                    beforeEach() {
                        rect = CGRect(x: 62, y: 20, width: 30, height: 30)
                    }

                    it("should set x") {
                        expect(button3.frame.origin.x).to(equal(rect.origin.x))
                    }

                    it("should set y") {
                        expect(button3.frame.origin.y).to(equal(rect.origin.y))
                    }

                    it("should set width") {
                        expect(button3.frame.size.width).to(equal(rect.size.width))
                    }

                    it("should set height") {
                        expect(button3.frame.size.height).to(equal(rect.size.height))
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
