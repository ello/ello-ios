////
///  UserAvatarCellModel.swift
//

import Foundation

let UserAvatarCellModelVersion = 2

@objc(UserAvatarCellModel)
final class UserAvatarCellModel: JSONAble {

    let icon: InterfaceImage
    let seeMoreTitle: String
    var endpoint: ElloAPI?
    var users: [User]?

    var hasUsers: Bool {
        if let arr = users {
            return arr.count > 0
        }
        return false
    }

    init(icon: InterfaceImage, seeMoreTitle: String) {
        self.icon = icon
        self.seeMoreTitle = seeMoreTitle
        super.init(version: UserAvatarCellModelVersion)
    }

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.icon = decoder.decodeKey("icon")
        self.seeMoreTitle = decoder.decodeKey("seeMoreTitle")
        super.init(coder: decoder.coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(icon, forKey: "icon")
        coder.encodeObject(seeMoreTitle, forKey: "seeMoreTitle")
        super.encode(with: coder.coder)
    }

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        return UserAvatarCellModel(
            icon: InterfaceImage(rawValue: (data["icon"] as? String) ?? "hearts")!,
            seeMoreTitle: (data["seeMoreTitle"] as? String) ?? ""
        )
    }

}
