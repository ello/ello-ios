////
///  ElloTabBarSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots


class ElloTabBarSpec: QuickSpec {
    override func spec() {
        describe("ElloTabBar") {
            var subject: ElloTabBar!
            var redDot: UIView!
            let portraitSize = CGSize(width: 320, height: 49)
            let landscapeSize = CGSize(width: 1024, height: 49)

            beforeEach {
                let items = [
                    UITabBarItem.item(.sparkles),
                    UITabBarItem.item(.bolt),
                    UITabBarItem.item(.circBig),
                    UITabBarItem.item(.person),
                    UITabBarItem.item(.omni),
                ]
                subject = ElloTabBar()
                subject.items = items
                redDot = subject.addRedDotAtIndex(1)
                redDot.isHidden = false
            }

            context("red dot position") {
                context("portait") {
                    beforeEach {
                        prepareForSnapshot(subject, size: portraitSize)
                    }
                    it("should be in the correct location") {
                        expect(subject).to(haveValidSnapshot())
                    }
                }
                context("landscape") {
                    beforeEach {
                        prepareForSnapshot(subject, size: landscapeSize)
                    }
                    it("should be in the correct location") {
                        expect(subject).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
