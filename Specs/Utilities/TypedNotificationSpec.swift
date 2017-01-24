////
///  TypedNotificationSpec.swift
//

@testable import Ello
import Quick
import Nimble


class TypedNotificationSpec: QuickSpec {
    let notification = TypedNotification<String>(name: "com.Ello.Specs.TypedNotificationSpec")
    var didNotify: String?
    var observer: NotificationObserver?

    @objc
    func receivedNotification(_ notif: NSNotification) {
        if let userInfo = notif.userInfo {
            if let box = userInfo["value"] as? Box<String> {
                didNotify = box.value
            }
        }
    }

    override func spec() {
        describe("posting a notification") {
            beforeEach() {
                self.didNotify = nil
                NotificationCenter.default.addObserver(self, selector: #selector(TypedNotificationSpec.receivedNotification(_:)), name: self.notification.name, object: nil)
            }

            afterEach() {
                NotificationCenter.default.removeObserver(self)
            }

            it("should post a notification") {
                postNotification(self.notification, value: "testing")
                expect(self.didNotify).to(equal("testing"))
            }
        }

        describe("observing a notification") {
            beforeEach() {
                self.didNotify = nil
                self.observer = NotificationObserver(notification: self.notification) { value in
                    self.didNotify = value
                }
            }

            it("should receive a notification") {
                NotificationCenter.default.post(name: self.notification.name, object: nil, userInfo: ["value": Box("testing")])
                expect(self.didNotify).to(equal("testing"))
            }
        }

        describe("stop observing a notification") {
            beforeEach() {
                self.didNotify = nil
                self.observer = NotificationObserver(notification: self.notification) { value in
                    self.didNotify = value
                }
            }

            it("should be able to stop observing") {
                self.observer!.removeObserver()
                NotificationCenter.default.post(name: self.notification.name, object: nil, userInfo: ["value": Box("testing")])
                expect(self.didNotify).to(beNil())
            }
        }
    }
}
