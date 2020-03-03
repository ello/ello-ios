////
///  ImageRegionSpec.swift
//

@testable import Ello
import Quick
import Nimble

class ImageRegionSpec: QuickSpec {
    override func spec() {
        describe("ImageRegion") {

            it("parses protocol relative URLs correctly") {
                var imageRegionData = stubbedJSONData("image-region", "region")
                guard var data = imageRegionData["data"] as? [String: String],
                    let urlString = data["url"]
                else {
                    fail("image-region.json does not have data.url")
                    return
                }

                data["url"] = urlString.replacingOccurrences(of: "https://", with: "//")
                expect(data["url"]) == "//example.com/test.jpg"
                imageRegionData["data"] = data
                let region = ImageRegion.fromJSON(imageRegionData)

                expect(region.url!.absoluteString) == "https://example.com/test.jpg"
            }

            it("parses buy-button region correctly") {
                let imageRegionData = stubbedJSONData("buy-button-image-region", "region")
                let region = ImageRegion.fromJSON(imageRegionData)

                expect(region.url!.absoluteString) == "https://example.com/test.jpg"
                expect(region.buyButtonURL!.absoluteString) == "https://amazon.com"

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
    }
}
