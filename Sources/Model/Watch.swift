////
///  Watch.swift
//

import SwiftyJSON


let WatchVersion: Int = 1

@objc(Watch)
final class Watch: JSONAble, PostActionable {

    // active record
    let id: String
    let createdAt: Date
    let updatedAt: Date
    // required
    let postId: String
    let userId: String

    var post: Post? {
        return ElloLinkedStore.sharedInstance.getObject(self.postId, type: .postsType) as? Post
    }

    var user: User? {
        return ElloLinkedStore.sharedInstance.getObject(self.userId, type: .usersType) as? User
    }

// MARK: Initialization

    init(id: String,
        createdAt: Date,
        updatedAt: Date,
        postId: String,
        userId: String )
    {
        // active record
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        // required
        self.postId = postId
        self.userId = userId
        super.init(version: WatchVersion)
    }


// MARK: NSCoding
    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        self.updatedAt = decoder.decodeKey("updatedAt")
        // required
        self.postId = decoder.decodeKey("postId")
        self.userId = decoder.decodeKey("userId")
        super.init(coder: decoder.coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        coder.encodeObject(updatedAt, forKey: "updatedAt")
        // required
        coder.encodeObject(postId, forKey: "postId")
        coder.encodeObject(userId, forKey: "userId")
        super.encode(with: coder.coder)
    }

// MARK: JSONAble

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        var createdAt: Date
        var updatedAt: Date
        if let date = json["created_at"].stringValue.toDate() {
            // good to go
            createdAt = date
        }
        else {
            createdAt = Date()
        }

        if let date = json["updated_at"].stringValue.toDate() {
            // good to go
            updatedAt = date
        }
        else {
            updatedAt = Date()
        }

        // create Watch
        let watch = Watch(
            id: json["id"].stringValue,
            createdAt: createdAt,
            updatedAt: updatedAt,
            postId: json["post_id"].stringValue,
            userId: json["user_id"].stringValue
        )

        return watch
    }
}

extension Watch: JSONSaveable {
    var uniqueId: String? { return "Watch-\(id)" }
    var tableId: String? { return id }

}
