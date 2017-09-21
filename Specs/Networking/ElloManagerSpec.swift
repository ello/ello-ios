////
///  ElloManagerSpec.swift
//

@testable import Ello
import Quick
import Moya
import Nimble
import Alamofire
@testable import ElloCerts

class ElloManagerSpec: QuickSpec {
    override func spec() {

        describe("ElloManager") {
            afterEach {
                Globals.isSimulator = true
            }

            describe("serverTrustPolicies") {

                if ElloCerts.isPublic {
                    it("has zero when running as open source app") {
                        Globals.isSimulator = false
                        expect(ElloManager.serverTrustPolicies["ello.co"]).to(beNil())
                    }
                }
                else {
                    it("has one when not in the simulator") {
                        Globals.isSimulator = false
                        expect(ElloManager.serverTrustPolicies["ello.co"]).notTo(beNil())
                    }
                }

                it("has zero when in the simulator") {
                    Globals.isSimulator = true
                    expect(ElloManager.serverTrustPolicies["ello.co"]).to(beNil())
                }
            }

            describe("SSL Pinning") {

                it("has a custom Alamofire.Manager") {
                    let defaultManager = SessionManager.default
                    let elloManager = ElloManager.manager

                    expect(elloManager).notTo(beIdenticalTo(defaultManager))
                }

                if !ElloCerts.isPublic {
                    it("includes 2 ssl certificates in the app") {
                        Globals.isSimulator = false
                        let policy = ElloManager.serverTrustPolicies["ello.co"]!
                        var doesValidateChain = false
                        var doesValidateHost = false
                        let keys: [SecKey]
                        switch policy {
                        case let .pinPublicKeys(publicKeys, validateCertificateChain, validateHost):
                            doesValidateChain = validateCertificateChain
                            doesValidateHost = validateHost
                            keys = publicKeys
                        default:
                            keys = []
                        }

                        expect(doesValidateChain) == true
                        expect(doesValidateHost) == true
                        let minNumberOfCerts = 2
                        // make sure there's a cert, and at least one backup
                        expect(keys.count) >= minNumberOfCerts
                    }
                }
            }
        }
    }
}
