////
///  StreamImageViewerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya
import JTSImageViewController
import FLAnimatedImage

class StreamImageViewerSpec: QuickSpec {

    override func spec() {

        describe("StreamImageViewer") {

            var presentingVC: StreamViewController!
            var subject: StreamImageViewer!
            beforeEach {
                presentingVC = .instantiateFromStoryboard()
                subject = StreamImageViewer(presentingController: presentingVC)
            }

            describe("imageTapped(_:cell:)") {

                it("configures AppDelegate to allow rotation") {
                    let image = FLAnimatedImageView()
                    subject.imageTapped(image, imageURL: URL(string: "http://www.example.com/image.jpg"))

                    expect(AppDelegate.restrictRotation) == false
                }
            }

            context("JTSImageViewControllerOptionsDelegate") {

                describe("alphaForBackgroundDimmingOverlayInImageViewer(_:)") {

                    it("returns 1.0") {
                        expect(subject.alphaForBackgroundDimmingOverlay(inImageViewer: JTSImageViewController())) == 1.0
                    }
                }
            }

            context("JTSImageViewControllerDismissalDelegate") {

                describe("imageViewerWillDismiss(_:)") {

                    it("configures AppDelegate to prevent rotation") {
                        subject.imageViewerWillDismiss(JTSImageViewController())

                        expect(AppDelegate.restrictRotation) == true
                    }
                }
            }
        }
    }
}
