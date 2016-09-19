////
///  AssetSpec.swift
//

import Ello
import Quick
import Nimble


class AssetSpec: QuickSpec {
    override func spec() {
        context("gifs") {
            it("should return 'true' for 'isGif'") {
                let attachment: Attachment = stub(["type": "image/gif"])
                let asset: Asset = stub(["optimized": attachment])
                expect(asset.isGif).to(beTrue())
            }
        }
        context("large gifs") {
            it("should return 'true' for 'isLargeGif'") {
                let attachment: Attachment = stub(["size": 4_100_000, "type": "image/gif"])
                let asset: Asset = stub(["optimized": attachment])
                expect(asset.isLargeGif).to(beTrue())
            }
        }
        context("small gifs") {
            it("should return 'false' for 'isLargeGif'") {
                let attachment: Attachment = stub(["size": 2_000_000, "type": "image/gif"])
                let asset: Asset = stub(["optimized": attachment])
                expect(asset.isGif).to(beTrue())
                expect(asset.isLargeGif).to(beFalse())
            }
        }

        describe("+fromJSON:") {

            beforeEach {
                ElloURI.httpProtocol = "https"
            }

            it("parses correctly") {
                let data = stubbedJSONData("asset", "assets")
                let asset = Asset.fromJSON(data) as! Asset

                expect(asset.id) == "5381"

                let optimized = asset.optimized!
                expect(optimized.url.absoluteString) == "https://example.com/5381/optimized.jpg"
                expect(optimized.size) == 728689
                expect(optimized.type) == "image/jpeg"
                expect(optimized.width) == 2560
                expect(optimized.height) == 1094

                let smallScreen = asset.smallScreen!
                expect(smallScreen.url.absoluteString) == "https://example.com/5381/small_screen.jpg"
                expect(smallScreen.size) == 58160
                expect(smallScreen.type) == "image/jpeg"
                expect(smallScreen.width) == 640
                expect(smallScreen.height) == 274

                let ldpi = asset.ldpi!
                expect(ldpi.url.absoluteString) == "https://example.com/5381/ldpi.jpg"
                expect(ldpi.size) == 4437
                expect(ldpi.type) == "image/jpeg"
                expect(ldpi.width) == 150
                expect(ldpi.height) == 64

                let mdpi = asset.mdpi!
                expect(mdpi.url.absoluteString) == "https://example.com/5381/mdpi.jpg"
                expect(mdpi.size) == 21813
                expect(mdpi.type) == "image/jpeg"
                expect(mdpi.width) == 375
                expect(mdpi.height) == 160

                let hdpi = asset.hdpi!
                expect(hdpi.url.absoluteString) == "https://example.com/5381/hdpi.jpg"
                expect(hdpi.size) == 77464
                expect(hdpi.type) == "image/jpeg"
                expect(hdpi.width) == 750
                expect(hdpi.height) == 321

                let xhdpi = asset.xhdpi!
                expect(xhdpi.url.absoluteString) == "https://example.com/5381/xhdpi.jpg"
                expect(xhdpi.size) == 274363
                expect(xhdpi.type) == "image/jpeg"
                expect(xhdpi.width) == 1500
                expect(xhdpi.height) == 641

                let original = asset.original!
                expect(original.url.absoluteString) == "https://example.com/5381/original.jpg"
                expect(original.size) == 728689
                expect(original.type) == "image/jpeg"
                expect(original.width) == 2560
                expect(original.height) == 1094
            }
        }

        context("NSCoding") {

            var filePath = ""
            if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                filePath = url.URLByAppendingPathComponent("AssetSpec")!.absoluteString!
            }

            afterEach {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(filePath)
                }
                catch {

                }
            }

            context("encoding") {

                it("encodes successfully") {
                    let asset: Asset = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(asset, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {

                    let optimized: Attachment = stub([
                        "url" : NSURL(string: "http://www.example1.com")!,
                        "height" : 10,
                        "width" : 20,
                        "type" : "jpeg",
                        "size" : 111111
                    ])

                    let smallScreen: Attachment = stub([
                        "url" : NSURL(string: "http://www.example2.com")!,
                        "height" : 20,
                        "width" : 30,
                        "type" : "jpeg",
                        "size" : 222222
                    ])

                    let ldpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example3.com")!,
                        "height" : 30,
                        "width" : 40,
                        "type" : "jpeg",
                        "size" : 333333
                    ])

                    let mdpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example4.com")!,
                        "height" : 40,
                        "width" : 50,
                        "type" : "jpeg",
                        "size" : 444444
                    ])

