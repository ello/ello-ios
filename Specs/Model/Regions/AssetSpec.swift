////
///  AssetSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AssetSpec: QuickSpec {
    override func spec() {
        describe("Asset") {
            let mdpi: Attachment = stub([:])
            let hdpi: Attachment = stub([:])
            let xhdpi: Attachment = stub([:])
            let noVideoAsset: Asset = stub(["hdpi": hdpi, "xhdpi": xhdpi, "mdpi": mdpi])

            describe("aspectRatio") {

                it("returns correct aspect ratio when hdpi present") {
                    let attachment: Attachment = stub(["width": 15, "height": 5])
                    let asset: Asset = stub(["hdpi": attachment])
                    expect(asset.aspectRatio) == 3.0
                }

                it("returns correct aspect ratio when only optimized present") {
                    let attachment: Attachment = stub(["width": 5, "height": 5])
                    let asset: Asset = stub(["optimized": attachment])
                    expect(asset.aspectRatio) == 1.0
                }

                it("returns correct aspect ratio when no attachments available") {
                    let asset: Asset = stub([:])
                    expect(asset.aspectRatio) == 4.0 / 3.0
                }
            }

            describe("oneColumnAttachment") {

                it("returns hdpi when narrow") {
                    expect(noVideoAsset.oneColumnAttachment) == hdpi
                }

                it("returns xhdpi when wide") {
                    let tmp = Window.width
                    Window.width = 2000
                    expect(noVideoAsset.oneColumnAttachment) == xhdpi
                    Window.width = tmp
                }

                it("returns hdpi when wide on non-retina screen") {
                    let tmpWidth = Window.width
                    let tmpScale = DeviceScreen.scale
                    Window.width = 2000
                    DeviceScreen.scale = 1

                    expect(noVideoAsset.oneColumnAttachment) == hdpi
                    Window.width = tmpWidth
                    DeviceScreen.scale = tmpScale
                }
            }

            describe("gridLayoutAttachment") {

                it("returns hdpi when wide") {
                    let tmp = Window.width
                    Window.width = 2000
                    expect(noVideoAsset.gridLayoutAttachment) == hdpi
                    Window.width = tmp
                }

                it("returns mdpi when wide on non-retina screen") {
                    let tmpWidth = Window.width
                    let tmpScale = DeviceScreen.scale
                    Window.width = 2000
                    DeviceScreen.scale = 1

                    expect(noVideoAsset.gridLayoutAttachment) == mdpi
                    Window.width = tmpWidth
                    DeviceScreen.scale = tmpScale
                }

                it("returns mdpi when not wide") {
                    expect(noVideoAsset.gridLayoutAttachment) == mdpi
                }
            }

            context("gifs") {

                it("returns 'true' for 'isGif' - optimized image - content type") {
                    let attachment: Attachment = stub(["type": "image/gif"])
                    let asset: Asset = stub(["optimized": attachment])
                    expect(asset.isGif) == true
                }

                it("returns 'true' for 'isGif' - optimized image - url") {
                    let attachment: Attachment = stub(["url": "http://image.com/image.gif"])
                    let asset: Asset = stub(["optimized": attachment])
                    expect(asset.isGif) == true
                }

                it("returns 'true' for 'isGif' - original image - content type") {
                    let attachment: Attachment = stub(["type": "image/gif"])
                    let asset: Asset = stub(["original": attachment])
                    expect(asset.isGif) == true
                }

                it("returns 'true' for 'isGif' - original image - url") {
                    let attachment: Attachment = stub(["url": "http://image.com/image.gif"])
                    let asset: Asset = stub(["original": attachment])
                    expect(asset.isGif) == true
                }

                it("returns 'true' for 'isLargeGif'") {
                    let attachment: Attachment = stub(["size": 4_100_000, "type": "image/gif"])
                    let asset: Asset = stub(["optimized": attachment])
                    expect(asset.isLargeGif) == true
                }

                it("returns 'false' for 'isLargeGif'") {
                    let attachment: Attachment = stub(["size": 2_000_000, "type": "image/gif"])
                    let asset: Asset = stub(["optimized": attachment])
                    expect(asset.isGif) == true
                    expect(asset.isLargeGif) == false
                }
            }
        }
    }
}
