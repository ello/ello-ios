////
///  TmpSpec.swift
//

import Ello
import Quick
import Nimble


class TmpSpec: QuickSpec {
    override func spec() {
        describe("Tmp.fileExists") {
            it("should return false") {
                expect(Tmp.fileExists("non sensical file name")).to(equal(false))
            }

            it("should return true") {

                var directoryName = ""
                if let url = NSURL(string: NSTemporaryDirectory()) {
                    directoryName = url.URLByAppendingPathComponent(Tmp.uniqDir)!.absoluteString!
                }

                let directoryURL = NSURL.fileURLWithPath(directoryName, isDirectory: true)
                try! NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)

                let fileName = "exists"
                let fileURL = directoryURL.URLByAppendingPathComponent(fileName)!
                if let filePath = fileURL.path {
                    let data = NSData()
                    data.writeToURL(fileURL, atomically: true)

                    let doesActuallyExist = NSFileManager.defaultManager().fileExistsAtPath(filePath)
                    expect(doesActuallyExist).to(beTrue())
                    expect(Tmp.fileExists("exists")).to(beTrue())
                }
                else {
                    fail("could not create fileURL.path")
                }
            }
        }

        describe("Tmp.directoryURL") {
            it("should be consistent") {
                let dir1 = Tmp.directoryURL()
                let dir2 = Tmp.directoryURL()
                expect(dir1).to(equal(dir2))
            }
        }

        describe("Tmp.fileURL") {
            it("should be a URL") {
                let fileURL = Tmp.fileURL("filename")
                expect(fileURL).to(beAKindOf(NSURL))
            }
        }

        describe("creating a file") {
            it("+Tmp.write(NSData)") {                      // "test"
                let originalData = NSData(base64EncodedString: "dGVzdA==", options: NSDataBase64DecodingOptions())!
                _ = Tmp.write(originalData, to: "file")
                if let readData : NSData = Tmp.read("file") {
                    expect(readData).to(equal(originalData))
                }
                else {
                    fail("could not read 'file'")
                }
            }

            it("+Tmp.write(String)") {
                let originalString = "test"
                _ = Tmp.write(originalString, to: "string")
                if let readString : String = Tmp.read("string") {
                    expect(readString).to(equal(originalString))
                }
                else {
                    fail("could not read 'string'")
                }
            }

            it("+Tmp.write(UIImage)") {
                let originalImage = UIImage(named: "specs-avatar", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)!
                _ = Tmp.write(originalImage, to: "image")
                if let readImage : UIImage = Tmp.read("image") {
                    let readData = UIImagePNGRepresentation(readImage)
                    let originalData = UIImagePNGRepresentation(originalImage)
                    expect(readData).to(equal(originalData))
                }
                else {
                    fail("could not read 'image'")
                }
            }
        }
    }
}
