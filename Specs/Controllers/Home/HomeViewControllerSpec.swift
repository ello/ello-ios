////
///  HomeViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class HomeViewControllerSpec: QuickSpec {
    override func spec() {
        describe("HomeViewController") {
            var subject: HomeViewController!

            beforeEach {
                subject = HomeViewController(usage: .loggedOut)
                showController(subject)
            }

            it("starts out with editorials visible") {
                expect(subject.visibleViewController) == subject.editorialsViewController
            }

            it("shows following view controller") {
                subject.showFollowingViewController()
                expect(subject.visibleViewController) == subject.followingViewController
            }

            it("shows editorials view controller") {
                subject.showFollowingViewController()
                subject.showEditorialsViewController()
                expect(subject.visibleViewController) == subject.editorialsViewController
            }

            it("shows discover view controller") {
                subject.showDiscoverViewController()
                expect(subject.visibleViewController) == subject.discoverViewController
            }
        }
    }
}
