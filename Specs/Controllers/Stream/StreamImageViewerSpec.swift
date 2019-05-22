////
///  StreamImageViewerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya
import PINRemoteImage

class StreamImageViewerSpec: QuickSpec {

    override func spec() {
        describe("StreamImageViewer") {
            var presentingVC: StreamViewController!
            var subject: StreamImageViewer!
            beforeEach {
                presentingVC = StreamViewController()
                subject = StreamImageViewer(streamViewController: presentingVC)
            }

            describe("imageTapped(_:cell:)") {
                it("configures AppDelegate to allow rotation") {
                    subject.imageTapped(selected: 0, allItems: [], currentUser: nil)
                    expect(AppDelegate.restrictRotation) == false
                }
            }

            describe("imageViewerWillDismiss(_:)") {
                it("configures AppDelegate to prevent rotation") {
                    subject.lightboxWillDismiss()
                    expect(AppDelegate.restrictRotation) == true
                }
            }
        }
    }
}
