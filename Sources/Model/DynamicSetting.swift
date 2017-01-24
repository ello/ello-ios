////
///  DynamicSetting.swift
//

import SwiftyJSON


let DynamicSettingVersion = 1
let DynamicSetAnotherVersion = 1

@objc(DynamicSetAnother)
final class DynamicSetAnother: JSONAble {
    let when: Bool?
    let key: String
    let value: Bool

    required init(when: Bool?, key: String, value: Bool) {
        self.when = when
        self.key = key
        self.value = value
        super.init(version: DynamicSetAnotherVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.when = decoder.decodeOptionalKey("when")
        self.key = decoder.decodeKey("key")
        self.value = decoder.decodeKey("value")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        if let when = when {
            encoder.encodeObject(when, forKey: "when")
        }
        encoder.encodeObject(key, forKey: "key")
        encoder.encodeObject(value, forKey: "value")
        super.encode(with: coder)
    }

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let when: Bool? = json["when"].bool
        let key: String = json["key"].stringValue
        let value: Bool = json["value"].boolValue
        return DynamicSetAnother(when: when, key: key, value: value)
    }

}

@objc(DynamicSetting)
final class DynamicSetting: JSONAble {
    let label: String
    let key: String
    let info: String?
    let linkLabel: String?
    let linkURL: URL?
    let dependentOn: [String]
    let conflictsWith: [String]
    let setsAnother: [DynamicSetAnother]

    init(label: String, key: String, info: String? = nil, linkLabel: String? = nil, linkURL: URL? = nil, dependentOn: [String] = [], conflictsWith: [String] = [], setsAnother: [DynamicSetAnother] = []) {
        self.label = label
        self.key = key
        self.info = info
        self.linkLabel = linkLabel
        self.linkURL = linkURL
        self.dependentOn = dependentOn
        self.conflictsWith = conflictsWith
        self.setsAnother = setsAnother
        super.init(version: DynamicSettingVersion)
    }

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.label = decoder.decodeKey("label")
        self.key = decoder.decodeKey("key")
        self.info = decoder.decodeOptionalKey("info")
        self.linkLabel = decoder.decodeOptionalKey("linkLabel")
        self.linkURL = decoder.decodeOptionalKey("linkURL")
        self.dependentOn = decoder.decodeKey("dependentOn")
        self.conflictsWith = decoder.decodeKey("conflictsWith")
        self.setsAnother = decoder.decodeKey("setsAnother")
        super.init(coder: decoder.coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(label, forKey: "label")
        coder.encodeObject(key, forKey: "key")
        coder.encodeObject(info, forKey: "info")
        coder.encodeObject(linkLabel, forKey: "linkLabel")
        coder.encodeObject(linkURL, forKey: "linkURL")
        coder.encodeObject(dependentOn, forKey: "dependentOn")
        coder.encodeObject(conflictsWith, forKey: "conflictsWith")
        coder.encodeObject(setsAnother, forKey: "setsAnother")
        super.encode(with: coder.coder)
    }

    func sets(_ anotherSetting: DynamicSetting, when: Bool) -> Bool? {
        for dynamicSetAnother in setsAnother {
            if dynamicSetAnother.key == anotherSetting.key && (dynamicSetAnother.when == nil || dynamicSetAnother.when == when) {
                return dynamicSetAnother.value
            }
        }
        return nil
    }
}

extension DynamicSetting {
    override class func fromJSON(_ data: [String: AnyObject]) -> DynamicSetting {
        let json = JSON(data)
        let label = json["label"].stringValue
        let key = json["key"].stringValue

        let dependentOn: [String]
        if let jsonDependentOn = json["dependent_on"].array {
            dependentOn = jsonDependentOn.flatMap { $0.string }
        }
        else {
            dependentOn = []
        }

        let conflictsWith: [String]
        if let jsonConflictsWith = json["conflicts_with"].array {
            conflictsWith = jsonConflictsWith.flatMap { $0.string }
        }
        else {
            conflictsWith = []
        }

        let setsAnother: [DynamicSetAnother]
        if let jsonSetsAnother = json["sets_another"].array {
            setsAnother = jsonSetsAnother.flatMap { json in
                if let val = json.object as? [String: AnyObject] {
                    return DynamicSetAnother.fromJSON(val) as? DynamicSetAnother
                }
                return nil
            }
        }
        else {
            setsAnother = []
        }

        let info = json["info"].string
        let linkLabel = json["link"]["label"].string
        let linkURL = json["link"]["url"].url

        return DynamicSetting(label: label, key: key, info: info, linkLabel: linkLabel, linkURL: linkURL, dependentOn: dependentOn, conflictsWith: conflictsWith, setsAnother: setsAnother)
    }
}

extension DynamicSetting {
    static var blockedSetting: DynamicSetting {
        let label = InterfaceString.Settings.BlockedTitle
        let info = InterfaceString.Settings.BlockedTitle
        return DynamicSetting(label: label, key: "delete_account", info: info)
    }
    static var mutedSetting: DynamicSetting {
        let label = InterfaceString.Settings.MutedTitle
        let info = InterfaceString.Settings.MutedTitle
        return DynamicSetting(label: label, key: "delete_account", info: info)
    }
    static var accountDeletionSetting: DynamicSetting {
        let label = InterfaceString.Settings.DeleteAccount
        let info = InterfaceString.Settings.DeleteAccountExplanation
        return DynamicSetting(label: label, key: "delete_account", info: info)
    }
}
