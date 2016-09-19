////
///  AttachmentSpec.swift
//

import Ello
import Quick
import Nimble


class AttachmentSpec: QuickSpec {
    override func spec() {

        context("NSCoding") {

            var filePath = ""
            if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                filePath = url.URLByAppendingPathComponent("ImageAttachmentSpec")!.absoluteString!
            }
            ElloURI.httpProtocol = "https"

            afterEach {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(filePath)
                }
                catch {

                }
            }

            context("encoding") {

                it("encodes successfully") {
                    let imageAttachment: Attachment = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(imageAttachment, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let imageAttachment: Attachment = stub([
                        "url" : NSURL(string: "https://www.example12.com")!,
                        "height" : 456,
                        "width" : 110,
                        "type" : "png",
                        "size" : 78787
                    ])

                    NSKeyedArchiver.archiveRootObject(imageAttachment, toFile: filePath)
                    let unArchivedAttachment = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Attachment

                    expect(unArchivedAttachment).toNot(beNil())
                    expect(unArchivedAttachment.version) == 1
                    expect(unArchivedAttachment.url.absoluteString) == "https://www.example12.com"
                    expect(unArchivedAttachment.height) == 456
                    expect(unArchivedAttachment.width) == 110
                    expect(unArchivedAttachment.size) == 78787
                    expect(unArchivedAttachment.type) == "png"
                }
            }

        }
    }
}