                    let hdpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example5.com")!,
                        "height" : 50,
                        "width" : 60,
                        "type" : "jpeg",
                        "size" : 555555
                    ])

                    let xhdpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example6.com")!,
                        "height" : 60,
                        "width" : 70,
                        "type" : "jpeg",
                        "size" : 666666
                    ])

                    let original: Attachment = stub([
                        "url" : NSURL(string: "http://www.example8.com")!,
                        "height" : 80,
                        "width" : 90,
                        "type" : "jpeg",
                        "size" : 888888
                    ])

                    let asset: Asset = stub([
                        "id" : "5698",
                        "optimized" : optimized,
                        "smallScreen" : smallScreen,
                        "ldpi" : ldpi,
                        "mdpi" : mdpi,
                        "hdpi" : hdpi,
                        "xhdpi" : xhdpi,
                        "original" : original
                    ])

                    NSKeyedArchiver.archiveRootObject(asset, toFile: filePath)
                    let unArchivedAsset = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Asset

                    expect(unArchivedAsset).toNot(beNil())
                    expect(unArchivedAsset.version) == 1

                    expect(unArchivedAsset.id) == "5698"

                    let unArchivedOptimized = unArchivedAsset.optimized!

                    expect(unArchivedOptimized.url.absoluteString) == "http://www.example1.com"
                    expect(unArchivedOptimized.width) == 20
                    expect(unArchivedOptimized.height) == 10
                    expect(unArchivedOptimized.size) == 111111
                    expect(unArchivedOptimized.type) == "jpeg"

                    let unArchivedSmallScreen = unArchivedAsset.smallScreen!

                    expect(unArchivedSmallScreen.url.absoluteString) == "http://www.example2.com"
                    expect(unArchivedSmallScreen.width) == 30
                    expect(unArchivedSmallScreen.height) == 20
                    expect(unArchivedSmallScreen.size) == 222222
                    expect(unArchivedSmallScreen.type) == "jpeg"

                    let unArchivedldpi = unArchivedAsset.ldpi!

                    expect(unArchivedldpi.url.absoluteString) == "http://www.example3.com"
                    expect(unArchivedldpi.width) == 40
                    expect(unArchivedldpi.height) == 30
                    expect(unArchivedldpi.size) == 333333
                    expect(unArchivedldpi.type) == "jpeg"

                    let unArchivedmdpi = unArchivedAsset.mdpi!

                    expect(unArchivedmdpi.url.absoluteString) == "http://www.example4.com"
                    expect(unArchivedmdpi.width) == 50
                    expect(unArchivedmdpi.height) == 40
                    expect(unArchivedmdpi.size) == 444444
                    expect(unArchivedmdpi.type) == "jpeg"

                    let unArchivedhdpi = unArchivedAsset.hdpi!

                    expect(unArchivedhdpi.url.absoluteString) == "http://www.example5.com"
                    expect(unArchivedhdpi.width) == 60
                    expect(unArchivedhdpi.height) == 50
                    expect(unArchivedhdpi.size) == 555555
                    expect(unArchivedhdpi.type) == "jpeg"

                    let unArchivedxhdpi = unArchivedAsset.xhdpi!

                    expect(unArchivedxhdpi.url.absoluteString) == "http://www.example6.com"
                    expect(unArchivedxhdpi.width) == 70
                    expect(unArchivedxhdpi.height) == 60
                    expect(unArchivedxhdpi.size) == 666666
                    expect(unArchivedxhdpi.type) == "jpeg"

                    let unArchivedOriginal = unArchivedAsset.original!

                    expect(unArchivedOriginal.url.absoluteString) == "http://www.example8.com"
                    expect(unArchivedOriginal.width) == 90
                    expect(unArchivedOriginal.height) == 80
                    expect(unArchivedOriginal.size) == 888888
                    expect(unArchivedOriginal.type) == "jpeg"

                }
            }
        }
    }
}
