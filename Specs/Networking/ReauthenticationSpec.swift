////
///  ReauthenticationSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ReauthenticationSpec: QuickSpec {
    override func spec() {
        describe("Reauthentication") {

            it("should reauth with refresh token after 401") {
                ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                    RecordedResponse(endpoint: .following, response: .networkResponse(401, Data())),
                ])
                var succeeded = false
                var failed = false
                ElloProvider.shared.request(.following)
                    .then { _ in
                        succeeded = true
                    }
                    .catch { _ in
                        failed = true
                    }
                expect(AuthToken().token) == "0237a2b08dfe6c30bd3c1525767efadffac942bbb6c045c924ff2eba1350c4aa"
                expect(AuthToken().isPasswordBased) == true
                expect(succeeded) == true
                expect(failed) == false
            }

            it("should reauth with user/pass after 401") {
                ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                    RecordedResponse(endpoint: .following, response: .networkResponse(401, Data())),
                    RecordedResponse(endpoint: .reAuth(token: ""), response: .networkResponse(401, Data())),
                ])
                var succeeded = false
                var failed = false
                ElloProvider.shared.request(.following)
                    .then { _ in
                        succeeded = true
                    }
                    .catch { _ in
                        failed = true
                    }
                expect(AuthToken().token) == "0237a2b08dfe6c30bd3c1525767efadffac942bbb6c045c924ff2eba1350c4aa"
                expect(AuthToken().isPasswordBased) == true
                expect(succeeded) == true
                expect(failed) == false
            }

            it("should reauth with token after NetworkFailure") {
                let networkError = NSError.networkError("Failed to send request", code: ElloErrorCode.networkFailure)
                ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                    RecordedResponse(endpoint: .following, response: .networkResponse(401, Data())),
                    RecordedResponse(endpoint: .reAuth(token: ""), response: .networkError(networkError)),
                    RecordedResponse(endpoint: .reAuth(token: ""), response: .networkError(networkError)),
                ])
                var succeeded = false
                var failed = false
                ElloProvider.shared.request(.following)
                    .then { _ in
                        succeeded = true
                    }
                    .catch { _ in
                        failed = true
                    }
                expect(AuthToken().token) == "0237a2b08dfe6c30bd3c1525767efadffac942bbb6c045c924ff2eba1350c4aa"
                expect(AuthToken().isPasswordBased) == true
                expect(succeeded) == true
                expect(failed) == false
            }

            it("should logout after failed reauth 401") {
                ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                    RecordedResponse(endpoint: .following, response: .networkResponse(401, Data())),
                    RecordedResponse(endpoint: .reAuth(token: ""), response: .networkResponse(401, Data())),
                    RecordedResponse(endpoint: .auth(email: "", password: ""), response: .networkResponse(404, Data())),
                ])
                var succeeded = false
                var failed = false
                ElloProvider.shared.request(.following)
                    .then { _ in
                        succeeded = true
                    }
                    .catch { _ in
                        failed = true
                    }
                expect(AuthToken().token).to(beNil())
                expect(AuthToken().isPasswordBased) == false
                expect(succeeded) == false
                expect(failed) == true
            }

        }
    }
}
