////
///  AmazonCredentials.swift
//


let AmazonCredentialsVersion = 2

@objc(AmazonCredentials)
class AmazonCredentials: JSONAble {
    let accessKey: String
    let endpoint: String
    let policy: String
    let prefix: String
    let signature: String

    init(accessKey: String, endpoint: String, policy: String, prefix: String, signature: String) {
        self.accessKey = accessKey
        self.endpoint = endpoint
        self.policy = policy
        self.prefix = prefix
        self.signature = signature
        super.init(version: AmazonCredentialsVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        let version: Int = decoder.decodeKey("version")
        if version > 1 {
            accessKey = decoder.decodeKey("accessKey")
            endpoint = decoder.decodeKey("endpoint")
            policy = decoder.decodeKey("policy")
            prefix = decoder.decodeKey("prefix")
            signature = decoder.decodeKey("signature")
        }
        else {
            accessKey = ""
            endpoint = ""
            policy = ""
            prefix = ""
            signature = ""
        }
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(accessKey, forKey: "accessKey")
        coder.encodeObject(endpoint, forKey: "endpoint")
        coder.encodeObject(policy, forKey: "policy")
        coder.encodeObject(prefix, forKey: "prefix")
        coder.encodeObject(signature, forKey: "signature")
    }

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        return AmazonCredentials(
            accessKey: data["access_key"] as! String,
            endpoint: data["endpoint"] as! String,
            policy: data["policy"] as! String,
            prefix: data["prefix"] as! String,
            signature: data["signature"] as! String
        )
    }
}

extension AmazonCredentials: JSONSaveable {
    var uniqueId: String? { return "AmazonCredentials-\(accessKey)" }
    var tableId: String? { return accessKey }

}
