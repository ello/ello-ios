////
///  ProfileLinksPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileLinksPresenterSpec: QuickSpec {
    override func spec() {
        describe("ProfileLinksPresenter") {
            it("should assign links") {
                let links: [[String: String]] = [
                    ["url": "http://ello.co", "text": "ello.co"],
                    ["url": "http://ello.co", "text": "ello.co", "icon": "http://social-icons.ello.co/ello.png"],
                ]
                let user: User = stub(["externalLinksList": links])
                let view = ProfileLinksView()
                ProfileLinksPresenter.configure(view, user: user, currentUser: nil)
                expect(view.externalLinks).to(equal(links.compactMap { ExternalLink.fromDict($0) }))
            }
        }
    }
}
