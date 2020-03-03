////
///  DrawerAnimatorsSpec.swift
//

@testable import Ello
import Quick
import Nimble


class DrawerAnimatorsSpec: QuickSpec {
    override func spec() {
        describe("DrawerAnimators") {
            var shouldComplete = true
            let animator: Animator = { animations, completion in
                animations()
                if shouldComplete {
                    completion(true)
                }
            }

            beforeEach {
                shouldComplete = true
            }

            describe("DrawerPushAnimator") {
                var subject: DrawerPushAnimator!
                let popControl = DrawerPopControl()

                beforeEach {
                    subject = DrawerPushAnimator(popControl: popControl)
                }
                it("animates") {
                    let streamView = UIView(
                        frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
                    )
                    let drawerView = UIView()
                    let containerView = UIView()
                    var completed = false

                    subject.animateTransition(
                        streamView: streamView,
                        drawerView: drawerView,
                        containerView: containerView,
                        animator: animator
                    ) {
                        completed = true
                    }

                    expect(completed) == true
                    expect(streamView.frame.origin.x) > 0
                    expect(drawerView.frame.size) == streamView.frame.size
                    expect(drawerView.superview) == containerView
                    expect(popControl.superview) == streamView
                }
            }
            describe("DrawerPopAnimator") {
                var subject: DrawerPopAnimator!
                let popControl = DrawerPopControl()

                beforeEach {
                    subject = DrawerPopAnimator(popControl: popControl)
                }
                it("animates") {
                    let streamView = UIView()
                    let drawerView = UIView()
                    let containerView = UIView()
                    var completed = false

                    shouldComplete = false
                    subject.animateTransition(
                        streamView: streamView,
                        drawerView: drawerView,
                        containerView: containerView,
                        animator: animator
                    ) {
                        completed = true
                    }

                    expect(completed) == false
                    expect(streamView.frame.origin.x) == 0
                    expect(drawerView.frame.size) == streamView.frame.size
                    expect(drawerView.superview) == containerView
                }
                it("completes") {
                    let streamView = UIView()
                    let drawerView = UIView()
                    let containerView = UIView()
                    var completed = false

                    // setup as if 'push animator' had a chance to run
                    containerView.addSubview(drawerView)
                    containerView.addSubview(streamView)
                    streamView.addSubview(popControl)

                    subject.animateTransition(
                        streamView: streamView,
                        drawerView: drawerView,
                        containerView: containerView,
                        animator: animator
                    ) {
                        completed = true
                    }

                    expect(completed) == true
                    expect(streamView.frame.origin.x) == 0
                    expect(drawerView.frame.size) == streamView.frame.size
                    expect(drawerView.superview).to(beNil())
                    expect(popControl.superview).to(beNil())
                }
            }
        }
    }
}
