////
///  Watch.swift
//

import SwiftyJSON


let WatchVersion: Int = 1

@objc(Watch)
final class Watch: Model, PostActionable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let postId: String
    let userId: String

    var post: Post? {
        return ElloLinkedStore.shared.getObject(self.postId, type: .postsType) as? Post
    }

    var user: User? {
        return ElloLinkedStore.shared.getObject(self.userId, type: .usersType) as? User
    }

    init(id: String,
        createdAt: Date,
        updatedAt: Date,
        postId: String,
        userId: String )
    {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.postId = postId
        self.userId = userId
        super.init(version: WatchVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        self.updatedAt = decoder.decodeKey("updatedAt")
        self.postId = decoder.decodeKey("postId")
        self.userId = decoder.decodeKey("userId")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        coder.encodeObject(updatedAt, forKey: "updatedAt")
        coder.encodeObject(postId, forKey: "postId")
        coder.encodeObject(userId, forKey: "userId")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Watch {
        let json = JSON(data)
        var createdAt: Date
        var updatedAt: Date
        if let date = json["created_at"].stringValue.toDate() {
            // good to go
            createdAt = date
        }
        else {
            createdAt = Globals.now
        }

        if let date = json["updated_at"].stringValue.toDate() {
            // good to go
            updatedAt = date
        }
        else {
            updatedAt = Globals.now
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
