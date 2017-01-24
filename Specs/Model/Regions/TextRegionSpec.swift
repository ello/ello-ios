////
///  TextRegionSpec.swift
//

@testable import Ello
import Quick
import Nimble


class TextRegionSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses correctly") {
                let data = stubbedJSONData("text-region", "region")
                let region = TextRegion.fromJSON(data) as! TextRegion

                expect(region.content) == "test text content"

            }
        }

        context("NSCoding") {

            var filePath = ""
            if let url = URL(string: FileManager.ElloDocumentsDir()) {
                filePath = url.appendingPathComponent("TextRegionSpec").absoluteString
            }

            afterEach {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                }
                catch {

                }
            }

            context("encoding") {

                it("encodes successfully") {
                    let region: TextRegion = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(region, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let region: TextRegion = stub([
                        "content" : "test-content"
                    ])

                    NSKeyedArchiver.archiveRootObject(region, toFile: filePath)
                    let unArchivedRegion = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! TextRegion

                    expect(unArchivedRegion).toNot(beNil())
                    expect(unArchivedRegion.version) == 1
                    expect(unArchivedRegion.content) == "test-content"
                }
            }
        }
    }
}
