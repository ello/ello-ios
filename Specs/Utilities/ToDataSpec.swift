////
///  ToDataSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ToDataSpec: QuickSpec {
    override func spec() {
        let emptyData = Data()
        let someData = Data(base64Encoded: "dGVzdA==")!
        let string = "test"
        let image = UIImage.imageWithColor(.black)!

        describe("NSData") {
            it("should return self (empty data)") {
                expect(emptyData.toData()).to(equal(emptyData))
            }

            it("should return self (base64 data)") {
                expect(someData.toData()).to(equal(someData))
            }
        }

        describe("String") {
            it("should return NSData") {
                if let data = string.toData() {
                    expect(data).notTo(beNil())
                    let expectedData = string.data(using: String.Encoding.utf8)
                    expect(data).to(equal(expectedData))
                }
                else {
                    fail("could not convert string \"\(string)\" to NSData")
                }
            }
        }

        describe("UIImage") {
            it("should return NSData") {
                if let data = image.toData() {
                    expect(data).notTo(beNil())
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
