////
///  Nonce.swift
//

import SwiftyJSON

let NonceVersion: Int = 1

final class Nonce: Model {
    let value: String

    init(value: String) {
        self.value = value
        super.init(version: NonceVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.value = decoder.decodeKey("nonce")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(value, forKey: "nonce")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Nonce {
        let json = JSON(data)
        return Nonce(value: json["nonce"].stringValue)
    }

}
