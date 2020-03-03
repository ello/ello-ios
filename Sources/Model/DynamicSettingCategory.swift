////
///  DynamicSettingCategory.swift
//

import SwiftyJSON


enum DynamicSettingsSection: Int {
    case creatorType
    case dynamicSettings
    case blocked
    case muted
    case accountDeletion

    static var count: Int {
        return 5
    }
}


@objc(DynamicSettingCategory)
final class DynamicSettingCategory: Model {
    static let Version = 2

    let label: String
    var settings: [DynamicSetting]
    let section: DynamicSettingsSection

    init(
        label: String,
        settings: [DynamicSetting],
        section: DynamicSettingsSection = .dynamicSettings
    ) {
        self.label = label
        self.settings = settings
        self.section = section
        super.init(version: DynamicSettingCategory.Version)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.label = decoder.decodeKey("label")
        self.settings = decoder.decodeKey("settings")
        let version: Int = decoder.decodeKey("version")
        if version > 1 {
            self.section = DynamicSettingsSection(rawValue: decoder.decodeKey("section"))
                ?? .dynamicSettings
        }
        else {
            self.section = .dynamicSettings
        }
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(label, forKey: "label")
        coder.encodeObject(settings, forKey: "settings")
        coder.encodeObject(section.rawValue, forKey: "section")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> DynamicSettingCategory {
        let json = JSON(data)
        let label = json["label"].stringValue
        let settings: [DynamicSetting] = json["items"].arrayValue.map {
            DynamicSetting.fromJSON($0.object as! [String: Any])
        }

        return DynamicSettingCategory(label: label, settings: settings)
    }
}

extension DynamicSettingCategory {
    static let creatorTypeCategory: DynamicSettingCategory = {
        let label = InterfaceString.Settings.CreatorType
        return DynamicSettingCategory(
            label: label,
            settings: [DynamicSetting.creatorTypeSetting],
            section: .creatorType
        )
    }()
    static let blockedCategory: DynamicSettingCategory = {
        let label = InterfaceString.Settings.BlockedTitle
        return DynamicSettingCategory(
            label: label,
            settings: [DynamicSetting.blockedSetting],
            section: .blocked
        )
    }()
    static let mutedCategory: DynamicSettingCategory = {
        let label = InterfaceString.Settings.MutedTitle
        return DynamicSettingCategory(
            label: label,
            settings: [DynamicSetting.mutedSetting],
            section: .muted
        )
    }()
    static let accountDeletionCategory: DynamicSettingCategory = {
        let label = InterfaceString.Settings.DeleteAccountTitle
        return DynamicSettingCategory(
            label: label,
            settings: [DynamicSetting.accountDeletionSetting],
            section: .accountDeletion
        )
    }()
}
