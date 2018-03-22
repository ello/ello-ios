////
///  DynamicSettingSpec.swift
//

@testable import Ello
import Quick
import Nimble

class DynamicSettingSpec: QuickSpec {
    override func spec() {
        describe("DynamicSetting") {
            describe("static values are comparable") {
                let generators: [(String, () -> DynamicSetting)] = [
                    ("creatorTypeSetting", { return DynamicSetting.creatorTypeSetting }),
                    ("blockedSetting", { return DynamicSetting.blockedSetting }),
                    ("mutedSetting", { return DynamicSetting.mutedSetting }),
                    ("accountDeletionSetting", { return DynamicSetting.accountDeletionSetting }),
                ]
                for (title, generator) in generators {
                    it("should compare \(title)") {
                        let a = generator()
                        let b = generator()
                        expect(a) == b
                    }
                }
            }
        }
    }
}
