////
///  AmazonCredentialsSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class AmazonCredentialsSpec: QuickSpec {
    override func spec() {
        describe("requesting credentials") {
            describe("requesting an AmazonCredentials object") {
                var credentials : AmazonCredentials?
                beforeEach() {
                    credentials = nil
                    ElloProvider.shared.request(.amazonCredentials)
                        .then { response in
                            credentials = response.0 as? AmazonCredentials
                        }
                }

                it("should not be nil") {
                    expect(credentials).toNot(beNil())
                }
                it("should set the prefix") {
                    expect(credentials!.prefix).to(equal("uploads/prefix"))
                }
                it("should set the policy") {
                    expect(credentials!.policy).to(equal("prolicy-hash"))
                }
                it("should set the signature") {
                    expect(credentials!.signature).to(equal("signature-hash"))
                }
                it("should set the endpoint") {
                    expect(credentials!.endpoint).to(equal("https://endpoint.amazonaws.com"))
                }
                it("should set the access_key") {
                    expect(credentials!.accessKey).to(equal("access-key"))
                }
            }
        }
    }
}
