@testable import Ello
import Quick
import Nimble


class JWTSpec: QuickSpec {
    override func spec() {
        describe("JWT") {
            describe("refresh()") {
                context("staff") {
                    let data = stubbedData("jwt-auth-is-staff")
                    var token: AuthToken!

                    beforeEach {
                        AuthToken.reset()
                        token = AuthToken()
                        AuthToken.storeToken(data, isPasswordBased: true)
                    }

                    it("is staff") {
                        JWT.refresh()
                        expect(token.isStaff) == true
                    }
                }

                context("NON staff") {
                    let data = stubbedData("jwt-auth-no-staff")
                    var token: AuthToken!

                    beforeEach {
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
