////
///  AuthTokenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AuthTokenSpec: QuickSpec {
    override func spec() {
        describe("AuthToken") {

            it("returns correct data") {
                let keychain = FakeKeychain()
                keychain.authToken = "1234-fake-token"
                keychain.authTokenType = "fake-refresh-token"
                keychain.refreshAuthToken = "FakeType"
                keychain.isPasswordBased = true
                keychain.isStaff = true
                var token = AuthToken()
                token.keychain = keychain

                expect(token.token).to(equal(keychain.authToken))
                expect(token.type).to(equal(keychain.authTokenType))
                expect(token.refreshToken).to(equal(keychain.refreshAuthToken))
                expect(token.isPasswordBased).to(equal(keychain.isPasswordBased))
                expect(token.isStaff).to(equal(keychain.isStaff))
            }

            it("correctly calculates presence of tokens") {
                let keychain = FakeKeychain()
                keychain.authToken = "1234-fake-token"
                keychain.authTokenType = "fake-refresh-token"
                keychain.refreshAuthToken = "FakeType"
                keychain.isPasswordBased = true
                keychain.isStaff = false
                var token = AuthToken()
                token.keychain = keychain

                expect(token.isPresent) == true
            }

            it("correctly calculates absence of tokens (token: nil)") {
                let keychain = FakeKeychain()
                keychain.authToken = nil
                keychain.authTokenType = "fake-refresh-token"
                keychain.refreshAuthToken = "FakeType"
                keychain.isPasswordBased = true
                keychain.isStaff = false
                var token = AuthToken()
                token.keychain = keychain

                expect(token.isPresent) == false
            }

            it("correctly calculates absence of tokens (token: \"\")") {
                let keychain = FakeKeychain()
                keychain.authToken = ""
                keychain.authTokenType = "fake-refresh-token"
                keychain.refreshAuthToken = "FakeType"
                keychain.isPasswordBased = true
                keychain.isStaff = false
                var token = AuthToken()
                token.keychain = keychain

                expect(token.isPresent) == false
            }

            context("storeToken(_:isPasswordBased:email:password:)") {
                let data = ElloAPI.anonymousCredentials.sampleData
                var token: AuthToken!

                beforeEach {
                    AuthToken.reset()
                    token = AuthToken()
                }

                it("is reset") {
                    expect(token.token).to(beNil())
                    expect(token.type).to(beNil())
                    expect(token.refreshToken).to(beNil())
                    expect(token.isPresent) == false
                    expect(token.isPasswordBased) == false
                    expect(token.isStaff) == false
                    expect(token.isAnonymous) == false
                    expect(token.username).to(beNil())
                    expect(token.password).to(beNil())
                }

                it("will store a password based token without user creds") {
                    AuthToken.storeToken(data, isPasswordBased: true)

                    expect(token.token).notTo(beNil())
                    expect(token.type).notTo(beNil())
                    expect(token.refreshToken).notTo(beNil())
                    expect(token.isPresent) == true
                    expect(token.isPasswordBased) == true
                    expect(token.isAnonymous) == false
                    expect(token.isStaff) == false
                    expect(token.username).to(beNil())
                    expect(token.password).to(beNil())
                }

                it("will store a password based token with user creds") {
                    AuthToken.storeToken(data, isPasswordBased: true, email: "email", password: "password")

                    expect(token.token).notTo(beNil())
                    expect(token.type).notTo(beNil())
                    expect(token.refreshToken).notTo(beNil())
                    expect(token.isPresent) == true
                    expect(token.isPasswordBased) == true
                    expect(token.isAnonymous) == false
                    expect(token.isStaff) == false
                    expect(token.username) == "email"
                    expect(token.password) == "password"
                }

                it("will store an anonymous token") {
                    AuthToken.storeToken(data, isPasswordBased: false)

                    expect(token.token).notTo(beNil())
                    expect(token.type).notTo(beNil())
                    expect(token.refreshToken).notTo(beNil())
                    expect(token.isPresent) == true
                    expect(token.isPasswordBased) == false
                    expect(token.isAnonymous) == true
                    expect(token.isStaff) == false
                    expect(token.username).to(beNil())
                    expect(token.password).to(beNil())
                }
            }


            context("staff credentials") {
                let data = stubbedData("jwt-auth-is-staff")
                var token: AuthToken!

                beforeEach {
                    AuthToken.reset()
                    token = AuthToken()
                }

                it("is staff") {
                    AuthToken.storeToken(data, isPasswordBased: true)

                    expect(token.token).notTo(beNil())
                    expect(token.type).notTo(beNil())
                    expect(token.refreshToken).notTo(beNil())
                    expect(token.isPresent) == true
                    expect(token.isPasswordBased) == true
                    expect(token.isAnonymous) == false
                    expect(token.isStaff) == true
                    expect(token.username).to(beNil())
                    expect(token.password).to(beNil())
                }
            }

            context("NON staff credentials") {
                let data = stubbedData("jwt-auth-no-staff")
                var token: AuthToken!

                beforeEach {
                    AuthToken.reset()
                    token = AuthToken()
                }

                it("is staff") {
                    AuthToken.storeToken(data, isPasswordBased: true)

                    expect(token.token).notTo(beNil())
                    expect(token.type).notTo(beNil())
                    expect(token.refreshToken).notTo(beNil())
                    expect(token.isPresent) == true
                    expect(token.isPasswordBased) == true
                    expect(token.isAnonymous) == false
                    expect(token.isStaff) == false
                    expect(token.username).to(beNil())
                    expect(token.password).to(beNil())
                }
            }

        }
    }
}
