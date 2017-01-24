////
///  NSItemProviderExtensionsSpec.swift
//

@testable import Ello
import Quick
import Nimble

class NSItemProviderExtensionsSpec: QuickSpec {
    override func spec() {

        describe("NSItemProviderExtensions") {

            describe("isURL()") {

                it("returns true when it is a url") {
                    let item = NSItemProvider(item: URL(string: "https://ello.co") as NSSecureCoding?, typeIdentifier: String(kUTTypeURL))
                    expect(item.isURL()) == true
                }

                it("returns false when it is not a url") {
                    let item = NSItemProvider(item: "not a url" as NSSecureCoding?, typeIdentifier: String(kUTTypeText))
                    expect(item.isURL()) == false
                }
            }

            describe("isImage()") {

                it("returns true when it is an image") {
                    let item = NSItemProvider(item: UIImage(), typeIdentifier: String(kUTTypeImage))
                    expect(item.isImage()) == true
                }

                it("returns false when it is not an image") {
                    let item = NSItemProvider(item: "not an image" as NSSecureCoding?, typeIdentifier: String(kUTTypeText))
                    expect(item.isImage()) == false
                }
            }

            describe("isText()") {

                it("returns true when it is text") {
                    let item = NSItemProvider(item: "it is text!" as NSSecureCoding?, typeIdentifier: String(kUTTypeText))
                    expect(item.isText()) == true
                }

                it("returns true when it is not text") {
                    let item = NSItemProvider(item: URL(string: "https://ello.co") as NSSecureCoding?, typeIdentifier: String(kUTTypeURL))
                    expect(item.isText()) == false
                }
            }

            describe("loadText(_:completion)") {

                xit("returns text") {
                    let item = NSItemProvider(item: "it is text!" as NSSecureCoding?, typeIdentifier: String(kUTTypeText))
                    waitUntil(timeout: 30) { done in
                        item.loadText(nil) { (item, error) in
                            if let item = item as? String {
                                expect(item) == "it is text!"
                            }
                            done()
                        }
                    }
                }
            }

            describe("loadURL(_:completion)") {

                xit("returns a url") {
                    let item = NSItemProvider(item: URL(string: "https://ello.co") as NSSecureCoding?, typeIdentifier: String(kUTTypeURL))
                    waitUntil(timeout: 30) { done in
                        item.loadURL(nil) { (item, error) in
                            if let item = item as? URL {
                                expect(item) == URL(string: "https://ello.co")
                            }
                            else {
                                fail("did not receive expected url in item")
                            }
                            done()
                        }
                    }
                }
            }

            describe("loadImage(_:completion)") {

                xit("returns an image") {
                    let expectedImage = UIImage()
                    let item = NSItemProvider(item: expectedImage, typeIdentifier: String(kUTTypeImage))
                    waitUntil(timeout: 30) { done in
                        item.loadImage(nil) { (item, error) in
                            if let image = item as? UIImage {
                                expect(image) == expectedImage
                            }
                            done()
                        }
                    }
                }
            }

            xdescribe("loadPreview(_:completion)") {
                // no idea how to create an NSItemProvider to test against here
            }
        }
    }
}
