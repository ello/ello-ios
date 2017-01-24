////
///  OmnibarScreenSnapshotSpecs.swift
//

@testable import Ello
import Quick
import Nimble


class OmnibarScreenSnapshotSpecs: QuickSpec {
    override func spec() {
        let image = UIImage.imageWithColor(.blue, size: CGSize(width: 4000, height: 3000))!
        let smallImage = UIImage(named: "specs-avatar", in: Bundle(for: type(of: self)), compatibleWith: nil)!

        var subject: OmnibarScreen!
        beforeEach {
            subject = OmnibarScreen()
            subject.avatarImage = smallImage
        }

        describe("OmnibarScreenSnapshots") {
            validateAllSnapshots { return OmnibarScreen() }

            context("creating a post") {
                beforeEach {
                    subject.canGoBack = false
                    subject.title = ""
                    subject.submitTitle = InterfaceString.Omnibar.CreatePostButton
                }
                context("empty") { it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with text") { it("should have a valid snapshot") {
                    subject.regions = [.text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc consectetur molestie faucibus. Phasellus iaculis pellentesque felis eu fringilla. Ut in sollicitudin nisi. Praesent in mauris tortor. Nam interdum, magna eu pellentesque scelerisque, dui ipsum adipiscing ante, vel ullamcorper nisl sapien id arcu. Nullam egestas diam eu felis mollis sit amet cursus enim vehicula. Quisque eu tellus id erat pellentesque consequat. Maecenas fermentum faucibus magna, eget dictum nisi congue sed. Quisque a justo a nisi eleifend facilisis sit amet at augue. Sed a sapien vitae augue hendrerit porta vel eu ligula. Proin enim urna, faucibus in vestibulum tincidunt, commodo sit amet orci. Vestibulum ac sem urna, quis mattis urna. Nam eget ullamcorper ligula. Nam volutpat, arcu vel auctor dignissim, tortor nisi sodales enim, et vestibulum nulla dui id ligula. Nam ullamcorper, augue ut interdum vulputate, eros mauris lobortis sapien, ac sodales dui eros ac elit.")]
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with image") { it("should have a valid snapshot") {
                    subject.regions = [.image(image)]
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with small image") { it("should have a valid snapshot") {
                    subject.regions = [.image(smallImage)]
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with image and buyButton link") { it("should have a valid snapshot") {
                    subject.regions = [.image(image)]
                    subject.buyButtonURL = URL(string: "https://ello.co")
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with small image and buyButton link") { it("should have a valid snapshot") {
                    subject.regions = [.image(smallImage)]
                    subject.buyButtonURL = URL(string: "https://ello.co")
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
            }

            context("editing a post") {
                beforeEach {
                    subject.canGoBack = true
                    subject.title = InterfaceString.Omnibar.EditPostTitle
                    subject.submitTitle = InterfaceString.Omnibar.EditPostButton
                    subject.isEditing = true
                }
                context("with text") { it("should have a valid snapshot") {
                    subject.regions = [.text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc consectetur molestie faucibus. Phasellus iaculis pellentesque felis eu fringilla. Ut in sollicitudin nisi. Praesent in mauris tortor. Nam interdum, magna eu pellentesque scelerisque, dui ipsum adipiscing ante, vel ullamcorper nisl sapien id arcu. Nullam egestas diam eu felis mollis sit amet cursus enim vehicula. Quisque eu tellus id erat pellentesque consequat. Maecenas fermentum faucibus magna, eget dictum nisi congue sed. Quisque a justo a nisi eleifend facilisis sit amet at augue. Sed a sapien vitae augue hendrerit porta vel eu ligula. Proin enim urna, faucibus in vestibulum tincidunt, commodo sit amet orci. Vestibulum ac sem urna, quis mattis urna. Nam eget ullamcorper ligula. Nam volutpat, arcu vel auctor dignissim, tortor nisi sodales enim, et vestibulum nulla dui id ligula. Nam ullamcorper, augue ut interdum vulputate, eros mauris lobortis sapien, ac sodales dui eros ac elit.")]
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with image") { it("should have a valid snapshot") {
                    subject.regions = [.image(image)]
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with image and buyButton link") { it("should have a valid snapshot") {
                    subject.regions = [.image(image)]
                    subject.buyButtonURL = URL(string: "https://ello.co")
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
            }

            context("creating a comment") {
                beforeEach {
                    subject.canGoBack = true
                    subject.title = InterfaceString.Omnibar.CreateCommentTitle
                    subject.submitTitle = InterfaceString.Omnibar.CreateCommentButton
                    subject.isComment = true
                }
                context("empty") { it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with text") { it("should have a valid snapshot") {
                    subject.regions = [.text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc consectetur molestie faucibus. Phasellus iaculis pellentesque felis eu fringilla. Ut in sollicitudin nisi. Praesent in mauris tortor. Nam interdum, magna eu pellentesque scelerisque, dui ipsum adipiscing ante, vel ullamcorper nisl sapien id arcu. Nullam egestas diam eu felis mollis sit amet cursus enim vehicula. Quisque eu tellus id erat pellentesque consequat. Maecenas fermentum faucibus magna, eget dictum nisi congue sed. Quisque a justo a nisi eleifend facilisis sit amet at augue. Sed a sapien vitae augue hendrerit porta vel eu ligula. Proin enim urna, faucibus in vestibulum tincidunt, commodo sit amet orci. Vestibulum ac sem urna, quis mattis urna. Nam eget ullamcorper ligula. Nam volutpat, arcu vel auctor dignissim, tortor nisi sodales enim, et vestibulum nulla dui id ligula. Nam ullamcorper, augue ut interdum vulputate, eros mauris lobortis sapien, ac sodales dui eros ac elit.")]
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with image") { it("should have a valid snapshot") {
                    subject.regions = [.image(image)]
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
            }

            context("editing a comment") {
                beforeEach {
                    subject.canGoBack = true
                    subject.title = InterfaceString.Omnibar.EditCommentTitle
                    subject.submitTitle = InterfaceString.Omnibar.EditCommentButton
                    subject.isComment = true
                    subject.isEditing = true
                }
                context("with text") { it("should have a valid snapshot") {
                    subject.regions = [.text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc consectetur molestie faucibus. Phasellus iaculis pellentesque felis eu fringilla. Ut in sollicitudin nisi. Praesent in mauris tortor. Nam interdum, magna eu pellentesque scelerisque, dui ipsum adipiscing ante, vel ullamcorper nisl sapien id arcu. Nullam egestas diam eu felis mollis sit amet cursus enim vehicula. Quisque eu tellus id erat pellentesque consequat. Maecenas fermentum faucibus magna, eget dictum nisi congue sed. Quisque a justo a nisi eleifend facilisis sit amet at augue. Sed a sapien vitae augue hendrerit porta vel eu ligula. Proin enim urna, faucibus in vestibulum tincidunt, commodo sit amet orci. Vestibulum ac sem urna, quis mattis urna. Nam eget ullamcorper ligula. Nam volutpat, arcu vel auctor dignissim, tortor nisi sodales enim, et vestibulum nulla dui id ligula. Nam ullamcorper, augue ut interdum vulputate, eros mauris lobortis sapien, ac sodales dui eros ac elit.")]
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("with image") { it("should have a valid snapshot") {
                    subject.regions = [.image(image)]
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
            }
            context("reordering") {
                context("image") { it("should have a valid snapshot") {
                    subject.regions = [.image(image)]
                    subject.reorderingTable(true)
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("multiple images") { it("should have a valid snapshot") {
                    subject.regions = [.image(image), .image(smallImage), .image(image)]
                    subject.reorderingTable(true)
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
                context("small image") { it("should have a valid snapshot") {
                    subject.regions = [.image(smallImage)]
                    subject.reorderingTable(true)
                    expectValidSnapshot(subject, device: .phone6_Portrait)
                } }
            }
        }
    }
}
