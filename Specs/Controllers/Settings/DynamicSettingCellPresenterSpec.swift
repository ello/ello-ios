////
///  DynamicSettingCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble

class DynamicSettingCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {
            context("toggle setting") {
                it("configures the cell from the setting") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", info: "info")
                    let profile: Profile = stub(["hasSharingEnabled": false])
                    let user: User = stub([
                        "hasSharingEnabled": false,
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == false
                    expect(cell.toggleButton.isHidden) == false
                    expect(cell.toggleButton.isEnabled) == true
                    expect(cell.deleteButton.isHidden) == true
                }

                it("configures the cell from the setting and uses the profile setting") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", info: "info")
                    let profile: Profile = stub(["hasSharingEnabled": true])
                    let user: User = stub([
                        "hasSharingEnabled": false,
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == true
                    expect(cell.toggleButton.isHidden) == false
                    expect(cell.toggleButton.isEnabled) == true
                    expect(cell.deleteButton.isHidden) == true
                }

                it("configures the cell from the setting and disables if dependent is false") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", info: "info", dependentOn: ["is_public"])
                    let profile: Profile = stub(["hasSharingEnabled": true, "isPublic": false])
                    let user: User = stub([
                        "hasSharingEnabled": false,
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == true
                    expect(cell.toggleButton.isHidden) == false
                    expect(cell.contentView.isHidden) == true
                    expect(isVisible) == false
                    expect(cell.deleteButton.isHidden) == true
                }

                it("configures the cell from the setting and enables if dependent is true") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", info: "info", dependentOn: ["is_public"])
                    let profile: Profile = stub(["hasSharingEnabled": false, "isPublic": true])
                    let user: User = stub([
                        "hasSharingEnabled": false,
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == false
                    expect(cell.toggleButton.isHidden) == false
                    expect(cell.contentView.isHidden) == false
                    expect(isVisible) == true
                    expect(cell.deleteButton.isHidden) == true
                }

                it("configures the cell from the setting and disables if conflicted is true") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", info: "info", conflictsWith: ["allows_analytics"])
                    let profile: Profile = stub(["hasSharingEnabled": true, "allowsAnalytics": true])
                    let user: User = stub([
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == true
                    expect(cell.toggleButton.isHidden) == false
                    expect(cell.contentView.isHidden) == true
                    expect(isVisible) == false
                    expect(cell.deleteButton.isHidden) == true
                }

                it("configures the cell from the setting and enables if conflicted if false") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", info: "info", conflictsWith: ["allows_analytics"])
                    let profile: Profile = stub(["hasSharingEnabled": false, "allowsAnalytics": false])
                    let user: User = stub([
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == false
                    expect(cell.toggleButton.isHidden) == false
                    expect(cell.contentView.isHidden) == false
                    expect(isVisible) == true
                    expect(cell.deleteButton.isHidden) == true
                }

                it("configures the cell from the setting and disables if conflicted") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", info: "info", conflictsWith: ["allows_analytics"])
                    let profile: Profile = stub(["s": true, "allowsAnalytics": false])
                    let user: User = stub([
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == true
                    expect(cell.toggleButton.isHidden) == false
                    expect(cell.contentView.isHidden) == false
                    expect(isVisible) == true
                    expect(cell.deleteButton.isHidden) == true
                }

                it("configures the cell from the setting and enables if not conflicted") {
                    let setting = DynamicSetting(label: "Test", key: "has_sharing_enabled", info: "info", conflictsWith: ["allows_analytics"])
                    let profile: Profile = stub(["hasSharingEnabled": false, "allowsAnalytics": true])
                    let user: User = stub([
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
                    let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.value) == false
                    expect(cell.toggleButton.isHidden) == false
                    expect(cell.contentView.isHidden) == true
                    expect(isVisible) == false
                    expect(cell.deleteButton.isHidden) == true
                }
            }

            context("delete account setting") {
                it("configures the cell from the setting") {
                    let setting = DynamicSetting.accountDeletionSetting
                    let profile: Profile = stub([:])
                    let user: User = stub([
                        "profile": profile
                        ])
                    let cell = DynamicSettingCell.loadFromNib() as DynamicSettingCell
                    DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)

                    expect(cell.titleLabel.text) == setting.label
                    expect(cell.descriptionLabel.text) == setting.info
                    expect(cell.toggleButton.isHidden) == true
                    expect(cell.deleteButton.isHidden) == false
                }
            }
        }
    }
}
