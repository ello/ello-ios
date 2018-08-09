////
///  FollowingViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import SwiftyUserDefaults


class FollowingViewControllerSpec: QuickSpec {
    override func spec() {
        describe("FollowingViewController") {
            var subject: FollowingViewController!

            beforeEach {
                subject = FollowingViewController()
                showController(subject)
            }

            it("shows the more posts button when new content is available") {
                subject.screen.newPostsButtonVisible = false
                postNotification(NewContentNotifications.newFollowingContent, value: ())
                expect(subject.screen.newPostsButtonVisible) == true
            }

            it("hide the more posts button after pulling to refresh") {
                subject.screen.newPostsButtonVisible = true
                subject.streamWillPullToRefresh()
                expect(subject.screen.newPostsButtonVisible) == false
            }
        }
    }
}
