////
///  AlertViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AlertViewControllerSpec: QuickSpec {

    func presentAlert(_ controller: AlertViewController) {
        let holder = UIViewController()
        showController(holder)
        holder.present(controller, animated: false, completion: nil)
    }

    override func spec() {
        describe("AlertViewController") {
            describe("nib") {
                it("outlets are set") {
                    let controller = AlertViewController(message: .none)
                    self.presentAlert(controller)

                    expect(controller.tableView).toNot(beNil())
                    expect(controller.topPadding).toNot(beNil())
                    expect(controller.leftPadding).toNot(beNil())
                }
            }

            describe("snapshots") {
                validateAllSnapshots {
                    let subject = AlertViewController(message: "hey there!")
                    let action = AlertAction(title: InterfaceString.OK, style: .dark, handler: nil)
                    subject.addAction(action)
                    showController(subject)
                    return subject
                }
            }

            describe("contentView") {

                it("accepts a contentView") {
                    let controller = AlertViewController(message: .none)
                    self.presentAlert(controller)

                    let view = UIView()
                    controller.contentView = view

                    expect(controller.contentView).to(equal(view))
                }

                it("hides its tableView") {
                    let controller = AlertViewController(message: .none)
                    self.presentAlert(controller)
                    let view = UIView()
                    controller.contentView = view

                    expect(controller.tableView.isHidden).to(beTrue())
                }

                it("resizes") {
                    let controller = AlertViewController(message: .none)
                    self.presentAlert(controller)
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    controller.contentView = view

                    expect(controller.desiredSize).to(equal(view.frame.size))
                    expect(controller.view.frame.size).to(equal(view.frame.size))
                }

                it("centers") {
                    let controller = AlertViewController(message: .none)
                    self.presentAlert(controller)
                    let superview = UIView(frame: CGRect(x: 0, y: 0, width: 102, height: 102))
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    superview.addSubview(controller.view)
                    controller.contentView = view

                    expect(controller.view.frame.origin).to(equal(CGPoint(x: 1, y: 1)))
                }
            }
        }
    }
}
