////
///  Username.swift
//

import SwiftyJSON

let UsernameVersion: Int = 1

@objc(Username)
final class Username: JSONAble {
    let username: String
    var atName: String { return "@\(username)"}

    init(username: String) {
        self.username = username
        super.init(version: UsernameVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.username = decoder.decodeKey("username")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(username, forKey: "username")
        super.encode(with: coder)
    }

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        return Username(username: json["username"].stringValue)
    }

}
