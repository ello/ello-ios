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
        cell.titleLabel.text = setting.label
        cell.descriptionLabel.text = setting.info

        if setting.key == DynamicSetting.accountDeletionSetting.key {
            cell.toggleButton.isHidden = true
            cell.deleteButton.isHidden = false
            cell.deleteButton.text = InterfaceString.Delete
            cell.contentView.isHidden = false
        } else {
            cell.toggleButton.isHidden = false
            cell.deleteButton.isHidden = true
            cell.toggleButton.value = currentUser.propertyForSettingsKey(key: setting.key)

            let visible = isVisible(setting: setting, currentUser: currentUser)
            cell.contentView.isHidden = !visible
        }
    }
}
