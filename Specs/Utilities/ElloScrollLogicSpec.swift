////
///  ElloScrollLogicSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ElloScrollLogicSpec: QuickSpec {
    var didShow : Bool?
    var didHide : Bool?

    fileprivate func resetShowHide() {
        didShow = nil
        didHide = nil
    }

    override func spec() {
        describe("scrolling behavior") {
            var logic: ElloScrollLogic!
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
            let scrollHeight = scrollView.frame.size.height * CGFloat(2)
            let scrollStart : CGFloat = 20

            beforeEach() {
                logic = ElloScrollLogic(
                    onShow: { [unowned self] in
                        self.didShow = true
                    },
                    onHide: { [unowned self] in
                        self.didHide = true
                    })
                logic.isRunningSpecs = true

                scrollView.contentOffset = CGPoint(x: 0, y: scrollStart)
                scrollView.contentSize = CGSize(width: 320, height: scrollHeight)
                logic.prevOffset = CGPoint(x: 0, y: scrollStart)
                logic.scrollViewWillBeginDragging(scrollView)
                self.resetShowHide()
            }

            it("should 'hide' when scrolling down") {
                scrollView.contentOffset = CGPoint(x: 0, y: scrollStart + CGFloat(2))
                logic.scrollViewDidScroll(scrollView)
                expect(self.didShow).to(beNil())
                expect(self.didHide).to(equal(true))
            }

            it("should 'show' when scrolling up") {
                scrollView.contentOffset = CGPoint(x: 0, y: scrollStart - CGFloat(8))
                logic.scrollViewDidScroll(scrollView)
                expect(self.didShow).to(equal(true))
                expect(self.didHide).to(beNil())
            }

            it("should not 'show' when scrolling up just a little") {
                scrollView.contentOffset = CGPoint(x: 0, y: scrollStart - CGFloat(2))
                logic.scrollViewDidScroll(scrollView)
                expect(self.didShow).to(beNil())
                expect(self.didHide).to(beNil())
            }

            it("should not 'show' when scrolling up quickly") {
                scrollView.contentOffset = CGPoint(x: 0, y: scrollStart - CGFloat(20))
                logic.scrollViewDidScroll(scrollView)
                expect(self.didShow).to(beNil())
                expect(self.didHide).to(beNil())
            }

            it("should 'show' when scrolling past the top") {
                scrollView.contentOffset = CGPoint(x: 0, y: -10)
                logic.scrollViewDidScroll(scrollView)
                expect(self.didShow).to(equal(true))
                expect(self.didHide).to(beNil())
            }

            describe("scrolling near the bottom") {
                beforeEach() {
                    logic.prevOffset = CGPoint(x: 0, y: scrollHeight)
                }
                it("should ignore scrolling up") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollHeight - CGFloat(25))
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
                it("should ignore scrolling down") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollHeight + CGFloat(25))
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
            }

            describe("scrolling if there is very little content") {
                beforeEach() {
                    scrollView.contentSize = CGSize(width: 320, height: 30)
                }

                it("should ignore -30") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollStart - 30)
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
                it("should ignore -10") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollStart - 10)
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
                it("should ignore 10") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollStart + 10)
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
                it("should ignore 30") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollStart + 30)
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
            }

            describe("should ignore all scrolling if there is not 'much' content") {
                beforeEach() {
                    scrollView.contentSize = CGSize(width: 320, height: scrollView.frame.size.height + CGFloat(10))
                }

                it("should ignore -30") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollStart - 30)
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
                it("should ignore -10") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollStart - 10)
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
                it("should ignore 10") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollStart + 10)
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
                it("should ignore 30") {
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollStart + 30)
                    logic.scrollViewDidScroll(scrollView)
                    expect(self.didShow).to(beNil())
                    expect(self.didHide).to(beNil())
                }
            }

            it("should ignore after the finger has lifted") {
                logic.scrollViewDidEndDragging(scrollView, willDecelerate: true)
                scrollView.contentOffset = CGPoint(x: 0, y: scrollStart + 10)
                logic.scrollViewDidScroll(scrollView)
                expect(self.didShow).to(beNil())
                expect(self.didHide).to(beNil())
            }

            it("should 'show' after the finger has lifted if past top") {
                scrollView.contentOffset = CGPoint(x: 0, y: scrollStart)
                logic.scrollViewDidScroll(scrollView)
                expect(self.didShow).to(beNil())
                expect(self.didHide).to(beNil())

                self.resetShowHide()

                scrollView.contentOffset = CGPoint(x: 0, y: -10)
                logic.scrollViewDidEndDragging(scrollView, willDecelerate: true)
                expect(self.didShow).to(equal(true))
                expect(self.didHide).to(beNil())
            }

            it("should not show after the finger has lifted if past bottom") {
                scrollView.contentOffset = CGPoint(x: 0, y: scrollStart)
                logic.scrollViewDidScroll(scrollView)
                expect(self.didShow).to(beNil())
                expect(self.didHide).to(beNil())

                self.resetShowHide()

                scrollView.contentOffset = CGPoint(x: 0, y: scrollStart + 20)
                logic.scrollViewDidScroll(scrollView)
                expect(self.didShow).to(beNil())
                expect(self.didHide).to(equal(true))

                self.resetShowHide()

                scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height + 10)
                logic.scrollViewDidEndDragging(scrollView, willDecelerate: true)
                expect(self.didShow).to(beNil())
                expect(self.didHide).to(beNil())
            }
        }
    }
}
