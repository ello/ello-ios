////
///  ShareAttachmentProcessorSpec.swift
//

@testable import Ello
import Quick
import Nimble

class ShareAttachmentProcessorSpec: QuickSpec {
    class FakeItemProvider: NSItemProvider {
        let typeIdentifier: String
        let item: NSSecureCoding

        override init(item: NSSecureCoding?, typeIdentifier: String?) {
            self.typeIdentifier = typeIdentifier!
            self.item = item!
            super.init(item: item, typeIdentifier: typeIdentifier)
        }

        override func loadItem(forTypeIdentifier typeIdentifier: String, options: [AnyHashable: Any]?, completionHandler: NSItemProvider.CompletionHandler?) {
            if typeIdentifier == self.typeIdentifier {
                completionHandler?(item, nil)
            }
            else {
                completionHandler?(nil, nil)
            }
        }
    }

    override func spec() {

        describe("ShareAttachmentProcessor") {

            var itemPreviews: [ExtensionItemPreview] = []

            afterEach {
                itemPreviews = []
            }

            describe("preview(_:callback)") {

                var fileURL: URL!
                beforeEach {
                    let tempURL = try! FileManager.default.url(for: .sharedPublicDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    fileURL = tempURL.appendingPathComponent("ShareAttachmentProcessorSpec")
                }

                afterEach {
                    do { try FileManager.default.removeItem(atPath: fileURL?.path ?? "") }
                    catch { }
                }

                it("loads url items") {
                    let extensionItem = NSExtensionItem()
                    let image = specImage(named: "specs-avatar")!
                    let imageAsData = UIImagePNGRepresentation(image)
                    try? imageAsData?.write(to: fileURL, options: [.atomic])

                    extensionItem.attachments = [
                        FakeItemProvider(item: URL(string: "https://ello.co") as NSSecureCoding?, typeIdentifier: String(kUTTypeURL)),
                        FakeItemProvider(item: "hello" as NSSecureCoding?, typeIdentifier: String(kUTTypeText)),
                        FakeItemProvider(item: fileURL as NSSecureCoding?, typeIdentifier: String(kUTTypeImage))
                    ]

                    let urlPreview = ExtensionItemPreview(text: "https://ello.co")
                    let textPreview = ExtensionItemPreview(text: "hello")

                    ShareAttachmentProcessor.preview(extensionItem) { previews in
                        itemPreviews = previews
                        expect(itemPreviews.count) == 3
                        expect(itemPreviews[0] == urlPreview).to(beTrue())
                        expect(itemPreviews[1] == textPreview).to(beTrue())
                        expect(itemPreviews[2].image).notTo(beNil())
                    }
                }

                it("filters out duplicate url items") {
                    let extensionItem = NSExtensionItem()

                    extensionItem.attachments = [
                        FakeItemProvider(item: URL(string: "https://ello.co") as NSSecureCoding?, typeIdentifier: String(kUTTypeURL)),
                        FakeItemProvider(item: "https://ello.co" as NSSecureCoding?, typeIdentifier: String(kUTTypeText))
                    ]

                    let urlPreview = ExtensionItemPreview(text: "https://ello.co")

                    ShareAttachmentProcessor.preview(extensionItem) { previews in
                        itemPreviews = previews
                        expect(itemPreviews[0] == urlPreview).to(beTrue())
                        expect(itemPreviews.count) == 1
                    }
                }
            }

            describe("hasContent(_:)") {
                context("has something to share") {
                    let extensionItem = NSExtensionItem()

                    extensionItem.attachments = [
                        FakeItemProvider(item: URL(string: "https://ello.co") as NSSecureCoding?, typeIdentifier: String(kUTTypeURL)),
                        FakeItemProvider(item: "https://ello.co" as NSSecureCoding?, typeIdentifier: String(kUTTypeText))
                    ]

                    it("returns true if content text is present and extension item is nil") {
                        expect(ShareAttachmentProcessor.hasContent("content", extensionItem: nil)) == true
                    }

                    it("returns true if content text is nil and extension item is present") {
                        expect(ShareAttachmentProcessor.hasContent(nil, extensionItem: extensionItem)) == true
                    }

                    it("returns true if content text is present and extension item is present") {
                        expect(ShareAttachmentProcessor.hasContent("content", extensionItem: extensionItem)) == true
                    }

                }

                context("has nothing to share") {

                    it("returns false if nothing is present") {
                        expect(ShareAttachmentProcessor.hasContent(nil, extensionItem: nil)) == false
                    }
                }
            }
        }
    }
}
