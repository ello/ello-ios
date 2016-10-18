////
///  ProfileLinksViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileLinksViewSpec: QuickSpec {
    override func spec() {
        describe("ProfileLinksView") {
            context("snapshots") {
                it("links") {
                    let subject = ProfileLinksView(frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 114)
                        ))
                    subject.externalLinks = [
                        ExternalLink(url: NSURL(string: "http://ello.co")!, text: "link1"),
                        ExternalLink(url: NSURL(string: "http://ello.co")!, text: "link2"),
                        ExternalLink(url: NSURL(string: "http://ello.co")!, text: "link3"),
                    ]
                    expectValidSnapshot(subject, named: "ProfileLinksView-links", device: .Custom(subject.frame.size))
                }
                it("links and icons") {
                    let subject = ProfileLinksView(frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 85)
                        ))
                    subject.externalLinks = [
                        ExternalLink(url: NSURL(string: "http://ello.co")!, text: "link1"),
                        ExternalLink(url: NSURL(string: "http://ello.co")!, text: "link2"),
                        ExternalLink(url: NSURL(string: "http://ello.co")!, text: "link3", iconURL: NSURL(string: "http://social-icons.ello.co/noimagehere")),
                    ]
                    expectValidSnapshot(subject, named: "ProfileLinksView-links-icons", device: .Custom(subject.frame.size))
                }
                it("icons") {
                    let subject = ProfileLinksView(frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 52)
                        ))
                    subject.externalLinks = [
                        ExternalLink(url: NSURL(string: "http://ello.co")!, text: "link1", iconURL: NSURL(string: "http://social-icons.ello.co/noimagehere")),
                        ExternalLink(url: NSURL(string: "http://ello.co")!, text: "link2", iconURL: NSURL(string: "http://social-icons.ello.co/noimagehere")),
                        ExternalLink(url: NSURL(string: "http://ello.co")!, text: "link3", iconURL: NSURL(string: "http://social-icons.ello.co/noimagehere")),
                    ]
                    expectValidSnapshot(subject, named: "ProfileLinksView-icons", device: .Custom(subject.frame.size))
                }
            }
        }
    }
}
