@testable import Ello
import Quick
import Nimble


class JWTSpec: QuickSpec {
    override func spec() {
        describe("JWT") {
            describe("refresh()") {
                context("staff") {
                    var token: AuthToken!

                    beforeEach {
                        let data = stubbedData("jwt-auth-is-staff")
                        AuthToken.reset()
                        token = AuthToken()
                        AuthToken.storeToken(data, isPasswordBased: true)
                    }

                    it("is staff") {
                        JWT.refresh()
                        expect(token.isStaff) == true
                    }
                }

                context("nabaroo") {
                    var token: AuthToken!

                    beforeEach {
                        let data = stubbedData("jwt-auth-is-nabaroo")
                        AuthToken.reset()
                        token = AuthToken()
                        AuthToken.storeToken(data, isPasswordBased: true)
                    }

                    it("is nabaroo") {
                        JWT.refresh()
                        expect(token.isNabaroo) == true
                    }
                }

                context("NON staff") {
                    var token: AuthToken!

                    beforeEach {
                        let data = stubbedData("jwt-auth-no-staff")
                        AuthToken.reset()
                        token = AuthToken()
                        AuthToken.storeToken(data, isPasswordBased: true)
                    }

                    it("is NOT staff") {
                        JWT.refresh()
                        expect(token.isStaff) == false
                    }
                }
            }
        }
    }
}
