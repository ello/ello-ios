////
///  ElloWebViewHelperSpec.swift
//

@testable import Ello
import Quick
import Nimble

class ElloWebViewHelperSpec: QuickSpec {

    override func spec() {

        describe("handleRequest") {

            context("outside web view") {

                it("returns false with ello://notifications") {
                    let request = URLRequest(url: URL(string: "ello://notifications")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil)) == false
                }

                it("returns false with mailto:archer@isis.com") {
                    let request = URLRequest(url: URL(string: "mailto:archer@isis.com")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil)) == false
                }

                it("returns false with http://ello.co/downloads") {
                    let request = URLRequest(url: URL(string: "http://ello.co/downloads")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil)) == false
                }

                it("returns false with http://ello.co/wtf") {
                    let request = URLRequest(url: URL(string: "http://ello.co/wtf")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil)) == false
                }

                it("returns false with http://wallpapers.ello.co/anything") {
                    let request = URLRequest(url: URL(string: "http://wallpapers.ello.co/anything")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil)) == false
                }

                it("returns false with http://www.google.com") {
                    let request = URLRequest(url: URL(string: "http://www.google.com")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil)) == false
                }

                it("returns true with file://path_to_something") {
                    let request = URLRequest(url: URL(string: "file://path_to_something")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil)) == true
                }

            }

            context("inside web view") {

                it("returns true with http://ello.co/downloads") {
                    let request = URLRequest(url: URL(string: "http://ello.co/downloads")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil, fromWebView: true)) == true
                }

                it("returns true with http://ello.co/wtf") {
                    let request = URLRequest(url: URL(string: "http://ello.co/wtf")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil, fromWebView: true)) == true
                }

                it("returns true with http://wallpapers.ello.co/anything") {
                    let request = URLRequest(url: URL(string: "http://wallpapers.ello.co/anything")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil, fromWebView: true)) == true
                }

                it("returns true with http://www.google.com") {
                    let request = URLRequest(url: URL(string: "http://www.google.com")!)
                    expect(ElloWebViewHelper.handle(request: request, webLinkDelegate: nil, fromWebView: true)) == true
                }

            }
        }

        describe("bypassInAppBrowser(_:)") {

            it("returns true for appstore links") {
                let urls = [
                    "https://appstore.com/blah",
                    "http://appstore.com/blah",
                    "https://itunes.apple.com/blah",
                    "http://itunes.apple.com/blah"
                ]

                for url in urls {
                    expect(ElloWebViewHelper.bypassInAppBrowser(URL(string: url)!)) == true
                }
            }

            it("returns false for all other links") {
                let urls = [
                    "https://google.com",
                    "http://ello.co/bob",
                    "https://mailto:bob@example.com",
                    "http://appstore-not-real.com"
                ]

                for url in urls {
                    expect(ElloWebViewHelper.bypassInAppBrowser(URL(string: url)!)) == false
                }
            }
        }
    }
}
