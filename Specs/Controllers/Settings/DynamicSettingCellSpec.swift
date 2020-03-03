////
///  DynamicSettingCellSpec.swift
//

@testable import Ello
import Quick
import Nimble

class DynamicSettingCellSpec: QuickSpec {

    class FakeDelegate: UIView, DynamicSettingCellResponder {
        var didCall = false
        var setting: DynamicSetting?
        var value: Bool?

        func toggleSetting(_ setting: DynamicSetting, value: Bool) {
            didCall = true
            self.setting = setting
            self.value = value
        }

        func deleteAccount() {
            didCall = true
        }
    }

    override func spec() {
        describe("DynamicSettingCell") {
            var subject: DynamicSettingCell!
            var button: UIControl!

            beforeEach {
                subject = DynamicSettingCell()
                button = subject.findSubview()
            }

            describe("toggleButtonTapped") {
                it("calls the delegate function") {
                    let fake = FakeDelegate()
                    let setting = DynamicSetting(label: "", key: "")
                    fake.addSubview(subject)
                    showView(fake)
                    subject.setting = setting
                    button.sendActions(for: .touchUpInside)
                    expect(fake.didCall).to(beTrue())
                }

                it("hands the setting and value to the delegate function") {
                    let fake = FakeDelegate()
                    let setting = DynamicSetting(label: "test", key: "")
                    fake.addSubview(subject)
                    showView(fake)
                    subject.setting = setting
                    button.sendActions(for: .touchUpInside)
                    expect(fake.setting?.label) == setting.label
                    expect(fake.value) == true
                }
            }

            describe("deleteButtonTapped") {
                it("calls the delegate function") {
                    let fake = FakeDelegate()
                    fake.addSubview(subject)
                    subject.setting = DynamicSetting.accountDeletionSetting
                    showView(fake)
                    button.sendActions(for: .touchUpInside)
                    expect(fake.didCall).to(beTrue())
                }
            }
        }
    }
}
