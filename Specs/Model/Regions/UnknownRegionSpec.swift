////
///  UnknownRegionSpec.swift
//

@testable import Ello
import Quick
import Nimble


class UnknownRegionSpec: QuickSpec {
    override func spec() {

        context("NSCoding") {

            var filePath = ""
            if let url = URL(string: FileManager.ElloDocumentsDir()) {
                filePath = url.appendingPathComponent("UnknownRegionSpec").absoluteString
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
                    let region: UnknownRegion = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(region, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {

                    let region: UnknownRegion = stub([:])

                    NSKeyedArchiver.archiveRootObject(region, toFile: filePath)
                    let unArchivedRegion = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! UnknownRegion

                    expect(unArchivedRegion).toNot(beNil())
                    expect(unArchivedRegion.version) == 1
                }
            }
        }
    }
}
