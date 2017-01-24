////
///  LocalPerson.swift
//

import Foundation

// version 1: initial
// version 2: change 'id' from Int32 to String
let LocalPersonVersion = 2

@objc(LocalPerson)
final class LocalPerson: JSONAble {
    let name: String
    let emails: [String]
    let id: String

    var identifier: String {
        return "\(id)"
    }

    init(name: String, emails: [String], id: String) {
        self.name = name
        self.emails = emails
        self.id = id
        super.init(version: LocalPersonVersion)
    }

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.name = decoder.decodeKey("name")
        self.emails = decoder.decodeKey("emails")
        let version: Int = decoder.decodeKey("version")
        if version < 2 {
            let idInt: Int32 = decoder.decodeKey("id")
            self.id = "\(idInt)"
        }
        else {
            self.id = decoder.decodeKey("id")
        }
        super.init(coder: decoder.coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(emails, forKey: "emails")
        coder.encodeObject(id, forKey: "id")
        super.encode(with: coder.coder)
    }

    // this shouldn't ever get called
    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        return LocalPerson(name: "Unknown", emails: ["unknown@example.com"], id: "unknown")
    }
}

extension LocalPerson: JSONSaveable {
    var uniqueId: String? { if let id = tableId { return "LocalPerson-\(id)" } ; return nil }
    var tableId: String? { return "\(id)" }

}
