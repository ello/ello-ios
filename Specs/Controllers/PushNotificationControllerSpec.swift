@testable import Ello
import Quick
import Nimble


class PushNotificationControllerSpec: QuickSpec {
    class MockViewController: UIViewController {
        var presented = false

        override func present(
            _ viewControllerToPresent: UIViewController,
            animated flag: Bool,
            completion: Block? = nil
        ) {
            presented = true
        }
    }

    override func spec() {
        describe("PushNotificationController") {
            var currentBadgeCount = 0

            beforeEach {
                currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
            }

            afterEach {
                UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount
            }

            describe("-hasAlert(_:)") {
                context("has alert") {
                    it("returns true") {
                        let userInfo: [AnyHashable: Any] = [
                            "application_target": "notifications/posts/4",
                            "type": "repost",
                            "aps": [
                                "alert": [
                                    "body": "@bob has reposted one of your posts",
                                    "title": "New Repost"
                                ],
                                "badge": NSNumber(value: 4)
                            ]
                        ]

                        expect(PushNotificationController.shared.hasAlert(userInfo)) == true
                    }
                }

                context("no alert") {
                    it("returns false") {
                        let userInfo: [AnyHashable: Any] = [
                            "type": "reset_badge_count",
                            "aps": [
                                "badge": NSNumber(value: 0)
                            ]
                        ]

                        expect(PushNotificationController.shared.hasAlert(userInfo)) == false
                    }
                }
            }

            context("-updateBadgeCount(_:)") {

                context("has badge") {
                    it("updates to new value") {
                        UIApplication.shared.applicationIconBadgeNumber = 5
                        let userInfo: [AnyHashable: Any] = [
                            "type": "reset_badge_count",
                            "aps": [
                                "badge": NSNumber(value: 0)
                            ]
                        ]
                        PushNotificationController.shared.updateBadgeCount(userInfo)
                        // yes, apparently, *printing* the value makes this spec pass
                        print("count: \(UIApplication.shared.applicationIconBadgeNumber)")

                        expect(UIApplication.shared.applicationIconBadgeNumber) == 0
                    }
                }

                context("no badge") {
                    it("does nothing") {
                        UIApplication.shared.applicationIconBadgeNumber = 5
                        let userInfo: [AnyHashable: Any] = [
                            "type": "reset_badge_count",
                            "aps": [
                            ]
                        ]
                        PushNotificationController.shared.updateBadgeCount(userInfo)

                        expect(UIApplication.shared.applicationIconBadgeNumber) == 5
                    }
                }
            }

            describe("requestPushAccessIfNeeded") {
                let keychain = FakeKeychain()

                beforeEach {
                    AuthToken.sharedKeychain = keychain
                }

                context("when the user isn't authenticated") {
                    it("does not present prompt") {
                        keychain.isPasswordBased = false
                        let controller = PushNotificationController(
                            defaults: UserDefaults(),
                            keychain: keychain
                        )
                        let vc = MockViewController()
                        controller.requestPushAccessIfNeeded(vc)
                        expect(vc.presented) == false
                    }
                }

                context("when the user is authenticated, but has denied access") {
                    it("does not present prompt") {
                        keychain.isPasswordBased = true

                        let controller = PushNotificationController(
                            defaults: UserDefaults(),
                            keychain: keychain
                        )
                        controller.permissionDenied = true
                        let vc = MockViewController()
                        controller.requestPushAccessIfNeeded(vc)
                        expect(vc.presented) == false
                    }
                }

                context(
                    "when the user is authenticated, hasn't previously denied access, and hasn't seen the custom alert before"
                ) {
                    it("presents a prompt") {
                        keychain.authToken = "abcde"
                        keychain.isPasswordBased = true

                        let controller = PushNotificationController(
                            defaults: UserDefaults(),
                            keychain: keychain
                        )
                        controller.permissionDenied = false
                        controller.needsPermission = true

                        let vc = MockViewController()
                        controller.requestPushAccessIfNeeded(vc)
                        expect(vc.presented) == true
                    }
                }
            }
        }

    }
}
