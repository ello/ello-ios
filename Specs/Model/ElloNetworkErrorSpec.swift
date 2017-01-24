////
///  elloNetworkError.swift
//

@testable import Ello
import Quick
import Nimble


class ElloNetworkErrorSpec: QuickSpec {
    override func spec() {
        it("converts from JSON") {
            let errors = stubbedJSONData("422", "errors")
            let elloNetworkError = ElloNetworkError.fromJSON(errors) as! ElloNetworkError

            expect(elloNetworkError.code) == ElloNetworkError.CodeType.invalidResource
            expect(elloNetworkError.title) == "The current resource was invalid."
            expect(elloNetworkError.status) == "422"
            expect(elloNetworkError.detail).to(beNil())
            expect(elloNetworkError.messages) == ["Name can't be blank"]
            expect(elloNetworkError.attrs!["name"]!) == ["can't be blank"]
        }

        it("converts from JSON, sparse data") {
            let errors = stubbedJSONData("422_sparse", "errors")
            let elloNetworkError = ElloNetworkError.fromJSON(errors) as! ElloNetworkError

            expect(elloNetworkError.code) == ElloNetworkError.CodeType.unknown
            expect(elloNetworkError.title) == "The current resource was invalid."
            expect(elloNetworkError.status).to(beNil())
            expect(elloNetworkError.detail).to(beNil())
            expect(elloNetworkError.messages).to(beNil())
            expect(elloNetworkError.attrs).to(beNil())
        }

        it("defaults code to unknown if json code string isn't supported") {
            let errors = stubbedJSONData("0", "errors")
            let elloNetworkError = ElloNetworkError.fromJSON(errors) as! ElloNetworkError

            expect(elloNetworkError.code) == ElloNetworkError.CodeType.unknown
            expect(elloNetworkError.title) == "Something went wrong"
            expect(elloNetworkError.status) == "0"
            expect(elloNetworkError.detail).to(beNil())
        }
    }
}
