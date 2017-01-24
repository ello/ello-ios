////
///  MultipartRequestBuilderSpec.swift
//

@testable import Ello
import Quick
import Nimble


class MultipartRequestBuilderSpec: QuickSpec {
    override func spec() {
        let url = URL(string: "http://ello.co")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        var content = ""
        var builder : MultipartRequestBuilder!

        describe("building a multipart request") {
            beforeEach {
                builder = MultipartRequestBuilder(url: url, capacity: 100)
                builder.addParam("foo", value: "bar")
                builder.addParam("baz", value: "a\nb\nc")

                request = builder.buildRequest()
                content = String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? ""
            }
            it("can build a multipart request") {
                let boundaryConstant = builder.boundaryConstant
                var expected = ""
                expected += "--\(boundaryConstant)\r\n"
                expected += "Content-Disposition: form-data; name=\"foo\"\r\n"
                expected += "\r\n"
                expected += "bar\r\n"
                expected += "--\(boundaryConstant)\r\n"
                expected += "Content-Disposition: form-data; name=\"baz\"\r\n"
                expected += "\r\n"
                expected += "a\nb\nc\r\n"
                expected += "--\(boundaryConstant)--\r\n"

                expect(content).to(equal(expected))
            }
        }
    }
}
