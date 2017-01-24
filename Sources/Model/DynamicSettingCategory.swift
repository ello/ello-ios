////
///  DynamicSettingCategory.swift
//

import SwiftyJSON


let DynamicSettingCategoryVersion = 1

@objc(DynamicSettingCategory)
final class DynamicSettingCategory: JSONAble {
    let label: String
    var settings: [DynamicSetting]

    init(label: String, settings: [DynamicSetting]) {
        self.label = label
        self.settings = settings
        super.init(version: DynamicSettingCategoryVersion)
    }

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.label = decoder.decodeKey("label")
        self.settings = decoder.decodeKey("settings")
        super.init(coder: decoder.coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(label, forKey: "label")
        coder.encodeObject(settings, forKey: "settings")
        super.encode(with: coder.coder)
    }
}

extension DynamicSettingCategory {
    override class func fromJSON(_ data: [String: AnyObject]) -> DynamicSettingCategory {
        let json = JSON(data)
        let label = json["label"].stringValue
        let settings: [DynamicSetting] = json["items"].arrayValue.map { DynamicSetting.fromJSON($0.object as! [String: AnyObject]) }

        return DynamicSettingCategory(label: label, settings: settings)
    }
}

extension DynamicSettingCategory {
    static var blockedCategory: DynamicSettingCategory {
        let label = InterfaceString.Settings.BlockedTitle
        return DynamicSettingCategory(label: label, settings: [DynamicSetting.blockedSetting])
    }
    static var mutedCategory: DynamicSettingCategory {
        let label = InterfaceString.Settings.MutedTitle
        return DynamicSettingCategory(label: label, settings: [DynamicSetting.mutedSetting])
    }
    static var accountDeletionCategory: DynamicSettingCategory {
        let label = InterfaceString.Settings.DeleteAccountTitle
        return DynamicSettingCategory(label: label, settings: [DynamicSetting.accountDeletionSetting])
    }
}
