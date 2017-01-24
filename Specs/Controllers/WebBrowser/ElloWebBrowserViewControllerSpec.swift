////
///  ElloWebBrowserViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ElloWebBrowserViewControllerSpec: QuickSpec {
    override func spec() {
        describe("instantiating an ElloWebBrowserViewControllerSpec") {
            it("is easy to create a navigation controller w/ browser") {
                let nav = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
                expect(nav.rootWebBrowser()).to(beAKindOf(ElloWebBrowserViewController.self))
            }
            it("is easy to create a navigation controller w/ custom browser") {
                let browser = ElloWebBrowserViewController()
                let nav = ElloWebBrowserViewController.navigationControllerWithBrowser(browser)
                expect(nav.rootWebBrowser()).to(equal(browser))
            }
            it("has a fancy done button") {
                let nav = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
                let browser: ElloWebBrowserViewController = nav.rootWebBrowser() as! ElloWebBrowserViewController
                let xButton = browser.navigationItem.leftBarButtonItem!
                expect(xButton.action).to(equal(#selector(ElloWebBrowserViewController.doneButtonPressed(_:))))
            }
            it("has a fancy share button") {
                let nav = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
                let browser: ElloWebBrowserViewController = nav.rootWebBrowser() as! ElloWebBrowserViewController
                let shareButton = browser.navigationItem.rightBarButtonItem!
                expect(shareButton.action).to(equal(#selector(ElloWebBrowserViewController.shareButtonPressed(_:))))
            }
        }
    }
}
