////
///  Watch.swift
//

import SwiftyJSON


let WatchVersion: Int = 1

@objc(Watch)
final class Watch: Model, PostActionable {
    let id: String
    let postId: String
    let userId: String

    var post: Post? { return getLinkObject("post") }
    var user: User? { return getLinkObject("user") }

    init(id: String,
        postId: String,
        userId: String )
    {
        self.id = id
        self.postId = postId
        self.userId = userId
        super.init(version: WatchVersion)

        addLinkObject("post", id: postId, type: .postsType)
        addLinkObject("user", id: userId, type: .usersType)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.id = decoder.decodeKey("id")
        self.postId = decoder.decodeKey("postId")
        self.userId = decoder.decodeKey("userId")
        super.init(coder: coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(postId, forKey: "postId")
        coder.encodeObject(userId, forKey: "userId")
        super.encode(with: coder.coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Watch {
        let json = JSON(data)

        let watch = Watch(
            id: json["id"].stringValue,
            postId: json["post_id"].stringValue,
            userId: json["user_id"].stringValue
        )

        watch.mergeLinks(data["links"] as? [String: Any])
        watch.addLinkObject("post", id: watch.postId, type: .postsType)
        watch.addLinkObject("user", id: watch.userId, type: .usersType)

        return watch
    }
}

extension Watch: JSONSaveable {
    var uniqueId: String? { return "Watch-\(id)" }
    var tableId: String? { return id }
}
