////
///  UINavigationItemSpec.swift
//

@testable import Ello
import Quick
import Nimble


class NavItemResponder: NSObject {
    static func a() {}
    static func b() {}
    static func c() {}
    static func d() {}
}

class UINavigationItemSpec: QuickSpec {
    override func spec() {
        describe("UINavigationItem") {
            var subject: UINavigationItem!
            beforeEach {
                subject = UINavigationItem()
            }

            describe("areRightButtonsTheSame(_:)") {
                let target = NavItemResponder()

                let newItemsSame = [
                    UIBarButtonItem(
                        barButtonSystemItem: .camera,
                        target: target,
                        action: #selector(NavItemResponder.a)
                    ),
                    UIBarButtonItem(
                        barButtonSystemItem: .camera,
                        target: target,
                        action: #selector(NavItemResponder.b)
                    )
                ]

                let newItemsDifferent = [
                    UIBarButtonItem(
                        barButtonSystemItem: .camera,
                        target: target,
                        action: #selector(NavItemResponder.c)
                    ),
                    UIBarButtonItem(
                        barButtonSystemItem: .camera,
                        target: target,
                        action: #selector(NavItemResponder.c)
                    )
                ]

                let rightItems = [
                    UIBarButtonItem(
                        barButtonSystemItem: .camera,
                        target: target,
                        action: #selector(NavItemResponder.a)
                    ),
                        UIBarButtonItem(
                            barButtonSystemItem: .camera,
                            target: target,
                            action: #selector(NavItemResponder.b)
                        )
                ]

                it("returns true when the arrays have similar value semantics") {
                    subject.rightBarButtonItems = rightItems
                    expect(subject.areRightButtonsTheSame(newItemsSame)) == true
                }

                it("returns false when the arrays have disimilar value semantics") {
                    subject.rightBarButtonItems = rightItems
                    expect(subject.areRightButtonsTheSame(newItemsDifferent)) == false
                }

                it("returns false rightBarButtonItems is nil") {
                    subject.rightBarButtonItems = nil
                    expect(subject.areRightButtonsTheSame(newItemsDifferent)) == false
                }

            }
        }
    }
}
