////
///  ProfileHeaderLinksCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderLinksCellSpec: QuickSpec {
    override func spec() {
        describe("ProfileHeaderLinksCell") {
            context("snapshots") {
                it("links") {
                    let subject = ProfileHeaderLinksCell(frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 114)
                        ))
                    subject.externalLinks = [
                        ExternalLink(url: URL(string: "http://ello.co")!, text: "link1"),
                        ExternalLink(url: URL(string: "http://ello.co")!, text: "link2"),
                        ExternalLink(url: URL(string: "http://ello.co")!, text: "link3"),
                    ]
                    expectValidSnapshot(subject)
                }
                it("links and icons") {
                    let subject = ProfileHeaderLinksCell(frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 85)
                        ))
                    subject.externalLinks = [
                        ExternalLink(url: URL(string: "http://ello.co")!, text: "link1"),
                        ExternalLink(url: URL(string: "http://ello.co")!, text: "link2"),
                        ExternalLink(url: URL(string: "http://ello.co")!, text: "link3", iconURL: URL(string: "http://social-icons.ello.co/noimagehere")),
                    ]
                    expectValidSnapshot(subject)
                }
                it("icons") {
                    let subject = ProfileHeaderLinksCell(frame: CGRect(
                        origin: .zero,
                        size: CGSize(width: 375, height: 52)
                        ))
                    subject.externalLinks = [
                        ExternalLink(url: URL(string: "http://ello.co")!, text: "link1", iconURL: URL(string: "http://social-icons.ello.co/noimagehere")),
                        ExternalLink(url: URL(string: "http://ello.co")!, text: "link2", iconURL: URL(string: "http://social-icons.ello.co/noimagehere")),
                        ExternalLink(url: URL(string: "http://ello.co")!, text: "link3", iconURL: URL(string: "http://social-icons.ello.co/noimagehere")),
                    ]
                    expectValidSnapshot(subject)
                }
            }
        }
    }
}
