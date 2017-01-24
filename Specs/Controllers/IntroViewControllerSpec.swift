////
///  IntroViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble

class IntroViewControllerSpec: QuickSpec {

    override func spec() {
        describe("IntroViewController") {
            var subject: IntroViewController!
            describe("snapshots") {
                beforeEach {
                    subject = IntroViewController()
                }
                validateAllSnapshots(named: "IntroViewController") { return subject }
            }
        }
    }
}
