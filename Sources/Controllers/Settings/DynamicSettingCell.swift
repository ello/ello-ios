////
///  DynamicSettingCell.swift
//

class DynamicSettingCell: TableViewCell {
    struct Size {
        static let margins: CGFloat = 10
    }

    static let reuseIdentifier = "DynamicSettingCell"

    var setting: DynamicSetting?
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var info: String? {
        get { return infoLabel.text}
        set { infoLabel.text = newValue }
    }
    var value: Bool {
        get { return toggleButton.isSelected }
        set { toggleButton.isSelected = newValue }
    }
    var toggleTitle: String? {
        get { return toggleButton.title }
        set {
            toggleButton.setTitle(newValue, for: .selected)
            toggleButton.setTitle(newValue, for: .normal)
        }
    }
    var isEnabled: Bool {
        get { return toggleButton.isEnabled }
        set { toggleButton.isEnabled = newValue }
    }

    private let titleLabel = StyledLabel(style: .default)
    private let infoLabel = StyledLabel(style: .smallGray)
    private let toggleButton = SettingsToggleButton()
    private let line = Line(color: .greyF2)

    override func styleCell() {
        infoLabel.isMultiline = true
    }

    override func bindActions() {
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
    }

    override func arrange() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(toggleButton)
        contentView.addSubview(line)

        let marginGuideTop = UILayoutGuide()
        let marginGuideBottom = UILayoutGuide()
        contentView.addLayoutGuide(marginGuideTop)
        contentView.addLayoutGuide(marginGuideBottom)

        marginGuideTop.snp.makeConstraints { make in
            make.height.equalTo(Size.margins)
            make.top.equalTo(contentView)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(Size.margins)
            make.top.equalTo(marginGuideTop.snp.bottom)
        }

        infoLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(Size.margins)
            make.trailing.lessThanOrEqualTo(toggleButton.snp.leading).offset(-Size.margins)
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.margins)
        }

        marginGuideBottom.snp.makeConstraints { make in
            make.height.equalTo(Size.margins)
            make.top.equalTo(infoLabel.snp.bottom)
            make.bottom.equalTo(contentView)
        }

        toggleButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-Size.margins)
            make.centerY.equalTo(contentView)
        }

        line.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(contentView)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setting = nil
        titleLabel.text = nil
        infoLabel.text = nil
        toggleButton.isEnabled = true
        toggleButton.setTitle(InterfaceString.Yes, for: .selected)
        toggleButton.setTitle(InterfaceString.No, for: .normal)
    }

    @objc
    private func toggleTapped() {
        guard
            let setting = setting,
            let responder: DynamicSettingCellResponder = findResponder()
        else { return }

        if setting == DynamicSetting.accountDeletionSetting {
            responder.deleteAccount()
        }
        else {
            responder.toggleSetting(setting, value: !toggleButton.isSelected)
            toggleButton.isSelected = !toggleButton.isSelected
        }
    }
}
