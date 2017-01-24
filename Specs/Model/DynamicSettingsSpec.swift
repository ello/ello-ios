////
///  DynamicSettingsSpec.swift
//

@testable import Ello
import Quick
import Nimble

class DynamicSettingsSpec: QuickSpec {
    override func spec() {
        it("converts from JSON") {
            let parsedDynamicSettings = stubbedJSONDataArray("profile_available_user_profile_toggles", "categories")
            let dynamicSettings = parsedDynamicSettings.map { DynamicSettingCategory.fromJSON($0) as DynamicSettingCategory }

            expect(dynamicSettings.count) == 4
            expect(dynamicSettings.first?.label) == "Preferences"
            expect(dynamicSettings.first?.settings.count) == 8

            expect(dynamicSettings.first?.settings.first?.label) == "Public Profile"
            expect(dynamicSettings.first?.settings.first?.key) == "is_public"
            expect(dynamicSettings.first?.settings.first?.setsAnother.count) == 1
            expect(dynamicSettings.first?.settings.first?.setsAnother.first?.key) == "has_reposting_enabled"
            expect(dynamicSettings.first?.settings.first?.setsAnother.first?.value) == false
            expect(dynamicSettings.first?.settings.first?.setsAnother.first?.when) == false

            expect(dynamicSettings.first?.settings[3].label) == "Sharing"
            expect(dynamicSettings.first?.settings[3].dependentOn) == ["is_public"]
        }
    }
}
