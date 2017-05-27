////
///  AppDelegateSpec.swift
//

@testable import Ello
import Quick
import Nimble
import PINRemoteImage
import PINCache

class AppDelegateSpec: QuickSpec {
    override func spec() {
        describe("AppDelegate") {
            beforeEach {
                let subject = UIApplication.shared.delegate as? AppDelegate
                subject?.setupCaches()
            }

            describe("caches") {

                describe("PINDiskCache") {

                    it("limits the size to 250 MB") {
                        expect(PINRemoteImageManager.shared().pinCache?.diskCache.byteLimit) == 250000000
                    }

                    it("has an object age of 2 weeks") {
                        expect(PINRemoteImageManager.shared().pinCache?.diskCache.ageLimit) == 1209600
                    }
                }
            }
        }
    }
}
