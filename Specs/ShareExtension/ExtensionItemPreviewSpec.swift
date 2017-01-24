////
///  ExtensionItemPreviewSpec.swift
//

@testable import Ello
import Quick
import Nimble

class ExtensionItemPreviewSpec: QuickSpec {
    override func spec() {

        describe("ExtensionItemPreview") {

            describe("==") {
                let imageA = UIImage()
                let imageB = UIImage()
                let dataA = Data()
                let dataB = Data(base64Encoded: "dGVzdA==")!
                let dataC = Data(base64Encoded: "dGVzdA==")!
                let urlA = URL(string: "https://ello.co")
                let urlB = URL(string: "https://ello.co")
                let urlC = URL(string: "https://status.ello.co")

                let tests: [(Bool, ExtensionItemPreview, ExtensionItemPreview)] = [
                    (true, ExtensionItemPreview(), ExtensionItemPreview()),
                    (true, ExtensionItemPreview(image: imageA), ExtensionItemPreview(image: imageA)),
                    (true, ExtensionItemPreview(imagePath: urlA), ExtensionItemPreview(imagePath: urlB)),
                    (true, ExtensionItemPreview(gifData: dataA), ExtensionItemPreview(gifData: dataA)),
                    (true, ExtensionItemPreview(gifData: dataB), ExtensionItemPreview(gifData: dataC)),
                    (true, ExtensionItemPreview(text: "text"), ExtensionItemPreview(text: "text")),
                    (true, ExtensionItemPreview(image: imageA, text: "text"), ExtensionItemPreview(image: imageA, text: "text")),
                    (true, ExtensionItemPreview(image: imageB, imagePath: urlA, text: "text"), ExtensionItemPreview(image: imageB, imagePath: urlB, text: "text")),
                    (false, ExtensionItemPreview(imagePath: urlA), ExtensionItemPreview(imagePath: urlC)),
                    (false, ExtensionItemPreview(image: imageA, text: "text"), ExtensionItemPreview(image: imageB, text: "text")),
                    (false, ExtensionItemPreview(image: imageB, imagePath: urlA, text: "text"), ExtensionItemPreview(image: imageB, imagePath: urlB, text: "different text")),
                    (false, ExtensionItemPreview(gifData: dataA), ExtensionItemPreview(gifData: dataB)),
                ]

                for (equal, a, b) in tests {

                    it("identifies equality correctly") {
                        expect(a == b) == equal
                    }

                }
            }
        }
    }
}
