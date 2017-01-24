////
///  InteractionVisibilitySpec.swift
//

@testable import Ello
import Quick
import Nimble


class InteractionVisibilitySpec: QuickSpec {
    override func spec() {
        describe("InteractionVisibility") {
            let expectations: [(InteractionVisibility, isVisible: Bool, isEnabled: Bool, isSelected: Bool)] = [
                (.enabled,             isVisible: true, isEnabled: true, isSelected: false),
                (.selectedAndEnabled,  isVisible: true, isEnabled: true, isSelected: true),
                (.selectedAndDisabled, isVisible: true, isEnabled: false, isSelected: true),
                (.disabled,            isVisible: true, isEnabled: false, isSelected: false),
                (.hidden,              isVisible: false, isEnabled: false, isSelected: false),
            ]
            for (visibility, expectedVisible, expectedEnabled, expectedSelected) in expectations {
                it("\(visibility) should have isVisible == \(expectedVisible)") {
                    expect(visibility.isVisible) == expectedVisible
                }
                it("\(visibility) should have isEnabled == \(expectedEnabled)") {
                    expect(visibility.isEnabled) == expectedEnabled
                }
                it("\(visibility) should have isSelected == \(expectedSelected)") {
                    expect(visibility.isSelected) == expectedSelected
                }
            }
        }
    }
}
