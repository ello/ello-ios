////
///  StreamImageCellSizeCalculatorSpec.swift
//

@testable import Ello
import Foundation
import Quick
import Nimble

class StreamImageCellSizeCalculatorSpec: QuickSpec {

    override func spec() {

        describe("-aspectRatioForImageRegion(_:)") {

            it("returns 4/3 if width or height not present") {
                let imageRegion: ImageRegion = stub(["alt": "alt text", "url": "http://www.ello.com"])
                let aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
                expect(aspectRatio) == 4.0/3.0
            }

            it("returns the correct aspect ratio") {
                let hdpi: Attachment = stub([
                    "url": "http://www.ello.com",
                    "height": 1600,
                    "width": 900,
                    "type": "jpeg",
                    "size": 894578
                    ])
                let asset: Asset = stub([
                    "id": "123",
                    "hdpi": hdpi
                    ])
                let imageRegion: ImageRegion = stub([
                    "asset": asset,
                    "alt": "alt text",
                    "url": "http://www.ello.com"
                    ])
                let aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
                expect(aspectRatio) == 900.0/1600.0
            }
        }
    }
}
