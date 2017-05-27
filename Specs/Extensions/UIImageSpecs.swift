////
///  UIImageSpecs.swift
//

@testable import Ello
import Quick
import Nimble


class UIImageSpecs: QuickSpec {
    override func spec() {
        var image: UIImage!
        var oriented: UIImage!

        describe("isGif") {
            let isGif = Data(base64Encoded: "R0lGODdhCg==")!
            let notGif = Data(base64Encoded: "dGVzdA==")!
            it("is a gif") {
                expect(UIImage.isGif(isGif)) == true
            }
            it("is not a gif") {
                expect(UIImage.isGif(notGif)) == false
            }
        }

        describe("copyWithCorrectOrientationAndSize") {

            context("no scaling") {
                beforeEach {
                    image = specImage(named: "specs-avatar")!
                    image.copyWithCorrectOrientationAndSize { image in
                        oriented = image
                    }
                }

                it("returns an image") {
                    expect(oriented).to(beAKindOf(UIImage.self))
                }

                it("with the correct size") {
                    expect(oriented.size).to(equal(image.size))
                }

                it("with the correct scale") {
                    expect(oriented.scale).to(equal(image.scale))
                }
            }

            context("scaling when width is greater than max") {
                beforeEach {
                    image = specImage(named: "specs-4000x1000")!
                    image.copyWithCorrectOrientationAndSize { image in
                        oriented = image
                    }
                }

                it("scales to the maxWidth") {
                    expect(image.size.width).to(equal(4000.0))
                    expect(image.size.height).to(equal(1000.0))
                    expect(oriented.size.width).to(equal(1200.0))
                    expect(oriented.size.height).to(equal(300.0))
                }
            }

            context("scaling when height is greater than max") {
                beforeEach {
                    image = specImage(named: "specs-1000x4000")!
                    image.copyWithCorrectOrientationAndSize { image in
                        oriented = image
                    }
                }

                it("scales to the maxWidth") {
                    expect(image.size.width).to(equal(1000.0))
                    expect(image.size.height).to(equal(4000.0))
                    expect(oriented.size.width).to(equal(900.0))
                    expect(oriented.size.height).to(equal(3600.0))
                }
            }
        }
    }
}
