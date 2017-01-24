////
///  ImageRegionSpec.swift
//

import Foundation
@testable import Ello
import Quick
import Nimble

class ImageRegionSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses image region correctly") {
                let imageRegionData = stubbedJSONData("image-region", "region")
                let region = ImageRegion.fromJSON(imageRegionData) as! ImageRegion

                expect(region.url!.absoluteString) == "https://example.com/test.jpg"
                expect(region.alt) == "region-alt.jpeg"

                let asset = region.asset!
                expect(asset.id) == "85"

                let hdpi = asset.hdpi!
                expect(hdpi.url.absoluteString) == "https://example.com/85/hdpi.jpg"
                expect(hdpi.size) == 77464
                expect(hdpi.type) == "image/jpeg"
                expect(hdpi.width) == 750
                expect(hdpi.height) == 321

                let xhdpi = asset.xhdpi!
                expect(xhdpi.url.absoluteString) == "https://example.com/85/xhdpi.jpg"
                expect(xhdpi.size) == 274363
                expect(xhdpi.type) == "image/jpeg"
                expect(xhdpi.width) == 1500
                expect(xhdpi.height) == 641
            }

            it("parses protocol relative URLs correctly") {
                var imageRegionData = stubbedJSONData("image-region", "region")
                guard var data = imageRegionData["data"] as? [String: String],
                    let urlString = data["url"] else
                {
                    fail("image-region.json does not have data.url")
                    return
                }

                data["url"] = urlString.replacingOccurrences(of: "https://", with: "//")
                expect(data["url"]) == "//example.com/test.jpg"
                imageRegionData["data"] = data as AnyObject
                let region = ImageRegion.fromJSON(imageRegionData) as! ImageRegion

                expect(region.url!.absoluteString) == "https://example.com/test.jpg"
                expect(region.alt) == "region-alt.jpeg"
            }

            it("parses buy-button region correctly") {
                let imageRegionData = stubbedJSONData("buy-button-image-region", "region")
                let region = ImageRegion.fromJSON(imageRegionData) as! ImageRegion

                expect(region.url!.absoluteString) == "https://example.com/test.jpg"
                expect(region.buyButtonURL!.absoluteString) == "https://amazon.com"
                expect(region.alt) == "region-alt.jpeg"

                let asset = region.asset!
                expect(asset.id) == "85"

                let hdpi = asset.hdpi!
                expect(hdpi.url.absoluteString) == "https://example.com/85/hdpi.jpg"
                expect(hdpi.size) == 77464
                expect(hdpi.type) == "image/jpeg"
                expect(hdpi.width) == 750
                expect(hdpi.height) == 321

                let xhdpi = asset.xhdpi!
                expect(xhdpi.url.absoluteString) == "https://example.com/85/xhdpi.jpg"
                expect(xhdpi.size) == 274363
                expect(xhdpi.type) == "image/jpeg"
                expect(xhdpi.width) == 1500
                expect(xhdpi.height) == 641
            }

        }

        context("NSCoding") {

            var filePath = ""
            if let url = URL(string: FileManager.ElloDocumentsDir()) {
                filePath = url.appendingPathComponent("ImageRegionSpec").absoluteString
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
                    let region: ImageRegion = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(region, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let hdpi: Attachment = stub([
                        "url": URL(string: "http://www.example.com")!,
                        "height": 2,
                        "width": 5,
                        "type": "jpeg",
                        "size": 45644
                    ])

                    let xhdpi: Attachment = stub([
                        "url": URL(string: "http://www.example2.com")!,
                        "height": 67,
                        "width": 999,
                        "type": "png",
                        "size": 114574
                    ])

                    let asset: Asset = stub([
                        "id": "qwerty",
                        "hdpi": hdpi,
                        "xhdpi": xhdpi
                    ])

                    let imageRegion: ImageRegion = stub([
                        "asset": asset,
                        "alt": "some-altness",
                        "url": URL(string: "http://www.example5.com")!
                    ])

                    NSKeyedArchiver.archiveRootObject(imageRegion, toFile: filePath)
                    let unArchivedRegion = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as! ImageRegion

                    expect(unArchivedRegion).toNot(beNil())
                    expect(unArchivedRegion.version) == 1

                    expect(unArchivedRegion.url!.absoluteString) == "http://www.example5.com"
                    expect(unArchivedRegion.alt) == "some-altness"

                    let unArchivedAsset = unArchivedRegion.asset!
                    expect(unArchivedAsset.id) == "qwerty"

                    let unArchivedHdpi = unArchivedAsset.hdpi!
                    expect(unArchivedHdpi.url.absoluteString) == "http://www.example.com"
                    expect(unArchivedHdpi.size) == 45644
                    expect(unArchivedHdpi.type) == "jpeg"
                    expect(unArchivedHdpi.width) == 5
                    expect(unArchivedHdpi.height) == 2

                    let unArchivedXhdpi = unArchivedAsset.xhdpi!
                    expect(unArchivedXhdpi.url.absoluteString) == "http://www.example2.com"
                    expect(unArchivedXhdpi.size) == 114574
                    expect(unArchivedXhdpi.type) == "png"
                    expect(unArchivedXhdpi.width) == 999
                    expect(unArchivedXhdpi.height) == 67
                }
            }
        }
    }
}
