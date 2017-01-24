////
///  DynamicSettingCell.swift
//

protocol DynamicSettingCellDelegate: class {
    func toggleSetting(_ setting: DynamicSetting, value: Bool)
    func deleteAccount()
}

class DynamicSettingCell: UITableViewCell {
    @IBOutlet weak var titleLabel: StyledLabel!
    weak var descriptionLabel: StyledLabel!
    @IBOutlet weak var toggleButton: ElloToggleButton!
    @IBOutlet weak var deleteButton: ElloToggleButton!

    weak var delegate: DynamicSettingCellDelegate?
    var setting: DynamicSetting?

    @IBAction func toggleButtonTapped() {
        if let setting = setting {
            delegate?.toggleSetting(setting, value: !toggleButton.value)
            toggleButton.value = !toggleButton.value
        }
    }

    @IBAction func deleteButtonTapped() {
        delegate?.deleteAccount()
    }
}
