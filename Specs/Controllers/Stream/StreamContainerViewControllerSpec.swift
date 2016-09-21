////
///  StreamContainerViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import SwiftyUserDefaults


class StreamContainerViewControllerSpec: QuickSpec {
    override func spec() {
        describe("StreamContainerViewController") {

            var controller: StreamContainerViewController!

            describe("initialization") {

                beforeEach {
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                }

                describe("storyboard") {

                    beforeEach {
                        showController(controller)
                    }

                    it("IBOutlets are  not nil") {
                        expect(controller.scrollView).notTo(beNil())
                        expect(controller.navigationBar).notTo(beNil())
                        expect(controller.navigationBarTopConstraint).notTo(beNil())
                    }

                }

                it("can be instantiated from storyboard") {
                    expect(controller).notTo(beNil())
                }

                it("is a BaseElloViewController") {
                    expect(controller).to(beAKindOf(BaseElloViewController.self))
                }

                it("is a StreamContainerViewController") {
                    expect(controller).to(beAKindOf(StreamContainerViewController.self))
                }

                it("has a tab bar item") {
                    expect(controller.tabBarItem).notTo(beNil())

                    let selectedImage:UIImage = controller.navigationController!.tabBarItem.valueForKey("selectedImage") as! UIImage

                    expect(selectedImage).notTo(beNil())
                }
            }

            describe("recalling previously viewed stream") {
                it("should have a default currentStreamIndex") {
                    GroupDefaults[CurrentStreamKey] = nil
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    expect(controller.currentStreamIndex) == 0
                }

                it("should store the currentStreamIndex") {
                    GroupDefaults[CurrentStreamKey] = 1
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    expect(controller.currentStreamIndex) == 1
                }

                it("should move the scroll view") {
                    GroupDefaults[CurrentStreamKey] = 1
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    showController(controller)
                    expect(controller.scrollView.contentOffset) == CGPoint(x: UIScreen.mainScreen().bounds.size.width, y: 0)
                }

                it("should update the currentStreamIndex") {
                    GroupDefaults[CurrentStreamKey] = 0
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    showController(controller)
                    controller.streamsSegmentedControl.selectedSegmentIndex = 1
                    controller.streamSegmentTapped(controller.streamsSegmentedControl)
                    expect(controller.currentStreamIndex) == 1
                }
            }

            describe("-viewDidLoad:") {

                beforeEach {
                    controller = StreamContainerViewController.instantiateFromStoryboard()
                    showController(controller)
                }

                it("has streams") {
                    expect(controller.streamControllerViews.count) == 2
                }

                it("IBActions are wired up") {
                    let streamsSegmentedControlActions = controller.streamsSegmentedControl.actionsForTarget(controller, forControlEvent: UIControlEvents.ValueChanged)

                    expect(streamsSegmentedControlActions).to(contain("streamSegmentTapped:"))

                    expect(streamsSegmentedControlActions?.count) == 1
                }
            }
        }
    }
}

