////
///  DynamicSettingCellPresenter.swift
//

struct DynamicSettingCellPresenter {
    static func isVisible(setting: DynamicSetting, currentUser: User) -> Bool {
        if setting.key == DynamicSetting.accountDeletionSetting.key {
            return true
        }
        else {
            for dependentKey in setting.dependentOn {
                if currentUser.propertyForSettingsKey(key: dependentKey) == false {
                    return false
                }
            }
            for conflictKey in setting.conflictsWith {
                if currentUser.propertyForSettingsKey(key: conflictKey) == true {
                    return false
                }
            }

            return true
        }
    }

    static func configure(_ cell: DynamicSettingCell, setting: DynamicSetting, currentUser: User) {
        cell.setting = setting
        cell.title = setting.label
        cell.info = setting.info
        cell.isEnabled = isVisible(setting: setting, currentUser: currentUser)
    }
}
