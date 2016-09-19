////
///  ToNSDataSpec.swift
//

import Ello
import Quick
import Nimble


class ToNSDataSpec: QuickSpec {
    override func spec() {
        let emptyData = NSData()
        let someData = NSData(base64EncodedString: "dGVzdA==", options: NSDataBase64DecodingOptions())!
        let string = "test"
        let image = UIImage.imageWithColor(.blackColor())!

        describe("NSData") {
            it("should return self (empty data)") {
                expect(emptyData.toNSData()).to(equal(emptyData))
            }

            it("should return self (base64 data)") {
                expect(someData.toNSData()).to(equal(someData))
            }
        }

        describe("String") {
            it("should return NSData") {
                if let data = string.toNSData() {
                    expect(data).to(beAKindOf(NSData))
                    let expectedData = string.dataUsingEncoding(NSUTF8StringEncoding)
                    expect(data).to(equal(expectedData))
                }
                else {
                    fail("could not convert string \"\(string)\" to NSData")
                }
            }
        }

        describe("UIImage") {
            it("should return NSData") {
                if let data = image.toNSData() {
                    expect(data).to(beAKindOf(NSData))
                    let expectedData = UIImagePNGRepresentation(image)
                    expect(data).to(equal(expectedData))
                }
                else {
                    fail("could not convert image to NSData")
                }
            }
        }
    }
}
