////
///  AuthenticationManagerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AuthenticationManagerSpec: QuickSpec {
    override func spec() {
        let manager = AuthenticationManager.shared

        describe("AuthenticationManager") {
            describe("canMakeRequest(ElloAPI)") {
                let noTokenReqd: [ElloAPI] = [.auth(email: "", password: ""), .reAuth(token: ""), .anonymousCredentials]
                let anonymous: [ElloAPI] = [.availability(content: [:]), .join(email: "", username: "", password: "", invitationCode: nil), .categories]
                let authdOnly: [ElloAPI] = [.amazonCredentials, .currentUserProfile, .pushSubscriptions(token: Data())]
                let expectations: [(AuthState, supported: [ElloAPI], unsupported: [ElloAPI])] = [
                    (.noToken, supported: noTokenReqd, unsupported: authdOnly),
                    (.anonymous, supported: noTokenReqd + anonymous, unsupported: authdOnly),
                    (.authenticated, supported: authdOnly, unsupported: []),
                    (.initial, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.userCredsSent, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.shouldTryUserCreds, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.refreshTokenSent, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.shouldTryRefreshToken, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.anonymousCredsSent, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                    (.shouldTryAnonymousCreds, supported: noTokenReqd, unsupported: anonymous + authdOnly),
                ]

                for (state, supported, unsupported) in expectations {
                    for supportedEndpoint in supported {
                        it("\(state) should support \(supportedEndpoint)") {
                            let manager = AuthenticationManager.shared
                            manager.specs(setAuthState: state)
                            expect(manager.canMakeRequest(supportedEndpoint)) == true
                        }
                    }
                    for unsupportedEndpoint in unsupported {
                        it("\(state) should not support \(unsupportedEndpoint)") {
                            let manager = AuthenticationManager.shared
                            manager.specs(setAuthState: state)
                            expect(manager.canMakeRequest(unsupportedEndpoint)) == false
                        }
                    }
                }
            }
        }
    }
}
