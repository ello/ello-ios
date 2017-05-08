////
///  Editorial.swift
//

import SwiftyJSON

// Version 1: initial
let EditorialVersion = 3

final class Editorial: JSONAble, Groupable {

    let id: String
    var groupId: String { return "Category-\(id)" }

    init(id: String)
    {
        self.id = id
        super.init(version: EditorialVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        super.encode(with: coder)
    }

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        let id = json["id"].stringValue
        let editorial = Editorial(id: id)
        return editorial
    }
}

extension Editorial: JSONSaveable {
    var uniqueId: String? { return "Editorial-\(id)" }
    var tableId: String? { return id }
}
