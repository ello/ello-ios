////
///  TmpSpec.swift
//

@testable import Ello
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
                if let url = URL(string: NSTemporaryDirectory()) {
                    directoryName = url.appendingPathComponent(Tmp.uniqDir).absoluteString
                }

                let directoryURL = URL(fileURLWithPath: directoryName, isDirectory: true)
                try! FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)

                let fileName = "exists"
                let fileURL = directoryURL.appendingPathComponent(fileName)
                let filePath = fileURL.path
                let data = Data()
                try! data.write(to: fileURL, options: [.atomic])

                let doesActuallyExist = FileManager.default.fileExists(atPath: filePath)
                expect(doesActuallyExist).to(beTrue())
                expect(Tmp.fileExists("exists")).to(beTrue())
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
                expect(fileURL).notTo(beNil())
            }
        }

        describe("creating a file") {
            it("+Tmp.write(Data)") {                      // "test"
                let originalData = Data(base64Encoded: "dGVzdA==")!
                _ = Tmp.write(originalData, to: "file")
                if let readData : Data = Tmp.read("file") {
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
                let originalImage = specImage(named: "specs-avatar")!
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
