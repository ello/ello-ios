////
///  ElloKeychainSpec.swift
//

@testable import Ello
import Quick
import Nimble
import KeychainAccess


class ElloKeychainSpec: QuickSpec {
    override func spec() {
        var elloKeychain: ElloKeychain!

        beforeEach {
            let keychain = Keychain(service: "co.ello.ElloDev.Specs")
            elloKeychain = ElloKeychain()
            elloKeychain.keychain = keychain
        }

        describe("ElloKeychain") {
            it("should get and set pushToken") {
                let data = "pushToken".data(using: String.Encoding.utf8, allowLossyConversion: false)
                elloKeychain.pushToken = data
                expect(elloKeychain.pushToken) == data
            }
            it("should reset pushToken") {
                elloKeychain.pushToken = nil
                expect(elloKeychain.pushToken).to(beNil())
            }
            it("should get and set authToken") {
                elloKeychain.authToken = "authToken"
                expect(elloKeychain.authToken) == "authToken"
            }
            it("should reset authToken") {
                elloKeychain.authToken = nil
                expect(elloKeychain.authToken).to(beNil())
            }
            it("should get and set refreshAuthToken") {
                elloKeychain.refreshAuthToken = "refreshAuthToken"
                expect(elloKeychain.refreshAuthToken) == "refreshAuthToken"
            }
            it("should reset refreshAuthToken") {
                elloKeychain.refreshAuthToken = nil
                expect(elloKeychain.refreshAuthToken).to(beNil())
            }
            it("should get and set authTokenType") {
                elloKeychain.authTokenType = "authTokenType"
                expect(elloKeychain.authTokenType) == "authTokenType"
            }
            it("should reset authTokenType") {
                elloKeychain.authTokenType = nil
                expect(elloKeychain.authTokenType).to(beNil())
            }
            it("should get and set username") {
                elloKeychain.username = "username"
                expect(elloKeychain.username) == "username"
            }
            it("should reset username") {
                elloKeychain.username = nil
                expect(elloKeychain.username).to(beNil())
            }
            it("should get and set password") {
                elloKeychain.password = "password"
                expect(elloKeychain.password) == "password"
            }
            it("should reset password") {
                elloKeychain.password = nil
                expect(elloKeychain.password).to(beNil())
            }
            it("should get and set isPasswordBased") {
                elloKeychain.isPasswordBased = true
                expect(elloKeychain.isPasswordBased) == true
            }
            it("should reset isPasswordBased") {
                elloKeychain.isPasswordBased = nil
                expect(elloKeychain.isPasswordBased).to(beNil())
            }
        }
    }
}
